#!/usr/bin/env bash

DOCKER_STACK_MODULE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DOCKER_STACK_REPO_ROOT=$(cd "$DOCKER_STACK_MODULE_DIR/../.." && pwd)
DOCKER_STACK_CANONICAL_DOCKERD_INIT="$DOCKER_STACK_REPO_ROOT/wrt_core/templates/dockerd.init"

DOCKER_STACK_COMPONENTS=(
    "runc"
    "containerd"
    "docker"
    "dockerd"
)

DOCKER_STACK_DOCKERD_MAKEFILE_REL="package/feeds/packages/dockerd/Makefile"
DOCKER_STACK_DOCKERD_CONFIG_REL="package/feeds/packages/dockerd/files/etc/config/dockerd"
DOCKER_STACK_DOCKERD_INIT_REL="package/feeds/packages/dockerd/files/dockerd.init"
DOCKER_STACK_DOCKERD_SYSCTL_REL="package/feeds/packages/dockerd/files/etc/sysctl.d/sysctl-br-netfilter-ip.conf"

_docker_stack_normalize_build_dir() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        echo "$path"
    else
        echo "$(pwd)/$path"
    fi
}

_docker_stack_validate_project() {
    local project_dir="$1"
    local component
    local mk_path

    if [ ! -d "$project_dir" ]; then
        echo "错误：OpenWrt 项目目录不存在: $project_dir" >&2
        return 1
    fi

    for component in "${DOCKER_STACK_COMPONENTS[@]}"; do
        mk_path="$project_dir/package/feeds/packages/$component/Makefile"
        if [ ! -f "$mk_path" ]; then
            echo "错误：缺少 $component Makefile: $mk_path" >&2
            return 1
        fi
    done

    return 0
}

_docker_stack_resolve_repo_from_makefile() {
    local mk_path="$1"
    local pkg_repo=""

    pkg_repo=$(grep -oE "^PKG_GIT_URL.*github.com(/[-_a-zA-Z0-9]{1,}){2}" "$mk_path" | awk -F"/" '{print $(NF - 1) "/" $NF}' || true)
    if [ -z "$pkg_repo" ]; then
        pkg_repo=$(grep -oE "^PKG_SOURCE_URL.*github.com(/[-_a-zA-Z0-9]{1,}){2}" "$mk_path" | awk -F"/" '{print $(NF - 1) "/" $NF}' || true)
    fi

    if [ -z "$pkg_repo" ]; then
        echo "错误：无法从 $mk_path 提取 GitHub 仓库路径" >&2
        return 1
    fi

    echo "$pkg_repo"
}

_docker_stack_resolve_target_tag() {
    local repo="$1"
    local branch="$2"
    local explicit_tag="$3"

    if [ -n "$explicit_tag" ]; then
        echo "$explicit_tag"
        return 0
    fi

    local target_tag
    if ! target_tag=$(curl -fsSL "https://api.github.com/repos/$repo/$branch" | jq -r '.[0] | .tag_name // .name'); then
        echo "错误：从 GitHub 获取 $repo 的 $branch 信息失败" >&2
        return 1
    fi

    if [ -z "$target_tag" ] || [ "$target_tag" = "null" ]; then
        echo "错误：无法解析 $repo 的目标版本标签" >&2
        return 1
    fi

    echo "$target_tag"
}

