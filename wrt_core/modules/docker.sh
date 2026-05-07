#!/usr/bin/env bash

_docker_stack_resolve_component_makefile() {
    local build_dir="$1"
    local component="$2"
    local candidate=""

    for candidate in \
        "$build_dir/package/feeds/packages/$component/Makefile" \
        "$build_dir/feeds/packages/utils/$component/Makefile"; do
        [ -f "$candidate" ] && {
            echo "$candidate"
            return 0
        }
    done

    echo "错误：未找到 $component Makefile（已检查 package/feeds 与 feeds/packages）" >&2
    return 1
}

_docker_stack_resolve_dockerd_file() {
    local build_dir="$1"
    local rel="$2"
    local candidate=""

    for candidate in \
        "$build_dir/package/feeds/packages/dockerd/$rel" \
        "$build_dir/feeds/packages/utils/dockerd/$rel"; do
        [ -f "$candidate" ] && {
            echo "$candidate"
            return 0
        }
    done

    echo "错误：未找到 dockerd 文件 $rel（已检查 package/feeds 与 feeds/packages）" >&2
    return 1
}

_docker_stack_resolve_dockerman_init() {
    local build_dir="$1"
    local candidate=""

    for candidate in \
        "$build_dir/feeds/luci/applications/luci-app-dockerman/root/etc/init.d/dockerman" \
        "$build_dir/package/feeds/luci/luci-app-dockerman/root/etc/init.d/dockerman" \
        "$build_dir/package/feeds/luci/applications/luci-app-dockerman/root/etc/init.d/dockerman"; do
        [ -f "$candidate" ] && {
            echo "$candidate"
            return 0
        }
    done

    return 1
}

_docker_stack_normalize_build_dir() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        echo "$path"
    else
        echo "$(pwd)/$path"
    fi
}

_docker_stack_set_or_append_dockerd_uci_option() {
    local config_path="$1"
    local option_name="$2"
    local option_value="$3"

    if grep -Eq "^[[:space:]]*option[[:space:]]+${option_name}[[:space:]]+" "$config_path"; then
        sed -i "s|^[[:space:]]*option[[:space:]]\+${option_name}[[:space:]]\+.*|\toption ${option_name} '${option_value}'|" "$config_path"
    elif grep -q "^config globals 'globals'" "$config_path"; then
        sed -i "/^config globals 'globals'/a\	option ${option_name} '${option_value}'" "$config_path"
    else
        echo "错误：$config_path 中缺少 config globals 'globals' 段，无法设置 $option_name" >&2
        return 1
    fi
}

_docker_stack_set_or_append_sysctl_value() {
    local sysctl_path="$1"
    local sysctl_key="$2"
    local sysctl_value="$3"
    local sysctl_key_regex="${sysctl_key//./\\.}"

    if grep -Eq "^[[:space:]]*${sysctl_key_regex}[[:space:]]*=" "$sysctl_path"; then
        sed -i "s|^[[:space:]]*${sysctl_key_regex}[[:space:]]*=.*|${sysctl_key}=${sysctl_value}|" "$sysctl_path"
    else
        printf '%s=%s\n' "$sysctl_key" "$sysctl_value" >> "$sysctl_path"
    fi
}

_docker_stack_update_dockerd_depends_block() {
    local mk_path="$1"
    local tmp_path=""

    tmp_path=$(mktemp) || {
        echo "错误：创建临时文件失败" >&2
        return 1
    }

    awk '
        BEGIN {
            in_depends = 0
            replaced = 0
        }
        /^  DEPENDS:=\$\(ARCH_DEPENDS\) \\$/ {
            in_depends = 1
            replaced = 1

            print "  DEPENDS:=$(ARCH_DEPENDS) \\" 
            print "    +ca-certificates \\" 
            print "    +containerd \\" 
            print "    +iptables-nft \\" 
            print "    +iptables-mod-extra \\" 
            print "    +IPV6:ip6tables-nft \\" 
            print "    +IPV6:kmod-ipt-nat6 \\" 
            print "    +KERNEL_SECCOMP:libseccomp \\" 
            print "    +kmod-ipt-nat \\" 
            print "    +kmod-ipt-physdev \\" 
            print "    +kmod-nf-ipvs \\" 
            print "    +kmod-veth \\" 
            print "    +nftables \\" 
            print "    +kmod-nft-nat \\" 
            print "    +tini \\" 
            print "    +uci-firewall"
            next
        }
        in_depends {
            if ($0 ~ /^  [A-Z0-9_]+:=/ || $0 ~ /^endef$/) {
                in_depends = 0
                print
            }
            next
        }
        {
            print
        }
        END {
            if (replaced == 0) {
                exit 2
            }
        }
    ' "$mk_path" > "$tmp_path" || {
        rm -f "$tmp_path"
        echo "错误：未能重写 $mk_path 的 DEPENDS 块" >&2
        return 1
    }

    mv "$tmp_path" "$mk_path"
}

