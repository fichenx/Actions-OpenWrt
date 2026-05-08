#!/usr/bin/env bash

get_feeds_path() {
    local feeds_path="$BUILD_DIR/$FEEDS_CONF"
    if [[ -f "$BUILD_DIR/feeds.conf" ]]; then
        feeds_path="$BUILD_DIR/feeds.conf"
    fi
    printf '%s\n' "$feeds_path"
}

append_feed_if_missing() {
    local feeds_path="$1"
    local match_pattern="$2"
    local feed_entry="$3"

    if ! grep -q "$match_pattern" "$feeds_path"; then
        [ -z "$(tail -c 1 "$feeds_path")" ] || echo "" >>"$feeds_path"
        echo "$feed_entry" >>"$feeds_path"
    fi
}

update_feeds() {
    local FEEDS_PATH
    FEEDS_PATH=$(get_feeds_path)
    sed -i '/^#/d' "$FEEDS_PATH"
    sed -i '/packages_ext/d' "$FEEDS_PATH"

    append_feed_if_missing "$FEEDS_PATH" "openwrt-passwall" "src-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall;main"
    append_feed_if_missing "$FEEDS_PATH" "openwrt_bandix" "src-git openwrt_bandix https://github.com/timsaya/openwrt-bandix.git;main"
    append_feed_if_missing "$FEEDS_PATH" "luci_app_bandix" "src-git luci_app_bandix https://github.com/timsaya/luci-app-bandix.git;main"
    append_feed_if_missing "$FEEDS_PATH" "nikki" "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main"

    if [ ! -f "$BUILD_DIR/include/bpf.mk" ]; then
        touch "$BUILD_DIR/include/bpf.mk"
    fi

    ./scripts/feeds update -a
}

install_feeds() {
    ./scripts/feeds update -i
    for dir in $BUILD_DIR/feeds/*; do
        if [ -d "$dir" ] && [[ ! "$dir" == *.tmp ]] && [[ ! "$dir" == *.index ]] && [[ ! "$dir" == *.targetindex ]]; then
            local feed_name
            feed_name=$(basename "$dir")
            if [[ "$feed_name" == "passwall" ]]; then
                install_passwall
            elif [[ "$feed_name" == "nikki" ]]; then
                install_nikki
            else
                ./scripts/feeds install -f -ap "$feed_name"
            fi
        fi
    done
}
