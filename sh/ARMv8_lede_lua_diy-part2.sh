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
function git_sparse_clone() {
  branch="$1" rurl="$2" && shift 2
  rootdir="$PWD"
  git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl temp_sparse
  #git clone -b $branch --single-branch --no-tags --depth 1 --filter=blob:none --no-checkout $rurl temp_sparse
  cd temp_sparse
  git sparse-checkout init --cone
  git sparse-checkout set $@
  pkg=`echo $@ | tr ' ' '\n' | rev | cut -d'/' -f 1 | rev | tr '\n' ' ' `
  #git checkout $branch -- $@
  [ -d ../package/custom ] && cd ../package/custom && rm -rf $pkg && cd "$rootdir"/temp_sparse
  mv -n $@ ../
  cd ..
  rm -rf temp_sparse
  }
  
function git_svn() {
  #branch="$1" rurl="$2" localdir="$3" && shift 3
  branch="$1" rurl="$2" && shift 2
  rootdir="$PWD"
  git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl temp_svn
  #git clone -b $branch --single-branch --no-tags --depth 1 --filter=blob:none --no-checkout $rurl temp_svn
  cd temp_svn
  git sparse-checkout init --cone
  git sparse-checkout set $@
  pkg=`echo $@ | tr ' ' '\n' | rev | cut -d'/' -f 1 | rev | tr '\n' ' ' `
  #git checkout $branch -- $@
  [ -d ../package/custom ] && cd ../package/custom && rm -rf $pkg && cd "$rootdir"/temp_svn
  mv -n $@ ../package/custom2/
  cd ..
  rm -rf temp_svn
  }
  
function merge_package(){
    branch=`echo $1 | rev | cut -d'/' -f 1 | rev`
    repo=`echo $2 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $3 | rev | cut -d'/' -f 1 | rev`
	rootdir="$PWD"
    # find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone -b $1 --depth=1 --single-branch $2
  [ -d package/custom ] && cd package/custom && rm -rf $3 && cd "$rootdir"
    mv $3 package/custom2/
    rm -rf $repo
}
rm -rf package/custom2; mkdir package/custom2


##########固件配置修改#########
# 修改默认IP
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate

# web登陆密码从password修改为空
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

#固件版本号添加个人标识和日期
#sed -i "s/DISTRIB_DESCRIPTION='OpenWrt '/DISTRIB_DESCRIPTION='FICHEN(\$\(TZ=UTC-8 date +%Y-%m-%d\))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings

#编译的固件文件名添加日期
#sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d-%H%M")-$(VERSION_DIST_SANITIZED)/g' include/image.mk


#修改主机名
#sed -i "s/hostname='OpenWrt'/hostname='phicomm-N1'/g" package/base-files/files/bin/config_generate

#禁用nginx，启用uhttpd
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/nginx disable' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/nginx stop' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/uhttpd enable' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/uhttpd start' package/lean/default-settings/files/zzz-default-settings

#添加关机选项（https://github.com/sirpdboy/luci-app-poweroffdevice）
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/poweroff.htm > ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_system/poweroff.htm 
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/system.lua > ./feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua
##########固件主题添加&修改#########

#更换lede源码中自带argon主题和design主题
rm -rf feeds/luci/themes/luci-theme-argon && git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-design && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-theme-design && mv -n luci-theme-design feeds/luci/themes/luci-theme-design
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-design-config && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-app-design-config && mv -n luci-theme-design feeds/luci/applications/luci-app-design-config

#####design主题导航栏设置######
#sed -i 's/shadowsocksr/openclash/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's|/cgi-bin/luci/admin/system/admin|/cgi-bin/luci/admin/docker/containers|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
sed -i 's|/cgi-bin/luci/admin/system/admin|/cgi-bin/luci/admin/docker/containers|g' feeds/luci/themes/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's/ssr.png/openclash.png/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm

#修改默认主题
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon-mod/root/etc/uci-defaults/90_luci-theme-argon
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-netgear/root/etc/uci-defaults/30_luci-theme-netgear
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/fichenx/luci-theme-opentomcat/files/30_luci-theme-opentomcat
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' package/luci-theme-opentomcat/files/30_luci-theme-opentomcat

sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-light/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-ssl-nginx/Makefile

