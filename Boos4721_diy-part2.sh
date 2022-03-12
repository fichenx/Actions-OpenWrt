#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

#1. 修改默认IP
sed -i 's/10.10.10.1/192.168.123.1/g' package/base-files/files/bin/config_generate

#2. web登陆密码从boos修改为password)
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings
#sed -i '/mirrors.cloud.tencent.com/a sed -i \'s\/root:$1$WplwC1t5$HBAtVXABp7XbvVjG4193B.:18753:0:99999:7:::\/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::\/g\' \/etc\/shadow' openwrt/package/lean/default-settings/files/zzz-default-settings
sed -i 's/root:$1$WplwC1t5$HBAtVXABp7XbvVjG4193B.:18753:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' package/base-files/files/etc/shadow

#3.固件版本号添加个人标识和日期
sed -i "s/Openwrt /FICHEN($(date "+%Y-%m-%d"))@OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

#4.编译的固件文件名添加日期
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(shell date "+%Y%m%d-%H%M")-/g' include/image.mk