_docker_stack_fix_dockerd_vendored_checks() {
    local mk_path="$1"
    local tmp_path=""

    tmp_path=$(mktemp) || {
        echo "错误：创建临时文件失败" >&2
        return 1
    }

    awk '
        {
            if ($0 ~ /^[[:space:]]*\[ ! -f "\$\(PKG_BUILD_DIR\)\/hack\/dockerfile\/install\/containerd\.installer" \] \|\|[[:space:]]*\\$/) {
                next
            }

            if ($0 ~ /^[[:space:]]*\[ ! -f "\$\(PKG_BUILD_DIR\)\/hack\/dockerfile\/install\/runc\.installer" \] \|\|[[:space:]]*\\$/) {
                next
            }

            if ($0 ~ /^[[:space:]]*\$\(call EnsureVendoredVersion,\.\.\/containerd\/Makefile,containerd\.installer\)$/) {
                print "\t[ ! -f \"$(PKG_BUILD_DIR)/hack/dockerfile/install/containerd.installer\" ] || \\" 
                print "\t\t$(call EnsureVendoredVersion,../containerd/Makefile,containerd.installer)"
                next
            }

            if ($0 ~ /^[[:space:]]*\$\(call EnsureVendoredVersion,\.\.\/runc\/Makefile,runc\.installer\)$/) {
                print "\t[ ! -f \"$(PKG_BUILD_DIR)/hack/dockerfile/install/runc.installer\" ] || \\" 
                print "\t\t$(call EnsureVendoredVersion,../runc/Makefile,runc.installer)"
                next
            }

            print
        }
    ' "$mk_path" > "$tmp_path" || {
        rm -f "$tmp_path"
        echo "错误：未能修补 $mk_path 的 vendored 依赖校验" >&2
        return 1
    }

    mv "$tmp_path" "$mk_path"
}

_docker_stack_fix_dockerd_nftables_comment() {
    local config_path="$1"

    if grep -Fq "Docker doesn't work well out of the box with fw4." "$config_path"; then
        sed -i \
            -e "/^# Docker doesn't work well out of the box with fw4\./c\# firewall_backend defaults to nftables and is expected to work with fw4." \
            -e "/^# naively translates iptables rules\. For the best compatibility replace the following dependencies:/c\# If you must use legacy behavior for compatibility, switch \`firewall_backend\` to \`iptables\`." \
            -e "/^# \`firewall4\` -> \`firewall\`/d" \
            -e "/^# \`iptables-nft\` -> \`iptables-legacy\`/d" \
            -e "/^# \`ip6tables-nft\` -> \`ip6tables-legacy\`/d" \
            "$config_path"
    fi
}

_docker_stack_warn() {
    echo "警告：$*" >&2
}

_docker_stack_dockerman_init_supports_nftables_backend() {
    local dockerman_init="$1"

    grep -Fq 'dockerman_use_iptables() {' "$dockerman_init" \
        && grep -Fq 'dockerman_use_iptables || {' "$dockerman_init"
}

_docker_stack_patch_dockerman_backend_helpers() {
    local dockerman_init="$1"
    local tmp_path=""

    grep -Fq 'dockerman_use_iptables() {' "$dockerman_init" && return 0

    tmp_path=$(mktemp) || {
        echo "错误：创建临时文件失败" >&2
        return 1
    }

    awk '
        BEGIN {
            inserted = 0
        }
        {
            print
            if ($0 ~ /^_DOCKERD=\/etc\/init\.d\/dockerd$/ && inserted == 0) {
                inserted = 1
                print ""
                print "dockerman_firewall_backend() {"
                print "\tlocal backend=\"\""
                print "\tbackend=\"$(uci -q get dockerd.globals.firewall_backend 2>/dev/null)\""
                print "\t[ -n \"${backend}\" ] || backend=\"nftables\""
                print "\techo \"${backend}\""
                print "}"
                print ""
                print "dockerman_use_iptables() {"
                print "\tlocal backend=\"\""
                print "\tlocal iptables_enabled=\"\""
                print ""
                print "\tbackend=\"$(dockerman_firewall_backend)\""
                print "\t[ \"${backend}\" = \"iptables\" ] || return 1"
                print ""
                print "\tiptables_enabled=\"$(uci -q get dockerd.globals.iptables 2>/dev/null)\""
                print "\t[ -n \"${iptables_enabled}\" ] || iptables_enabled=\"1\""
                print ""
                print "\t[ \"${iptables_enabled}\" = \"1\" ]"
                print "}"
            }
        }
        END {
            if (inserted == 0) {
                exit 2
            }
        }
    ' "$dockerman_init" > "$tmp_path" || {
        rm -f "$tmp_path"
        echo "错误：无法在 $dockerman_init 注入 firewall backend 辅助函数" >&2
        return 1
    }

    mv "$tmp_path" "$dockerman_init"
}