sed -i 's/luci-theme-argon/luci-theme-design/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-argon/luci-theme-design/g' feeds/luci/collections/luci-light/Makefile
sed -i 's/luci-theme-argon/luci-theme-design/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-argon/luci-theme-design/g' feeds/luci/collections/luci-ssl-nginx/Makefile

##########添加&修改插件#########

# 晶晨宝盒
#sed -i "s|https.*/amlogic-s9xxx-openwrt|https://github.com/breakingbadboy/OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|http.*/library|https://github.com/breakingbadboy/OpenWrt/opt/kernel|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|s9xxx_lede|ARMv8|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

sed -i "s|https.*/OpenWrt|https://github.com/fichenx/Actions-OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_stable|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|ARMv8|ARMv8(lede_lua)|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

sed -i "s|https.*/OpenWrt|https://github.com/fichenx/Actions-OpenWrt|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_stable|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|ARMv8|ARMv8(lede_lua)|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic



#nps（修改nps源为yisier）
rm -rf feeds/packages/net/nps
git_sparse_clone master https://github.com/immortalwrt/packages net/nps && mv -n nps feeds/packages/net/nps
#cp -rf $GITHUB_WORKSPACE/backup/nps feeds/packages/net/nps
#sed -i 's/PKG_SOURCE_URL:=.*/PKG_SOURCE_URL:=https:\/\/codeload.github.com\/yisier\/nps\/tar.gz\/v$(PKG_VERSION)?/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.26.18/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=29da044262071a1fa53ce7169c6427ee4f12fc0ada60ef7fb52fabfd165afe91/g' feeds/packages/net/nps/Makefile
#luci-app-nps（修改nps服务器允许域名）
sed -i 's/^server.datatype = "ipaddr"/--server.datatype = "ipaddr"/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po
sed -i 's/必须是 IPv4 地址/IPv4 地址或域名/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po



#luci-app-serverchan
rm -rf feeds/luci/applications/luci-app-serverchan
#cp -af feeds/fichenx/luci-app-serverchan feeds/luci/applications/luci-app-serverchan
git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush package/custom2/luci-app-serverchan

#luci-app-bypass
#git_sparse_clone master "https://github.com/kiddin9/openwrt-packages" "kiddin9" luci-app-bypass && mv -n luci-app-bypass package/luci-app-bypass
git_svn main https://github.com/fichenx/packages luci-app-bypass

#luci-app-npc
git_svn master https://github.com/Hyy2001X/AutoBuild-Packages luci-app-npc

#使用官方最新samba4
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=4.19.4/g' feeds/packages/net/samba4/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=4026d93b866db198c8ca1685b0f5d52793f65c6e63cb364163af661fdff0968c/g' feeds/packages/net/samba4/Makefile
rm -rf feeds/packages/net/samba4
rm -rf feeds/packages/lang/perl
git_sparse_clone master https://github.com/openwrt/packages net/samba4 && mv -n samba4 feeds/packages/net/samba4
git_sparse_clone master https://github.com/openwrt/packages lang/perl && mv -n perl feeds/packages/lang/perl

#更换msd_lite为最新版（immortalwrt源）
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/msd_lite
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_sparse_clone master https://github.com/immortalwrt/packages net/msd_lite && mv -n msd_lite feeds/packages/net/msd_lite
#更换msd_lite源为修改版（可以反向代理）
sed -i 's|PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=https://github.com/fichenx/msd_lite.git|g'  feeds/packages/net/msd_lite/Makefile
sed -i 's|PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=2024-12-16|g'  feeds/packages/net/msd_lite/Makefile
sed -i 's|PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=983f5c07527b0c87a6494db49eade57da3c516bf|g'  feeds/packages/net/msd_lite/Makefile
sed -i 's|PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=11039120524d97a23ebf57f4ac494464cff6dd07a843c0b968ef818920361965|g'  feeds/packages/net/msd_lite/Makefile



# 替换自带watchcat为https://github.com/gngpp/luci-app-watchcat-plus
rm -rf feeds/packages/utils/watchcat
#git_svn master https://github.com/openwrt/packages utils/watchcat
git_sparse_clone master https://github.com/openwrt/packages utils/watchcat && mv -n watchcat feeds/packages/utils/watchcat
git_svn main https://github.com/fichenx/packages luci-app-watchcat-plus

