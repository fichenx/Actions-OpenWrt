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


#1. 修改默认IP
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate

#3.固件版本号添加个人标识和日期
sed -i "s/DISTRIB_DESCRIPTION='OpenWrt '/DISTRIB_DESCRIPTION='FICHEN(\$\(TZ=UTC-8 date +%Y-%m-%d\))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings

#4.编译的固件文件名添加日期
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d-%H%M")-$(VERSION_DIST_SANITIZED)/g' include/image.mk

#5.更换lede源码中自带argon主题
rm -rf feeds/luci/themes/luci-theme-argon && git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon

#7.修改主机名
sed -i "s/hostname='OpenWrt'/hostname='phicomm-N1'/g" package/base-files/files/bin/config_generate

###################################################################
# autocore
sed -i 's/DEPENDS:=@(.*/DEPENDS:=@(TARGET_bcm27xx||TARGET_bcm53xx||TARGET_ipq40xx||TARGET_ipq806x||TARGET_ipq807x||TARGET_mvebu||TARGET_rockchip||TARGET_armvirt) \\/g' package/lean/autocore/Makefile

#themes
svn co https://github.com/rosywrt/luci-theme-rosy/trunk/luci-theme-rosy package/luci-theme-rosy
#git clone https://github.com/rosywrt/luci-theme-purple.git package/luci-theme-purple
#git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat
svn co https://github.com/Leo-Jo-My/luci-theme-opentomcat/trunk package/luci-theme-opentomcat
svn co https://github.com/Leo-Jo-My/luci-theme-opentomato/trunk package/luci-theme-opentomato
#svn co https://github.com/sirpdboy/luci-theme-opentopd/trunk package/luci-theme-opentopd
#git clone https://github.com/kevin-morgan/luci-theme-argon-dark.git package/luci-theme-argon-dark
#svn co https://github.com/kevin-morgan/luci-theme-argon-dark/trunk package/luci-theme-argon-dark
#svn co https://github.com/openwrt/luci/trunk/themes/luci-theme-openwrt-2020 package/luci-theme-openwrt-2020
svn co https://github.com/thinktip/luci-theme-neobird/trunk package/luci-theme-neobird

# fix nginx-ssl-util error (do not use fallthrough attribute)
#rm feeds/packages/net/nginx-util/src/nginx-ssl-util.hpp
#wget -P feeds/packages/net/nginx-util/src https://raw.githubusercontent.com/openwrt/packages/master/net/nginx-util/src/nginx-ssl-util.hpp


# 晶晨宝盒
sed -i "s|https.*/amlogic-s9xxx-openwrt|https://github.com/fichenx/Actions-OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|http.*/library|https://github.com/breakings/OpenWrt/opt/kernel|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|s9xxx_lede|ARMv8|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic


# docker-compose
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=2.10.0/g' feeds/packages/utils/docker-compose/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=981282ee5cc454a69f1d56845efea5645ff90295b9198decfc62674a9e286baa/g' feeds/packages/utils/docker-compose/Makefile

# luci-app-openvpn
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/controller/openvpn.lua
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/model/cbi/openvpn.lua
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/view/openvpn/pageswitch.htm

#fix ntfs3 generating empty package
#sed -i 's/KCONFIG:=CONFIG_NLS_DEFAULT="utf8"/#KCONFIG:=CONFIG_NLS_DEFAULT="utf8"/'g package/lean/ntfs3/Makefile
#sed -i 's/mount -t ntfs3 -o nls=utf8 "$@"/mount -t ntfs3 "$@"/g'  package/lean/ntfs3-mount/files/mount.ntfs
sed -i 's/DEPENDS:=.*/DEPENDS:=@(LINUX_5_4||LINUX_5_10) +kmod-nls-utf8/g' package/lean/ntfs3-oot/Makefile

# fix kernel modules missing nfs_ssc.ko
##cp -f $GITHUB_WORKSPACE/general/fs.mk package/kernel/linux/modules
##rm -f target/linux/generic/backport-5.10/350-v5.12-NFSv4_2-SSC-helper-should-use-its-own-config.patch
##rm -f target/linux/generic/backport-5.10/351-v5.13-NFSv4_2-Remove-ifdef-CONFIG_NFSD-from-client-SSC.patch
##cp -f $GITHUB_WORKSPACE/general/01-export-nfs_ssc.patch target/linux/generic/backport-5.15
cp -f $GITHUB_WORKSPACE/general/003-add-module_supported_device-macro.patch target/linux/generic/backport-5.15
#cp -f $GITHUB_WORKSPACE/general/crypto.mk package/kernel/linux/modules
#cp -f $GITHUB_WORKSPACE/general/netsupport.mk package/kernel/linux/modules
cp -f $GITHUB_WORKSPACE/general/netdevices.mk package/kernel/linux/modules
#cp -f $GITHUB_WORKSPACE/general/651-rt2x00-driver-compile-with-kernel-5.15.patch package/kernel/mac80211/patches/rt2x00
#rm -f target/linux/generic/pending-5.10/701-net-ethernet-mtk_eth_soc-add-ipv6-flow-offloading-support.patch
#rm -f target/linux/generic/hack-5.10/220-gc_sections.patch
#cp -f $GITHUB_WORKSPACE/general/220-arm-gc_sections.patch target/linux/generic/hack-5.10
#cp -f $GITHUB_WORKSPACE/general/781-dsa-register-every-port-with-of_platform.patch target/linux/generic/hack-5.10
#cp -f $GITHUB_WORKSPACE/general/900-regulator-consumer-Add-missing-stubs-to-regulator-co.patch target/linux/generic/backport-5.10
#rm -f package/kernel/mac80211/patches/brcm/999-backport-to-linux-5.18.patch