_docker_stack_patch_dockerman_start_service() {
    local dockerman_init="$1"
    local tmp_path=""

    grep -Fq 'dockerman_use_iptables || {' "$dockerman_init" && return 0

    tmp_path=$(mktemp) || {
        echo "错误：创建临时文件失败" >&2
        return 1
    }

    awk '
        BEGIN {
            inserted = 0
        }
        {
            print
            if ($0 ~ /^[[:space:]]*\$\(\$_DOCKERD running\) && docker_running \|\| return 0$/ && inserted == 0) {
                inserted = 1
                print "\tdockerman_use_iptables || {"
                print "\t\tlogger -t \"dockerman\" -p notice \"dockerd firewall backend is nftables; skip DOCKER-MAN iptables chain management\""
                print "\t\treturn 0"
                print "\t}"
            }
        }
        END {
            if (inserted == 0) {
                exit 2
            }
        }
    ' "$dockerman_init" > "$tmp_path" || {
        rm -f "$tmp_path"
        echo "错误：无法在 $dockerman_init 的 start_service 注入 nftables 分支" >&2
        return 1
    }

    mv "$tmp_path" "$dockerman_init"
}

_docker_stack_ensure_dockerman_nftables_compat() {
    local dockerman_init="$1"

    _docker_stack_dockerman_init_supports_nftables_backend "$dockerman_init" && return 0

    _docker_stack_warn "$dockerman_init 缺少 nftables 兼容逻辑，正在执行原位补丁"

    _docker_stack_patch_dockerman_backend_helpers "$dockerman_init" || return 1
    _docker_stack_patch_dockerman_start_service "$dockerman_init" || return 1

    _docker_stack_dockerman_init_supports_nftables_backend "$dockerman_init" || {
        echo "错误：补丁后 $dockerman_init 仍缺少 nftables 兼容逻辑" >&2
        return 1
    }
}

docker_stack_sync_dockerman_nftables_compat() {
    local build_dir="$1"
    local dry_run="${2:-0}"
    local dockerman_init=""

    [ -n "$build_dir" ] || {
        echo "错误：docker_stack_sync_dockerman_nftables_compat 缺少 build_dir 参数" >&2
        return 1
    }

    build_dir=$(_docker_stack_normalize_build_dir "$build_dir")
    dockerman_init=$(_docker_stack_resolve_dockerman_init "$build_dir" || true)
    [ -n "$dockerman_init" ] || return 0

    if [ "$dry_run" = "1" ]; then
        if _docker_stack_dockerman_init_supports_nftables_backend "$dockerman_init"; then
            echo "[dry-run] dockerman init already skips DOCKER-MAN iptables chain when backend=nftables"
        else
            echo "[dry-run] dockerman init will be patched to skip DOCKER-MAN iptables chain when backend=nftables"
        fi
        return 0
    fi

    _docker_stack_ensure_dockerman_nftables_compat "$dockerman_init"
}

_docker_stack_init_supports_nftables_backend() {
    local dockerd_init="$1"

    grep -Fq 'NFT_DOCKER_USER_TABLE="docker-user"' "$dockerd_init" \
        && grep -Fq 'verify_nftables_swarm_is_disabled "${data_root}" || return 1' "$dockerd_init" \
        && grep -Fq 'verify_nftables_forwarding || return 1' "$dockerd_init" \
        && grep -Fq 'verify_nftables_prerequisites "${data_root}" || return 1' "$dockerd_init" \
        && grep -Fq 'nft add rule inet "${NFT_DOCKER_USER_TABLE}" "${NFT_DOCKER_USER_CHAIN}" iifname "${inbound}" oifname "${outbound}" reject' "$dockerd_init"
}