#删除lede自带uwsgi
rm -rf feeds/packages/net/uwsgi
#git_svn openwrt-23.05 https://github.com/openwrt/packages net/uwsgi
git_sparse_clone openwrt-23.05 https://github.com/openwrt/packages net/uwsgi && mv -n uwsgi feeds/packages/net/uwsgi

#更换miniupnpd为最新版（immortalwrt源）
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/miniupnpd
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn master https://github.com/immortalwrt/packages net/miniupnpd

#替换luci-app-socat为https://github.com/chenmozhijin/luci-app-socat
rm -rf feeds/luci/applications/luci-app-socat
git_svn main https://github.com/chenmozhijin/luci-app-socat luci-app-socat

#更换luci-app-ikoolproxy为3.8.5-8
#git_svn ipk https://github.com/ilxp/luci-app-ikoolproxy luci-app-ikoolproxy koolproxy
git clone -b main https://github.com/ilxp/luci-app-ikoolproxy.git package/custom2/luci-app-ikoolproxy

#添加luci-app-lucky
rm -rf feeds/luci/applications/luci-app-lucky feeds/packages/net/lucky
git_svn main https://github.com/gdy666/luci-app-lucky luci-app-lucky lucky


#修改应用位置
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

#luci-app-nps（修改nps显示位置）
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-nps/luasrc/controller/nps.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-nps/luasrc/view/nps/nps_status.htm


#替换lucky_daji为本地lucky_wanji
local version=$(find "$GITHUB_WORKSPACE/patches" -name "lucky*" -printf "%f\n" | head -n 1 | awk -F'_' '{print $2}')
local mk_dir="feeds/fichenx/lucky/Makefile"
local mk_lede_dir="feeds/packages/net/lucky/Makefile"
if [ -d "${mk_dir%/*}" ] && [ -f "$mk_dir" ]; then
    sed -i '/Build\/Prepare/ a\	[ -f $(TOPDIR)/../patches/lucky_'${version}'_Linux_$(LUCKY_ARCH)_wanji.tar.gz ] && install -Dm644 $(TOPDIR)/../patches/lucky_'${version}'_Linux_$(LUCKY_ARCH)_wanji.tar.gz $(PKG_BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz' "$mk_dir"
    sed -i '/wget/d' "$mk_dir"
fi
if [ -d "${mk_lede_dir%/*}" ] && [ -f "$mk_lede_dir" ]; then
    sed -i '/Build\/Prepare/ a\	[ -f $(TOPDIR)/../patches/lucky_'${version}'_Linux_$(LUCKY_ARCH)_wanji.tar.gz ] && install -Dm644 $(TOPDIR)/../patches/lucky_'${version}'_Linux_$(LUCKY_ARCH)_wanji.tar.gz $(PKG_BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz' "$mk_lede_dir"
    sed -i '/wget/d' "$mk_lede_dir"
fi




#########修复编译错误#########

#取消编译libnetwork，防止出现冲突：
# * check_data_file_clashes: Package libnetwork wants to install file /workdir/openwrt/build_dir/target-aarch64_generic_musl/root-armvirt/usr/bin/docker-proxy
#         But that file is already provided by package  * dockerd 
# * opkg_install_cmd: Cannot install package libnetwork.
sed -i 's|CONFIG_PACKAGE_libnetwork=y|# CONFIG_PACKAGE_libnetwork is not set|g' .config

# frp
#编译错误，恢复frp为lede默认
#rm -rf feeds/packages/net/frp
#git_sparse_clone master https://github.com/coolsnowwolf/packages net/frp && mv -n frp feeds/packages/net/frp


##使用openwrt官方版elfutils
#rm -rf package/libs/elfutils
#git_svn main https://github.com/openwrt/openwrt package/libs/elfutils


##修复elfutils编译错误
#1、修复lede版elfutils0.188版编译错误
#sed -i "s|TARGET_CFLAGS += -D_GNU_SOURCE -Wno-unused-result -Wno-format-nonliteral|TARGET_CFLAGS += -D_GNU_SOURCE -Wno-unused-result -Wno-format-nonliteral -Wno-error=use-after-free|g" package/libs/elfutils/Makefile
#2、修复openwrt官方版elfutils0.191版elfutils编译错误
#sed -i "s|CONFIG_GCC_USE_VERSION_11|CONFIG_GCC_USE_VERSION_12|g" package/custom2/elfutils/Makefile

