#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: lede_diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
BUILD_MODEL=$1

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
#echo 'src-git small8 https://github.com/kenzok8/small-package' >>feeds.conf.default
#echo 'src-git Boos4721 https://github.com/Boos4721/OpenWrt-Packages' >>feeds.conf.default


#echo 'src-git fichenx https://github.com/fichenx/openwrt-package' >>feeds.conf.default

# 删除注释行
sed -i '/^#/d' "feeds.conf.default"

# 检查并添加 fichenx/openwrt-package 源
if ! grep -q "fichenx/openwrt-package" "feeds.conf.default"; then
    # 确保文件以换行符结尾
    [ -z "$(tail -c 1 "feeds.conf.default")" ] || echo "" >>"feeds.conf.default"
    ##echo "src-git small8 https://github.com/kenzok8/small-package" >>"$BUILD_DIR/$FEEDS_CON
    echo "src-git fichenx https://github.com/fichenx/openwrt-package;js" >>"feeds.conf.default"
fi

# 根据编译的固件选择不同的软件源
if [[ "$BUILD_MODEL" == *"lede_lua"* ]]; then
# 使用sed删除$FEEDS_CONF文件中的";openwrt-23.05"字符串
sed -i 's/;openwrt-23.05//g' "feeds.conf.default"
sed -i 's/;js/;lua/g' "feeds.conf.default"
fi