_docker_stack_patch_nft_prereq_block() {
    local dockerd_init="$1"
    local tmp_path=""

    if grep -Fq '# === DOCKER_STACK_NFT_PREREQ_START ===' "$dockerd_init"; then
        tmp_path=$(mktemp) || {
            echo "错误：创建临时文件失败" >&2
            return 1
        }

        awk '
            BEGIN { in_block = 0 }
            {
                if ($0 ~ /^# === DOCKER_STACK_NFT_PREREQ_START ===$/) {
                    in_block = 1
                    next
                }
                if ($0 ~ /^# === DOCKER_STACK_NFT_PREREQ_END ===$/) {
                    in_block = 0
                    next
                }
                if (in_block == 0) {
                    print
                }
            }
        ' "$dockerd_init" > "$tmp_path" || {
            rm -f "$tmp_path"
            echo "错误：无法清理旧的 nftables 前置校验函数块" >&2
            return 1
        }

        mv "$tmp_path" "$dockerd_init"
    fi

    tmp_path=$(mktemp) || {
        echo "错误：创建临时文件失败" >&2
        return 1
    }

    awk '
        BEGIN {
            inserted = 0
        }
        {
            print
            if ($0 ~ /^DOCKERD_CONF="\$\{DOCKER_CONF_DIR\}\/daemon\.json"$/) {
                inserted = 1
                print ""
                print "# === DOCKER_STACK_NFT_PREREQ_START ==="
                print "NFT_DOCKER_USER_TABLE=\"docker-user\""
                print "NFT_DOCKER_USER_CHAIN=\"forward\""
                print ""
                print "BLOCKING_RULE_ERROR=0"
                print ""
                print "set_blocking_rule_error() {"
                print "\tBLOCKING_RULE_ERROR=1"
                print "}"
                print ""
                print "verify_nftables_swarm_is_disabled() {"
                print "\tlocal data_root=\"${1}\""
                print "\treturn 0"
                print "}"
                print ""
                print "verify_nftables_forwarding() {"
                print "\tlocal ipv4_forwarding=\"\""
                print "\tlocal ipv6_forwarding=\"\""
                print ""
                print "\tipv4_forwarding=\"$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)\""
                print "\tipv6_forwarding=\"$(cat /proc/sys/net/ipv6/conf/all/forwarding 2>/dev/null)\""
                print ""
                print "\tif [ \"${ipv4_forwarding}\" != \"1\" ] || [ \"${ipv6_forwarding}\" != \"1\" ]; then"
                print "\t\tlogger -t \"dockerd-init\" -p err \"Docker nftables backend requires net.ipv4.ip_forward=1 and net.ipv6.conf.all.forwarding=1 before startup\""
                print "\t\treturn 1"
                print "\tfi"
                print ""
                print "\treturn 0"
                print "}"
                print ""
                print "verify_nftables_prerequisites() {"
                print "\tlocal data_root=\"${1}\""
                print ""
                print "\tverify_nftables_swarm_is_disabled \"${data_root}\" || return 1"
                print "\tverify_nftables_forwarding || return 1"
                print "}"
                print "# === DOCKER_STACK_NFT_PREREQ_END ==="
            }
        }
        END {
            if (inserted == 0) {
                exit 2
            }
        }
    ' "$dockerd_init" > "$tmp_path" || {
        rm -f "$tmp_path"
        echo "错误：无法在 $dockerd_init 注入 nftables 前置校验函数块" >&2
        return 1
    }

    mv "$tmp_path" "$dockerd_init"
}