# replace banner
cp -f $GITHUB_WORKSPACE/general/openwrt_banner package/base-files/files/etc/banner

# boost
rm -rf feeds/packages/libs/boost
cp -r $GITHUB_WORKSPACE/general/boost feeds/packages/libs

# fix luci-theme-opentomcat dockerman icon missing
rm -f package/luci-theme-opentomcat/files/htdocs/fonts/advancedtomato.woff
cp $GITHUB_WORKSPACE/general/advancedtomato.woff package/luci-theme-opentomcat/files/htdocs/fonts
sed -i 's/e025/e02c/g' package/luci-theme-opentomcat/files/htdocs/css/style.css
sed -i 's/66CC00/00b2ee/g' package/luci-theme-opentomcat/files/htdocs/css/style.css

# sqlite3
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=3380500/g' feeds/packages/libs/sqlite3/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=5af07de982ba658fd91a03170c945f99c971f6955bc79df3266544373e39869c/g' feeds/packages/libs/sqlite3/Makefile
#sed -i 's|PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=https://www.sqlite.org/2022/|g' feeds/packages/libs/sqlite3/Makefile
#sed -i '39d' feeds/packages/libs/sqlite3/Makefile
cp -rf $GITHUB_WORKSPACE/general/sqlite3 feeds/packages/libs

# perl
rm -rf feeds/packages/lang/perl
cp -rf $GITHUB_WORKSPACE/general/perl feeds/packages/lang

# zlib
rm -rf package/libs/zlib
svn co https://github.com/openwrt/openwrt/trunk/package/libs/zlib package/libs/zlib

# libnetfilter-conntrack
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.0.9/g' package/libs/libnetfilter-conntrack/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=67bd9df49fe34e8b82144f6dfb93b320f384a8ea59727e92ff8d18b5f4b579a8/g' package/libs/libnetfilter-conntrack/Makefile
cp -rf $GITHUB_WORKSPACE/general/libnetfilter-conntrack/patches package/libs/libnetfilter-conntrack

# util-linux
rm -rf package/utils/util-linux
cp -rf $GITHUB_WORKSPACE/general/util-linux package/utils

# lsof
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=4.95.0/g' feeds/packages/utils/lsof/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=e9faa0fbcc48638c1d1f143e93573ac43b65e76646150f83e24bd8c18786303c/g' feeds/packages/utils/lsof/Makefile

# nghttp2
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.47.0/g' feeds/packages/libs/nghttp2/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=68271951324554c34501b85190f22f2221056db69f493afc3bbac8e7be21e7cc/g' feeds/packages/libs/nghttp2/Makefile

# libiconv-full
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.17/g' package/libs/libiconv-full/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=8f74213b56238c85a50a5329f77e06198771e70dd9a739779f4c02f65d971313/g' package/libs/libiconv-full/Makefile

# sagernet-core
sed -i 's|$(LN) v2ray $(1)/usr/bin/xray|#$(LN) v2ray $(1)/usr/bin/xray|g' package/sagernet-core/Makefile
sed -i 's|CONFLICTS:=v2ray-core xray-core|#CONFLICTS:=v2ray-core xray-core|g' package/sagernet-core/Makefile

# bind
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=9.18.6/g' feeds/packages/net/bind/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=d43a0fed03c774d1685d203598218c0b7774a88fcc390a0170710d5feb7fbff1/g' feeds/packages/net/bind/Makefile

# libwebp
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.2.4/g' feeds/packages/libs/libwebp/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=7bf5a8a28cc69bcfa8cb214f2c3095703c6b73ac5fba4d5480c205331d9494df/g' feeds/packages/libs/libwebp/Makefile

# lighttpd
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.4.66/g' feeds/packages/net/lighttpd/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=47ac6e60271aa0196e65472d02d019556dc7c6d09df3b65df2c1ab6866348e3b/g' feeds/packages/net/lighttpd/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
