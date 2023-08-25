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

#####自定义设置#####
#1. 修改默认IP
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate

#2. web登陆密码从password修改为空
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

#3.固件版本号添加个人标识和日期
#sed -i "s/DISTRIB_DESCRIPTION='OpenWrt '/DISTRIB_DESCRIPTION='FICHEN(\$\(TZ=UTC-8 date +%Y-%m-%d\))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings

#4.编译的固件文件名添加日期
#sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d-%H%M")-$(VERSION_DIST_SANITIZED)/g' include/image.mk

#5.更换lede源码中自带argon主题和design主题
rm -rf feeds/luci/themes/luci-theme-argon && git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-design && git clone --depth 1 https://github.com/gngpp/luci-theme-design feeds/luci/themes/luci-theme-design
rm -rf feeds/luci/applications/luci-app-design-config && git clone --depth 1 https://github.com/gngpp/luci-app-design-config feeds/luci/applications/luci-app-design-config

#7.修改主机名
#sed -i "s/hostname='OpenWrt'/hostname='phicomm-N1'/g" package/base-files/files/bin/config_generate

# 晶晨宝盒
#sed -i "s|https.*/amlogic-s9xxx-openwrt|https://github.com/breakings/OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|http.*/library|https://github.com/breakings/OpenWrt/opt/kernel|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|s9xxx_lede|ARMv8|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

sed -i "s|https.*/OpenWrt|https://github.com/fichenx/Actions-OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakings/OpenWrt/opt/kernel|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|ARMv8|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

sed -i "s|https.*/OpenWrt|https://github.com/fichenx/Actions-OpenWrt|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakings/OpenWrt/opt/kernel|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|ARMv8|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

#####修改应用位置######
# luci-app-openvpn
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/controller/openvpn.lua
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/model/cbi/openvpn.lua
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/view/openvpn/pageswitch.htm

#luci-app-frpc
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-frpc/luasrc/controller/frp.lua
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-frpc/luasrc/model/cbi/frp/basic.lua
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-frpc/luasrc/model/cbi/frp/config.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-frpc/luasrc/view/frp/frp_status.htm

#luci-app-frps
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-frps/luasrc/controller/frps.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-frps/luasrc/view/frps/frps_status.htm

#nps（修改nps源为yisier）
sed -i 's/PKG_SOURCE_URL:=.*/PKG_SOURCE_URL:=https:\/\/codeload.github.com\/yisier\/nps\/tar.gz\/v$(PKG_VERSION)?/g' feeds/packages/net/nps/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.26.16.1/g' feeds/packages/net/nps/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=2fb8a19d2bd34d6a009f14d1c797169f09801eb814f57ebf10156ffdb78f2457/g' feeds/packages/net/nps/Makefile
#luci-app-nps（修改nps显示位置）
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-nps/luasrc/controller/nps.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-nps/luasrc/view/nps/nps_status.htm
#luci-app-nps（修改nps服务器允许域名）
sed -i 's/^server.datatype = "ipaddr"/--server.datatype = "ipaddr"/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po
sed -i 's/必须是 IPv4 地址/IPv4 地址或域名/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po

#####design主题导航栏设置######
#sed -i 's/shadowsocksr/openclash/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's|/cgi-bin/luci/admin/system/admin|/cgi-bin/luci/admin/docker/containers|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
sed -i 's|/cgi-bin/luci/admin/system/admin|/cgi-bin/luci/admin/docker/containers|g' feeds/luci/themes/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's/ssr.png/openclash.png/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm

#取消编译libnetwork，防止出现冲突：
# * check_data_file_clashes: Package libnetwork wants to install file /workdir/openwrt/build_dir/target-aarch64_generic_musl/root-armvirt/usr/bin/docker-proxy
#         But that file is already provided by package  * dockerd 
# * opkg_install_cmd: Cannot install package libnetwork.
#sed -i 's|CONFIG_PACKAGE_libnetwork=y|# CONFIG_PACKAGE_libnetwork is not set|g' .config

#修复linux-5.15.122缺少vxlan.ko的bug
#mkdir -p build_dir/target-aarch64_generic_musl/linux-armvirt_64/linux-5.15.122/drivers/net/vxlan
#cp -rf $GITHUB_WORKSPACE/general/armv8/build_dir/target-aarch64_generic_musl/linux-armvirt_64/linux-5.15.122/drivers/net/vxlan.ko build_dir/target-aarch64_generic_musl/linux-armvirt_64/linux-5.15.122/drivers/net/vxlan/