#修复breakings更新dnsproxy后的编译问题
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.73.3/g' feeds/packages/net/dnsproxy/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=9eb2b1e88e74d3a4237b50977aa52cd19ea1bb6c896535e7dd4b2df4d6aa469c/g' feeds/packages/net/dnsproxy/Makefile

rm -rf feeds/packages/net/dnsproxy
git_sparse_clone master https://github.com/coolsnowwolf/packages net/dnsproxy && mv -n dnsproxy feeds/packages/net/dnsproxy

#修复breakings替换python后的编译问题
#rm -rf feeds/packages/lang/python
#cp -rf $GITHUB_WORKSPACE/general/python feeds/packages/lang
rm -rf feeds/packages/lang/python
git_sparse_clone master https://github.com/coolsnowwolf/packages lang/python && mv -n python feeds/packages/lang/python

#修复breakings替换php8后的编译问题
rm -rf feeds/packages/lang/php8
git_sparse_clone master https://github.com/coolsnowwolf/packages lang/php8 && mv -n php8 feeds/packages/lang/php8

#修复breakings替换curl后的编译问题
rm -rf feeds/packages/net/curl
git_sparse_clone master https://github.com/coolsnowwolf/packages net/curl && mv -n curl feeds/packages/net/curl

#修复breakings替换boost后的编译问题
rm -rf feeds/packages/libs/boost
git_sparse_clone master https://github.com/coolsnowwolf/packages libs/boost && mv -n boost feeds/packages/libs/boost

#修复breakings替换bcoreutils后的编译警示（可编译通过）：
#make[3] -C feeds/packages/utils/coreutils compile
#WARNING: Makefile 'package/feeds/luci/luci-ssl-nginx/Makefile' has a dependency on 'nginx-mod-luci-ssl', which does not exist
rm -rf feeds/packages/utils/coreutils
git_sparse_clone master https://github.com/coolsnowwolf/packages utils/coreutils && mv -n coreutils feeds/packages/utils/coreutils

#修复breakings替换zlib后的编译问题
git_sparse_clone main https://github.com/openwrt/openwrt package/libs/zlib && mv -n zlib package/libs/zlib
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.3.1/g' tools/zlib/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23/g' tools/zlib/Makefile

#修复breakings替换golang后的编译问题
#rm -rf feeds/packages/lang/golang
#git_sparse_clone master https://github.com/coolsnowwolf/packages lang/golang && mv -n golang feeds/packages/lang/golang

#lua版取消编译rtp2httpd：
sed -i '/CONFIG_PACKAGE_luci-app-rtp2httpd=y/d' .config
sed -i '/CONFIG_PACKAGE_luci-i18n-rtp2httpd-en=y/d' .config
sed -i '/CONFIG_PACKAGE_luci-i18n-rtp2httpd-zh-cn=y/d' .config
sed -i '/CONFIG_PACKAGE_rtp2httpd=y/d' .config

#删除自带和breakingbadboy自定义版本的dockerd、docker及依赖containerd、runc，使用fichenx/openwrt-package、lede的源
rm -rf feeds/packages/utils/dockerd
git_sparse_clone main https://github.com/fichenx/openwrt-package dockerd && mv -n dockerd feeds/packages/utils/dockerd
rm -rf feeds/packages/utils/docker
git_sparse_clone main https://github.com/fichenx/openwrt-package docker && mv -n docker feeds/packages/utils/docker
rm -rf feeds/packages/utils/containerd
git_sparse_clone master https://github.com/coolsnowwolf/packages utils/containerd && mv -n containerd feeds/packages/utils/containerd
rm -rf feeds/packages/utils/runc
git_sparse_clone master https://github.com/coolsnowwolf/packages utils/runc && mv -n runc feeds/packages/utils/runc

# NaïveProxy
rm -rf package/naiveproxy
git_sparse_clone main https://github.com/fichenx/openwrt-package naiveproxy && mv -n naiveproxy package/naiveproxy

