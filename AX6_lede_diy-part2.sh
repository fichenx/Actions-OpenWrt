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
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate

#2. web登陆密码从password修改为空
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

#3.固件版本号添加个人标识和日期
sed -i "s/DISTRIB_DESCRIPTION='OpenWrt '/DISTRIB_DESCRIPTION='FICHEN(\$\(TZ=UTC-8 date +%Y-%m-%d\))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings

#4.编译的固件文件名添加日期
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d")-$(VERSION_DIST_SANITIZED)/g' include/image.mk

#5.更换lede源码中自带argon主题
rm -rf feeds/luci/themes/luci-theme-argon && git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon 

#6.添加自动挂载磁盘脚本
#mkdir -p files/etc/hotplug.d/block && wget -O files/etc/hotplug.d/block/30-usbmount https://raw.githubusercontent.com/ficheny/P3TERX_Actions-OpenWrt/main/files/etc/hotplug.d/block/30-usbmount && chmod 755 files/etc/hotplug.d/block/30-usbmount

#7.修改主机名
sed -i "s/hostname='OpenWrt'/hostname='Redmi-AX6'/g" package/base-files/files/bin/config_generate

#8.修改插件位置
sed -i '/sed -i "s\/services\/system\/g" \/usr\/lib\/lua\/luci\/controller\/cpufreq.lua/d'  package/lean/default-settings/files/zzz-default-settings
sed -i '/exit 0/i sed -i "s/services/system/g" /usr/lib/lua/luci/controller/cpufreq.lua'  package/lean/default-settings/files/zzz-default-settings

#9.禁止Turbo ACC 网络加速修改net.bridge.bridge-nf-call-iptables的值为1(修改为1后旁路由需开启ip动态伪装，影响下行带宽)。
#sed -i '/exit 0/i sed -i "s/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& return 0/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& return 1/g" /etc/init.d/qca-nss-ecm'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i sed -i "s/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& sysctl -w dev.nss.general.redirect=1/\\#[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& sysctl -w dev.nss.general.redirect=1/g" /etc/init.d/qca-nss-ecm'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i /etc/init.d/qca-nss-ecm disable' package/lean/default-settings/files/zzz-default-settings