_docker_stack_update_dockerd_git_ref() {
    local mk_path="$1"
    local version_clean="$2"
    local major=""

    major=$(echo "$version_clean" | awk -F. '{print $1}')
    if [[ "$major" =~ ^[0-9]+$ ]] && [ "$major" -ge 29 ]; then
        sed -i 's|^PKG_GIT_REF:=.*|PKG_GIT_REF:=docker-v$(PKG_VERSION)|g' "$mk_path"
    else
        sed -i 's|^PKG_GIT_REF:=.*|PKG_GIT_REF:=v$(PKG_VERSION)|g' "$mk_path"
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
        /^  DEPENDS:=\$\(GO_ARCH_DEPENDS\) \\$/ {
            in_depends = 1
            replaced = 1

            print "  DEPENDS:=$(GO_ARCH_DEPENDS) \\" 
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
            print "    +uci-firewall \\" 
            print "    @!(mips||mips64||mipsel)"
            next
        }
        in_depends {
            if ($0 ~ /@!\(mips\|\|mips64\|\|mipsel\)/) {
                in_depends = 0
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

_docker_stack_init_supports_nftables_backend() {
    local dockerd_init="$1"

    grep -Fq 'if [ "${firewall_backend}" = "nftables" ]; then' "$dockerd_init" \
        && grep -Fq 'verify_nftables_prerequisites "${data_root}" || return 1' "$dockerd_init" \
        && grep -Fq 'nft add rule inet "${NFT_DOCKER_USER_TABLE}" "${NFT_DOCKER_USER_CHAIN}" iifname "${inbound}" oifname "${outbound}" reject' "$dockerd_init"
}

_docker_stack_ensure_nftables_init_support() {
    local dockerd_init="$1"
    local canonical_init="$DOCKER_STACK_CANONICAL_DOCKERD_INIT"

    if _docker_stack_init_supports_nftables_backend "$dockerd_init"; then
        return 0
    fi

    [ -f "$canonical_init" ] || {
        echo "错误：缺少 nftables 兼容 dockerd.init 模板: $canonical_init" >&2
        return 1
    }

    _docker_stack_init_supports_nftables_backend "$canonical_init" || {
        echo "错误：nftables 兼容 dockerd.init 模板内容不完整: $canonical_init" >&2
        return 1
    }

    if [ "$canonical_init" = "$dockerd_init" ]; then
        echo "错误：当前 dockerd.init 缺少 nftables backend 逻辑，且不存在可用外部模板" >&2
        return 1
    fi

    _docker_stack_warn "$dockerd_init 缺少 nftables backend 逻辑，使用 $canonical_init 进行同步"
    cp "$canonical_init" "$dockerd_init" || {
        echo "错误：同步 dockerd.init 到 nftables 版本失败" >&2
        return 1
    }

    _docker_stack_init_supports_nftables_backend "$dockerd_init" || {
        echo "错误：同步后 $dockerd_init 仍缺少 nftables backend 逻辑" >&2
        return 1
    }
}

_docker_stack_update_dockerd_nftables_defaults() {
    local build_dir="$1"
    local dry_run="$2"
    local storage_driver="$3"
    local dockerd_makefile="$build_dir/$DOCKER_STACK_DOCKERD_MAKEFILE_REL"
    local dockerd_config="$build_dir/$DOCKER_STACK_DOCKERD_CONFIG_REL"
    local dockerd_init="$build_dir/$DOCKER_STACK_DOCKERD_INIT_REL"
    local dockerd_sysctl="$build_dir/$DOCKER_STACK_DOCKERD_SYSCTL_REL"

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
            echo "[dry-run] dockerd.init lacks nftables backend support and will be synchronized from $DOCKER_STACK_CANONICAL_DOCKERD_INIT"
            echo "[dry-run] dockerd firewall_backend will be forced to nftables after sync"
        fi
        if [ -n "$storage_driver" ]; then
            echo "[dry-run] dockerd storage_driver will be set to $storage_driver"
        fi
        echo "[dry-run] dockerd forwarding sysctls will be set to 1"
        return 0
    fi

    _docker_stack_update_dockerd_depends_block "$dockerd_makefile" || return 1
    _docker_stack_fix_dockerd_vendored_checks "$dockerd_makefile" || return 1

    _docker_stack_ensure_nftables_init_support "$dockerd_init" || return 1

    _docker_stack_set_or_append_dockerd_uci_option "$dockerd_config" "firewall_backend" "nftables" || return 1
    if [ -n "$storage_driver" ]; then
        _docker_stack_set_or_append_dockerd_uci_option "$dockerd_config" "storage_driver" "$storage_driver" || return 1
    fi
    _docker_stack_fix_dockerd_nftables_comment "$dockerd_config"
    echo "dockerd nftables 默认策略已应用。"

    _docker_stack_set_or_append_sysctl_value "$dockerd_sysctl" "net.ipv4.ip_forward" "1" || return 1
    _docker_stack_set_or_append_sysctl_value "$dockerd_sysctl" "net.ipv6.conf.all.forwarding" "1" || return 1
}

_docker_stack_resolve_short_commit() {
    local mk_path="$1"
    local version_clean="$2"
    local pkg_git_url=""
    local pkg_git_ref=""

    pkg_git_url=$(awk -F"=" '/^PKG_GIT_URL:=/ {print $NF}' "$mk_path")
    pkg_git_ref=$(awk -F"=" '/^PKG_GIT_REF:=/ {print $NF}' "$mk_path")

    if [ -z "$pkg_git_url" ] || [ -z "$pkg_git_ref" ]; then
        echo "错误：$mk_path 缺少 PKG_GIT_URL 或 PKG_GIT_REF，无法更新 PKG_GIT_SHORT_COMMIT" >&2
        return 1
    fi

    local pkg_git_ref_resolved=""
    local pkg_git_ref_tag=""
    pkg_git_ref_resolved=$(echo "$pkg_git_ref" | sed "s/\$(PKG_VERSION)/$version_clean/g; s/\${PKG_VERSION}/$version_clean/g")
    pkg_git_ref_tag="${pkg_git_ref_resolved#refs/tags/}"

    local remote_url=""
    if [[ "$pkg_git_url" = http* ]]; then
        remote_url="$pkg_git_url"
    else
        remote_url="https://$pkg_git_url"
    fi

    local ls_remote_output=""
    ls_remote_output=$(git ls-remote "$remote_url" "refs/tags/${pkg_git_ref_tag}" "refs/tags/${pkg_git_ref_tag}^{}" 2>/dev/null || true)

    local commit_sha=""
    commit_sha=$(echo "$ls_remote_output" | awk '/\^\{\}$/ {print $1; exit}')
    if [ -z "$commit_sha" ]; then
        commit_sha=$(echo "$ls_remote_output" | awk 'NR==1{print $1}')
    fi
    if [ -z "$commit_sha" ]; then
        commit_sha=$(git ls-remote "$remote_url" "${pkg_git_ref_resolved}^{}" 2>/dev/null | awk 'NR==1{print $1}')
    fi
    if [ -z "$commit_sha" ]; then
        commit_sha=$(git ls-remote "$remote_url" "$pkg_git_ref_resolved" 2>/dev/null | awk 'NR==1{print $1}')
    fi

    if [ -z "$commit_sha" ]; then
        echo "错误：无法从 $remote_url 获取 $pkg_git_ref_resolved 的提交哈希" >&2
        return 1
    fi

    echo "$commit_sha" | cut -c1-7
}

_docker_stack_compute_package_hash() {
    local mk_path="$1"
    local version_clean="$2"

    local pkg_name=""
    local pkg_source=""
    local pkg_source_url=""
    local pkg_git_url=""
    local pkg_git_ref=""

    pkg_name=$(awk -F"=" '/^PKG_NAME:=/ {print $NF}' "$mk_path" | grep -oE "[-_:/\$\(\)\?\.a-zA-Z0-9]{1,}")
    pkg_source=$(awk -F"=" '/^PKG_SOURCE:=/ {print $NF}' "$mk_path" | grep -oE "[-_:/\$\(\)\?\.a-zA-Z0-9]{1,}")
    pkg_source_url=$(awk -F"=" '/^PKG_SOURCE_URL:=/ {print $NF}' "$mk_path" | grep -oE "[-_:/\$\(\)\{\}\?\.a-zA-Z0-9]{1,}")
    pkg_git_url=$(awk -F"=" '/^PKG_GIT_URL:=/ {print $NF}' "$mk_path")
    pkg_git_ref=$(awk -F"=" '/^PKG_GIT_REF:=/ {print $NF}' "$mk_path")

    pkg_source_url=${pkg_source_url//\$\(PKG_GIT_URL\)/$pkg_git_url}
    pkg_source_url=${pkg_source_url//\$\(PKG_GIT_REF\)/$pkg_git_ref}
    pkg_source_url=${pkg_source_url//\$\(PKG_NAME\)/$pkg_name}
    pkg_source_url=$(echo "$pkg_source_url" | sed "s/\${PKG_VERSION}/$version_clean/g; s/\$(PKG_VERSION)/$version_clean/g")

    pkg_source=${pkg_source//\$\(PKG_NAME\)/$pkg_name}
    pkg_source=${pkg_source//\$\(PKG_VERSION\)/$version_clean}

    local pkg_hash=""
    if ! pkg_hash=$(curl -fsSL "$pkg_source_url$pkg_source" | sha256sum | cut -b -64); then
        echo "错误：从 $pkg_source_url$pkg_source 获取软件包哈希失败" >&2
        return 1
    fi

    echo "$pkg_hash"
}

_docker_stack_update_component() {
    local component="$1"
    local mk_path="$2"
    local branch="$3"
    local explicit_tag="$4"
    local dry_run="$5"

    if [ ! -f "$mk_path" ]; then
        echo "错误：未找到 $component Makefile: $mk_path" >&2
        return 1
    fi

    local repo=""
    repo=$(_docker_stack_resolve_repo_from_makefile "$mk_path")

    local target_tag=""
    target_tag=$(_docker_stack_resolve_target_tag "$repo" "$branch" "$explicit_tag")

    local version_clean="${target_tag#v}"

    if [ "$dry_run" = "1" ]; then
        if [ "$component" = "dockerd" ]; then
            local major=""
            major=$(echo "$version_clean" | awk -F. '{print $1}')
            if [[ "$major" =~ ^[0-9]+$ ]] && [ "$major" -ge 29 ]; then
                echo "[dry-run] dockerd will use PKG_GIT_REF:=docker-v\$(PKG_VERSION)"
            else
                echo "[dry-run] dockerd will use PKG_GIT_REF:=v\$(PKG_VERSION)"
            fi
        fi
        echo "[dry-run] $component -> $target_tag ($mk_path)"
        return 0
    fi

    if [ "$component" = "dockerd" ]; then
        _docker_stack_update_dockerd_git_ref "$mk_path" "$version_clean"
    fi

    if grep -q '^PKG_GIT_SHORT_COMMIT:=' "$mk_path"; then
        local short_commit=""
        short_commit=$(_docker_stack_resolve_short_commit "$mk_path" "$version_clean")
        sed -i "s/^PKG_GIT_SHORT_COMMIT:=.*/PKG_GIT_SHORT_COMMIT:=$short_commit/g" "$mk_path"
    fi

    local pkg_hash=""
    pkg_hash=$(_docker_stack_compute_package_hash "$mk_path" "$version_clean")

    sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=$version_clean/g" "$mk_path"
    sed -i "s/^PKG_HASH:=.*/PKG_HASH:=$pkg_hash/g" "$mk_path"

    echo "更新 $component 到 $version_clean ($pkg_hash)"
}

update_docker_stack() {
    local build_dir="${BUILD_DIR:-}"
    local runc_version="${DOCKER_STACK_RUNC_VERSION:-v1.3.3}"
    local containerd_version="${DOCKER_STACK_CONTAINERD_VERSION:-v1.7.28}"
    local docker_version="${DOCKER_STACK_DOCKER_VERSION:-v29.3.1}"
    local dockerd_version="${DOCKER_STACK_DOCKERD_VERSION:-$docker_version}"
    local storage_driver="${DOCKER_STACK_STORAGE_DRIVER:-vfs}"
    local dry_run="${DOCKER_STACK_DRY_RUN:-0}"

    if [ -z "$build_dir" ]; then
        echo "错误：update_docker_stack 依赖 BUILD_DIR，请先在调用方设置 BUILD_DIR" >&2
        return 1
    fi

    if [ "$dry_run" != "0" ] && [ "$dry_run" != "1" ]; then
        echo "错误：DOCKER_STACK_DRY_RUN 仅支持 0 或 1，当前值: $dry_run" >&2
        return 1
    fi

    build_dir=$(_docker_stack_normalize_build_dir "$build_dir")
    _docker_stack_validate_project "$build_dir" || return 1

    echo "Docker 相关组件版本处理开始:"
    echo "  BUILD_DIR=$build_dir"
    echo "  runc=$runc_version"
    echo "  containerd=$containerd_version"
    echo "  docker=$docker_version"
    echo "  dockerd=$dockerd_version"
    echo "  storage_driver=$storage_driver"

    _docker_stack_update_component "runc" "$build_dir/package/feeds/packages/runc/Makefile" "releases" "$runc_version" "$dry_run" || return 1
    _docker_stack_update_component "containerd" "$build_dir/package/feeds/packages/containerd/Makefile" "releases" "$containerd_version" "$dry_run" || return 1
    _docker_stack_update_component "docker" "$build_dir/package/feeds/packages/docker/Makefile" "tags" "$docker_version" "$dry_run" || return 1
    _docker_stack_update_component "dockerd" "$build_dir/package/feeds/packages/dockerd/Makefile" "releases" "$dockerd_version" "$dry_run" || return 1
    _docker_stack_update_dockerd_nftables_defaults "$build_dir" "$dry_run" "$storage_driver" || return 1

    if [ "$dry_run" = "1" ]; then
        echo "dry-run 完成，未修改文件。"
    else
        echo "Docker 相关组件版本更新完成。"
    fi

    return 0
}