_docker_stack_patch_process_config_nftables() {
    local dockerd_init="$1"
    local tmp_path=""

    sed -i 's/^[[:space:]]*local alt_config_file data_root log_level iptables ip6tables bip$/\tlocal alt_config_file data_root log_level firewall_backend iptables ip6tables bip/' "$dockerd_init"

    if ! grep -Fq 'config_get firewall_backend globals firewall_backend "nftables"' "$dockerd_init"; then
        tmp_path=$(mktemp) || {
            echo "错误：创建临时文件失败" >&2
            return 1
        }

        awk '
            BEGIN {
                replaced = 0
                skipping = 0
            }
            {
                if ($0 ~ /^[[:space:]]*config_get data_root globals data_root "\/opt\/docker\/"$/) {
                    replaced = 1
                    skipping = 1

                    print "\tconfig_get data_root globals data_root \"/opt/docker/\""
                    print "\tconfig_get log_level globals log_level \"warn\""
                    print "\tif uci_quiet get dockerd.globals.firewall_backend; then"
                    print "\t\tconfig_get firewall_backend globals firewall_backend \"nftables\""
                    print "\telse"
                    print "\t\tfirewall_backend=\"nftables\""
                    print "\t\tlogger -t \"dockerd-init\" -p notice \"Migrating dockerd firewall backend to ${firewall_backend}\""
                    print "\t\tuci_quiet set dockerd.globals.firewall_backend=\"${firewall_backend}\" && uci_quiet commit dockerd || {"
                    print "\t\t\tlogger -t \"dockerd-init\" -p err \"Failed to persist dockerd firewall backend migration\""
                    print "\t\t\treturn 1"
                    print "\t\t}"
                    print "\tfi"
                    print "\tcase \"${firewall_backend}\" in"
                    print "\t\tiptables|nftables)"
                    print "\t\t\t;;"
                    print "\t\t*)"
                    print "\t\t\tlogger -t \"dockerd-init\" -p notice \"Unsupported dockerd firewall backend ${firewall_backend}, defaulting to nftables\""
                    print "\t\t\tfirewall_backend=\"nftables\""
                    print "\t\t\t;;"
                    print "\tesac"
                    print "\tif [ \"${firewall_backend}\" = \"nftables\" ]; then"
                    print "\t\tverify_nftables_prerequisites \"${data_root}\" || return 1"
                    print "\tfi"
                    print "\tconfig_get_bool iptables globals iptables \"1\""
                    print "\tconfig_get_bool ip6tables globals ip6tables \"0\""
                    next
                }

                if (skipping == 1) {
                    if ($0 ~ /^[[:space:]]*config_get_bool ip6tables globals ip6tables "0"$/) {
                        skipping = 0
                    }
                    next
                }

                print
            }
            END {
                if (replaced == 0) {
                    exit 2
                }
            }
        ' "$dockerd_init" > "$tmp_path" || {
            rm -f "$tmp_path"
            echo "错误：无法重写 $dockerd_init 的 firewall_backend 配置段" >&2
            return 1
        }

        mv "$tmp_path" "$dockerd_init"
    fi

    if ! grep -Fq 'json_add_string "firewall-backend" "${firewall_backend}"' "$dockerd_init"; then
        sed -i '/^[[:space:]]*json_add_string "log-level" "${log_level}"$/a\	json_add_string "firewall-backend" "${firewall_backend}"' "$dockerd_init"
    fi

    if ! grep -Fq 'BLOCKING_RULE_ERROR=0' "$dockerd_init"; then
        tmp_path=$(mktemp) || {
            echo "错误：创建临时文件失败" >&2
            return 1
        }

        awk '
            BEGIN {
                replaced = 0
            }
            {
                if ($0 ~ /^[[:space:]]*\[ "\$\{iptables\}" -eq "1" \] && config_foreach iptables_add_blocking_rule firewall$/) {
                    replaced = 1
                    print "\tBLOCKING_RULE_ERROR=0"
                    print "\tif [ \"${firewall_backend}\" = \"nftables\" ]; then"
                    print "\t\tnftables_create_blocking_table || {"
                    print "\t\t\tset_blocking_rule_error"
                    print "\t\t\treturn 1"
                    print "\t\t}"
                    print "\t\tif ! nft flush chain inet \"${NFT_DOCKER_USER_TABLE}\" \"${NFT_DOCKER_USER_CHAIN}\"; then"
                    print "\t\t\tlogger -t \"dockerd-init\" -p err \"Failed to reset nftables docker policy chain\""
                    print "\t\t\tset_blocking_rule_error"
                    print "\t\t\treturn 1"
                    print "\t\tfi"
                    print "\tfi"
                    print ""
                    print "\tconfig_foreach iptables_add_blocking_rule firewall \"${firewall_backend}\""
                    print "\t[ \"${BLOCKING_RULE_ERROR}\" -eq 0 ] || return 1"
                    next
                }
                print
            }
            END {
                if (replaced == 0) {
                    exit 2
                }
            }
        ' "$dockerd_init" > "$tmp_path" || {
            rm -f "$tmp_path"
            echo "错误：无法重写 $dockerd_init 的 blocked_interfaces 处理段" >&2
            return 1
        }

        mv "$tmp_path" "$dockerd_init"
    fi
}

