#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

#1. 修改默认IP
sed -i 's/10.10.10.1/192.168.124.1/g' openwrt/package/base-files/files/bin/config_generate

#2. web登陆密码从boos修改为password)
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings
#sed -i '/mirrors.cloud.tencent.com/a sed -i \'s\/root:$1$WplwC1t5$HBAtVXABp7XbvVjG4193B.:18753:0:99999:7:::\/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::\/g\' \/etc\/shadow' openwrt/package/lean/default-settings/files/zzz-default-settings
sed -i 's/root:$1$WplwC1t5$HBAtVXABp7XbvVjG4193B.:18753:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' openwrt/package/base-files/files/etc/shadow

#3.固件版本号添加个人标识和日期
sed -i "s/Openwrt /FICHEN $(TZ=UTC-8 date "+%Y-%m-%d")@OpenWrt /g" openwrt/package/lean/default-settings/files/zzz-default-settings

#4.编译的固件文件名添加日期
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(shell date +%Y%m%d-%H%M)-/g' openwrt/include/image.mk
