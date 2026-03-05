#!/usr/bin/env bash

update_feeds() {
    local FEEDS_PATH="$BUILD_DIR/$FEEDS_CONF"
    if [[ -f "$BUILD_DIR/feeds.conf" ]]; then
        FEEDS_PATH="$BUILD_DIR/feeds.conf"
    fi
    sed -i '/^#/d' "$FEEDS_PATH"
    sed -i '/packages_ext/d' "$FEEDS_PATH"

    if ! grep -q "fichenx/openwrt-package" "$FEEDS_PATH"; then
        [ -z "$(tail -c 1 "$FEEDS_PATH")" ] || echo "" >>"$FEEDS_PATH"
        echo "src-git fichenx https://github.com/kenzok8/jell" >>"$FEEDS_PATH"
    fi

    if ! grep -q "openwrt-passwall" "$FEEDS_PATH"; then
        [ -z "$(tail -c 1 "$FEEDS_PATH")" ] || echo "" >>"$FEEDS_PATH"
        echo "src-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall;main" >>"$FEEDS_PATH"
    fi

    if ! grep -q "openwrt_bandix" "$BUILD_DIR/$FEEDS_CONF"; then
        [ -z "$(tail -c 1 "$BUILD_DIR/$FEEDS_CONF")" ] || echo "" >>"$BUILD_DIR/$FEEDS_CONF"
        echo 'src-git openwrt_bandix https://github.com/timsaya/openwrt-bandix.git;main' >>"$BUILD_DIR/$FEEDS_CONF"
    fi

    if ! grep -q "luci_app_bandix" "$BUILD_DIR/$FEEDS_CONF"; then
        [ -z "$(tail -c 1 "$BUILD_DIR/$FEEDS_CONF")" ] || echo "" >>"$BUILD_DIR/$FEEDS_CONF"
        echo 'src-git luci_app_bandix https://github.com/timsaya/luci-app-bandix.git;main' >>"$BUILD_DIR/$FEEDS_CONF"
    fi

    if [ ! -f "$BUILD_DIR/include/bpf.mk" ]; then
        touch "$BUILD_DIR/include/bpf.mk"
    fi

    ./scripts/feeds update -a
}

install_feeds() {
    ./scripts/feeds update -i
    for dir in $BUILD_DIR/feeds/*; do
        if [ -d "$dir" ] && [[ ! "$dir" == *.tmp ]] && [[ ! "$dir" == *.index ]] && [[ ! "$dir" == *.targetindex ]]; then
            if [[ $(basename "$dir") == "fichenx" ]]; then
                install_fichenx
                install_fullconenat
            elif [[ $(basename "$dir") == "passwall" ]]; then
                install_passwall
            else
                ./scripts/feeds install -f -ap $(basename "$dir")
            fi
        fi
    done
}