_docker_stack_patch_service_error_handling() {
    local dockerd_init="$1"

    sed -i '/^start_service() {/,/^}/{s/^[[:space:]]*process_config$/\tprocess_config || return 1/}' "$dockerd_init"
    sed -i '/^reload_service() {/,/^}/{s/^[[:space:]]*process_config$/\tprocess_config || return 1/}' "$dockerd_init"
}

_docker_stack_patch_iptables_dispatch() {
    local dockerd_init="$1"
    local tmp_path=""

    tmp_path=$(mktemp) || {
        echo "错误：创建临时文件失败" >&2
        return 1
    }

    awk '
        {
            if ($0 ~ /^[[:space:]]*local firewall_backend="\$\{2\}"$/) {
                next
            }
            if ($0 ~ /^[[:space:]]*local iptables="1"$/) {
                next
            }
            print
        }
    ' "$dockerd_init" > "$tmp_path" || {
        rm -f "$tmp_path"
        echo "错误：无法清理 $dockerd_init 中旧的 firewall_backend 注入行" >&2
        return 1
    }

    mv "$tmp_path" "$dockerd_init"

    if ! grep -Fq 'local firewall_backend="${2}"' "$dockerd_init"; then
        tmp_path=$(mktemp) || {
            echo "错误：创建临时文件失败" >&2
            return 1
        }

        awk '
            BEGIN {
                in_target = 0
                inserted = 0
            }
            {
                if ($0 ~ /^iptables_add_blocking_rule\(\) \{$/) {
                    in_target = 1
                    print
                    next
                }

                if (in_target == 1 && $0 ~ /^[[:space:]]*local cfg="\$\{1\}"$/ && inserted == 0) {
                    inserted = 1
                    print $0
                    print "\tlocal firewall_backend=\"${2}\""
                    print "\tlocal iptables=\"1\""
                    print ""
                    next
                }

                if (in_target == 1 && $0 ~ /^}$/) {
                    in_target = 0
                }

                print
            }
            END {
                if (inserted == 0) {
                    exit 2
                }
            }
        ' "$dockerd_init" > "$tmp_path" || {
            rm -f "$tmp_path"
            echo "错误：无法向 $dockerd_init 注入 firewall_backend 参数" >&2
            return 1
        }

        mv "$tmp_path" "$dockerd_init"
    fi

    if ! grep -Fq 'nftables_add_blocking_rules "${cfg}"' "$dockerd_init"; then
        tmp_path=$(mktemp) || {
            echo "错误：创建临时文件失败" >&2
            return 1
        }

        awk '
            BEGIN {
                in_target = 0
                inserted = 0
            }
            {
                if ($0 ~ /^iptables_add_blocking_rule\(\) \{$/) {
                    in_target = 1
                    print
                    next
                }

                if (in_target == 1 && $0 ~ /^[[:space:]]*config_get device "\$\{cfg\}" device$/ && inserted == 0) {
                    inserted = 1
                    print "\tif [ \"${firewall_backend}\" = \"nftables\" ]; then"
                    print "\t\tnftables_add_blocking_rules \"${cfg}\""
                    print "\t\treturn"
                    print "\tfi"
                    print ""
                    print "\tconfig_get_bool iptables globals iptables \"1\""
                    print "\t[ \"${iptables}\" -eq \"1\" ] || return"
                    print ""
                }

                if (in_target == 1 && $0 ~ /^}$/) {
                    in_target = 0
                }

                print
            }
            END {
                if (inserted == 0) {
                    exit 2
                }
            }
        ' "$dockerd_init" > "$tmp_path" || {
            rm -f "$tmp_path"
            echo "错误：无法向 $dockerd_init 注入 nftables 规则分支" >&2
            return 1
        }

        mv "$tmp_path" "$dockerd_init"
    fi
}

