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
sed -i 's/192.168.1.1/192.168.124.1/g' package/base-files/files/bin/config_generate

#2. web登陆密码从空修改为password
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' /etc/shadow

#3.固件版本号添加个人标识和日期
sed -i 's/\%D \%V \%C/FICHEN($(TZ=UTC-8 date "+%Y-%m-%d"))@\%D \%V \%C /g' package/base-files/files/etc/openwrt_release

#4.编译的固件文件名添加日期
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d-%H%M")-/g' include/image.mk

#5.修改wifi密码为空
#sed -i 's/set wireless.default_radio${devidx}.encryption=sae-mixed/set wireless.default_radio${devidx}.encryption=none/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
#sed -i 's/set wireless.default_radio${devidx}.key=1234567890//g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

#6.修改主机名
sed -i "s/set system.@system[-1].hostname='OpenWrt'/set system.@system[-1].hostname='Redmi-AX6'/g" package/base-files/files/bin/config_generate

#7.关闭虚拟网桥走 iptables
sed -i '/exit 0/i echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables' package/base-files/files/etc/rc.local
sed -i '/exit 0/i echo 0 > /proc/sys/net/bridge/bridge-nf-call-ip6tables' package/base-files/files/etc/rc.local
sed -i '/exit 0/i echo 0 > /proc/sys/net/bridge/bridge-nf-call-arptables' package/base-files/files/etc/rc.local
sed -i '/exit 0/i echo 0 > /proc/sys/net/bridge/bridge-nf-call-arptables' package/base-files/files/etc/rc.local
sed -i  '/exit 0/{x;p;x}' package/base-files/files/etc/rc.local