_docker_stack_patch_append_nft_rule_helpers() {
    local dockerd_init="$1"
    local tmp_path=""

    grep -Fq 'nftables_create_blocking_table() {' "$dockerd_init" && grep -Fq 'nftables_add_blocking_rules() {' "$dockerd_init" && return 0

    tmp_path=$(mktemp) || {
        echo "错误：创建临时文件失败" >&2
        return 1
    }

    awk '
        BEGIN {
            inserted = 0
        }
        {
            if ($0 ~ /^stop_service\(\) \{$/ && inserted == 0) {
                inserted = 1
                print "nftables_create_blocking_table() {"
                print "\tif ! nft list table inet \"${NFT_DOCKER_USER_TABLE}\" >/dev/null 2>&1; then"
                print "\t\tif ! nft add table inet \"${NFT_DOCKER_USER_TABLE}\"; then"
                print "\t\t\tlogger -t \"dockerd-init\" -p err \"Failed to create nftables table inet ${NFT_DOCKER_USER_TABLE}\""
                print "\t\t\treturn 1"
                print "\t\tfi"
                print "\tfi"
                print ""
                print "\tif ! nft list chain inet \"${NFT_DOCKER_USER_TABLE}\" \"${NFT_DOCKER_USER_CHAIN}\" >/dev/null 2>&1; then"
                print "\t\tif ! nft add chain inet \"${NFT_DOCKER_USER_TABLE}\" \"${NFT_DOCKER_USER_CHAIN}\" '\''{ type filter hook forward priority 0; policy accept; }'\''; then"
                print "\t\t\tlogger -t \"dockerd-init\" -p err \"Failed to create nftables chain inet ${NFT_DOCKER_USER_TABLE} ${NFT_DOCKER_USER_CHAIN}\""
                print "\t\t\treturn 1"
                print "\t\tfi"
                print "\tfi"
                print "}"
                print ""
                print "nftables_add_blocking_rules() {"
                print "\tlocal cfg=\"${1}\""
                print ""
                print "\tlocal device=\"\""
                print "\tlocal extra_iptables_args=\"\""
                print ""
                print "\thandle_nftables_rule() {"
                print "\t\tlocal interface=\"${1}\""
                print "\t\tlocal outbound=\"${2}\""
                print ""
                print "\t\tlocal inbound=\"\""
                print ""
                print "\t\t. /lib/functions/network.sh"
                print "\t\tnetwork_get_physdev inbound \"${interface}\""
                print ""
                print "\t\t[ -z \"${inbound}\" ] && {"
                print "\t\t\tlogger -t \"dockerd-init\" -p notice \"Unable to get physical device for interface ${interface}\""
                print "\t\t\treturn"
                print "\t\t}"
                print ""
                print "\t\tlogger -t \"dockerd-init\" -p notice \"Drop traffic from ${inbound} to ${outbound}\""
                print "\t\tif ! nft add rule inet \"${NFT_DOCKER_USER_TABLE}\" \"${NFT_DOCKER_USER_CHAIN}\" iifname \"${inbound}\" oifname \"${outbound}\" reject; then"
                print "\t\t\tlogger -t \"dockerd-init\" -p err \"Failed to add nftables docker policy from ${inbound} to ${outbound}\""
                print "\t\t\tset_blocking_rule_error"
                print "\t\t\treturn 1"
                print "\t\tfi"
                print "\t}"
                print ""
                print "\tconfig_get device \"${cfg}\" device"
                print ""
                print "\t[ -z \"${device}\" ] && {"
                print "\t\tlogger -t \"dockerd-init\" -p notice \"No device configured for ${cfg}\""
                print "\t\treturn"
                print "\t}"
                print ""
                print "\tconfig_get extra_iptables_args \"${cfg}\" extra_iptables_args"
                print "\t[ -n \"${extra_iptables_args}\" ] && {"
                print "\t\tlogger -t \"dockerd-init\" -p err \"extra_iptables_args is not supported when firewall_backend is nftables\""
                print "\t\tset_blocking_rule_error"
                print "\t\treturn 1"
                print "\t}"
                print ""
                print "\tconfig_list_foreach \"${cfg}\" blocked_interfaces handle_nftables_rule \"${device}\""
                print "}"
                print ""
            }
            print
        }
        END {
            if (inserted == 0) {
                exit 2
            }
        }
    ' "$dockerd_init" > "$tmp_path" || {
        rm -f "$tmp_path"
        echo "错误：无法向 $dockerd_init 追加 nftables 规则函数" >&2
        return 1
    }

    mv "$tmp_path" "$dockerd_init"
}

_docker_stack_ensure_nftables_init_support() {
    local dockerd_init="$1"

    if _docker_stack_init_supports_nftables_backend "$dockerd_init"; then
        _docker_stack_patch_iptables_dispatch "$dockerd_init" || return 1
        return 0
    fi

    _docker_stack_warn "$dockerd_init 缺少 nftables backend 逻辑，正在执行原位补丁"

    _docker_stack_patch_nft_prereq_block "$dockerd_init" || return 1
    _docker_stack_patch_process_config_nftables "$dockerd_init" || return 1
    _docker_stack_patch_service_error_handling "$dockerd_init" || return 1
    _docker_stack_patch_iptables_dispatch "$dockerd_init" || return 1
    _docker_stack_patch_append_nft_rule_helpers "$dockerd_init" || return 1

    _docker_stack_init_supports_nftables_backend "$dockerd_init" || {
        echo "错误：补丁后 $dockerd_init 仍缺少 nftables backend 逻辑" >&2
        return 1
    }
}

docker_stack_sync_nftables_compat() {
    local build_dir="${1:-${BUILD_DIR:-}}"
    local dry_run="${2:-${DOCKER_STACK_DRY_RUN:-0}}"
    local storage_driver="${3:-${DOCKER_STACK_STORAGE_DRIVER:-vfs}}"
    local dockerd_makefile=""
    local dockerd_config=""
    local dockerd_init=""
    local dockerd_sysctl=""

    [ -n "$build_dir" ] || {
        echo "错误：docker_stack_sync_nftables_compat 缺少 build_dir 参数" >&2
        return 1
    }

    if [ "$dry_run" != "0" ] && [ "$dry_run" != "1" ]; then
        echo "错误：docker_stack_sync_nftables_compat 仅支持 dry_run 为 0 或 1，当前值: $dry_run" >&2
        return 1
    fi

    build_dir=$(_docker_stack_normalize_build_dir "$build_dir")

    dockerd_makefile=$(_docker_stack_resolve_component_makefile "$build_dir" "dockerd") || return 1
    dockerd_config=$(_docker_stack_resolve_dockerd_file "$build_dir" "files/etc/config/dockerd") || return 1
    dockerd_init=$(_docker_stack_resolve_dockerd_file "$build_dir" "files/dockerd.init") || return 1
    dockerd_sysctl=$(_docker_stack_resolve_dockerd_file "$build_dir" "files/etc/sysctl.d/sysctl-br-netfilter-ip.conf") || return 1

    [ -f "$dockerd_makefile" ] || {
        echo "错误：未找到 dockerd Makefile: $dockerd_makefile" >&2
        return 1
    }
    [ -f "$dockerd_config" ] || {
        echo "错误：未找到 dockerd 配置文件: $dockerd_config" >&2
        return 1
    }
    [ -f "$dockerd_init" ] || {
        echo "错误：未找到 dockerd init 脚本: $dockerd_init" >&2
        return 1
    }
    [ -f "$dockerd_sysctl" ] || {
        echo "错误：未找到 dockerd sysctl 文件: $dockerd_sysctl" >&2
        return 1
    }

    if [ "$dry_run" = "1" ]; then
        echo "[dry-run] dockerd Makefile DEPENDS will switch to nftables-default compatible set"
        echo "[dry-run] dockerd Makefile vendored-version checks will tolerate missing installer files"
        if _docker_stack_init_supports_nftables_backend "$dockerd_init"; then
            echo "[dry-run] dockerd firewall_backend will be forced to nftables"
        else
            echo "[dry-run] dockerd.init lacks nftables backend support and will be patched in-place"
            echo "[dry-run] dockerd firewall_backend will be forced to nftables after patch"
        fi
        if [ -n "$storage_driver" ]; then
            echo "[dry-run] dockerd storage_driver will be set to $storage_driver"
        fi
        echo "[dry-run] dockerd forwarding sysctls will be set to 1"
        docker_stack_sync_dockerman_nftables_compat "$build_dir" "1" || return 1
        return 0
    fi

    _docker_stack_update_dockerd_depends_block "$dockerd_makefile" || return 1
    _docker_stack_fix_dockerd_vendored_checks "$dockerd_makefile" || return 1

    _docker_stack_ensure_nftables_init_support "$dockerd_init" || return 1
    docker_stack_sync_dockerman_nftables_compat "$build_dir" "0" || return 1

    _docker_stack_set_or_append_dockerd_uci_option "$dockerd_config" "firewall_backend" "nftables" || return 1
    if [ -n "$storage_driver" ]; then
        _docker_stack_set_or_append_dockerd_uci_option "$dockerd_config" "storage_driver" "$storage_driver" || return 1
    fi
    _docker_stack_fix_dockerd_nftables_comment "$dockerd_config"
    echo "dockerd nftables 默认策略已应用。"

    _docker_stack_set_or_append_sysctl_value "$dockerd_sysctl" "net.ipv4.ip_forward" "1" || return 1
    _docker_stack_set_or_append_sysctl_value "$dockerd_sysctl" "net.ipv6.conf.all.forwarding" "1" || return 1
}
