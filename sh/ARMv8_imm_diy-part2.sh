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

echo "开始 自定义（ARMv8_imm_diy-part2） 配置……"
echo "========================="


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
  mv $@ ../
  cd ../
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
  #pkg=`echo $@ | tr ' ' '\n' | rev | cut -d'/' -f 1 | rev | tr '\n' ' ' `
  #git checkout $branch -- $@
  #[ -d ../package/custom ] && cd ../package/custom && rm -rf $pkg && cd "$rootdir"/temp_svn
  mv $@ ../package/custom/
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
    #[ -d package/custom ] && cd package/custom && rm -rf $3 && cd "$rootdir"
    mv $3 package/custom/
    rm -rf $repo
}

rm -rf package/custom2; mkdir package/custom2

##########固件配置修改#########
# 修改默认IP
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate

#修改主机名
#sed -i "s/hostname='OpenWrt'/hostname='phicomm-N1'/g" package/base-files/files/bin/config_generate

#web登陆密码从password修改为空
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

#固件版本号添加个人标识和日期
#sed -i "s/DISTRIB_DESCRIPTION='OpenWrt '/DISTRIB_DESCRIPTION='FICHEN(\$\(TZ=UTC-8 date +%Y-%m-%d\))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings

#编译的固件文件名添加日期
#sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d-%H%M")-$(VERSION_DIST_SANITIZED)/g' include/image.mk

#修改插件位置
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

#禁用nginx，启用uhttpd
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/nginx disable' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/nginx stop' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/uhttpd enable' package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i '/exit 0/i /etc/init.d/uhttpd start' package/lean/default-settings/files/zzz-default-settings



##########固件主题添加&修改#########
#更换lede源码中自带argon主题和design主题（jS版）
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-argon feeds/fichenx/luci-theme-argon && git clone https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-design && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-theme-design && mv -n luci-theme-design feeds/luci/themes/luci-theme-design
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-design-config && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-app-design-config && mv -n luci-theme-design feeds/luci/applications/luci-app-design-config

#添加luci-theme-design(Js版)
rm -rf feeds/luci/themes/luci-theme-design
git clone -b js https://github.com/papagaye744/luci-theme-design package/luci-theme-design

#修改默认主题
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon-mod/root/etc/uci-defaults/90_luci-theme-argon
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-netgear/root/etc/uci-defaults/30_luci-theme-netgear
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/fichenx/luci-theme-opentomcat/files/30_luci-theme-opentomcat
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' package/luci-theme-opentomcat/files/30_luci-theme-opentomcat
#sed -i 's|luci-theme-bootstrap|luci-theme-design|g' feeds/luci/collections/luci/Makefile

sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-light/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-ssl-nginx/Makefile

#####design主题导航栏设置######
#sed -i 's/shadowsocksr/openclash/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's|/cgi-bin/luci/admin/system/admin|/cgi-bin/luci/admin/docker/containers|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
sed -i 's|/cgi-bin/luci/admin/system/admin|/cgi-bin/luci/admin/docker/containers|g' feeds/luci/themes/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's/ssr.png/openclash.png/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm


##########添加&修改插件#########


#添加turboacc
#curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh
sed -i '/^CONFIG_PACKAGE_luci-app-turboacc=y$/d' .config

# 晶晨宝盒修改默认配置
#sed -i "s|https.*/amlogic-s9xxx-openwrt|https://github.com/breakingbadboy/OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|http.*/library|https://github.com/breakingbadboy/OpenWrt/opt/kernel|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|s9xxx_lede|ARMv8|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

sed -i "s|https.*/OpenWrt|https://github.com/fichenx/Actions-OpenWrt|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_stable|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|ARMv8|ARMv8(lede_js)|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

sed -i "s|https.*/OpenWrt|https://github.com/fichenx/Actions-OpenWrt|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakingbadboy/OpenWrt/releases/tag/kernel_stable|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|ARMv8|ARMv8(lede_js)|g" feeds/fichenx/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic



#nps（修改nps源为yisier）
#rm -rf feeds/packages/net/nps
#git_sparse_clone master https://github.com/immortalwrt/packages net/nps && mv -n nps feeds/packages/net/nps
#cp -rf $GITHUB_WORKSPACE/backup/nps feeds/packages/net/nps
#sed -i 's/PKG_SOURCE_URL:=.*/PKG_SOURCE_URL:=https:\/\/codeload.github.com\/yisier\/nps\/tar.gz\/v$(PKG_VERSION)?/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.26.18/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=29da044262071a1fa53ce7169c6427ee4f12fc0ada60ef7fb52fabfd165afe91/g' feeds/packages/net/nps/Makefile

#luci-app-nps（修改nps服务器允许域名）
sed -i 's/^server.datatype = "ipaddr"/--server.datatype = "ipaddr"/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po
sed -i 's/必须是 IPv4 地址/IPv4 地址或域名/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po




#添加luci-app-wechatpush(js版)
sed -i 's|CONFIG_PACKAGE_luci-app-serverchan=y|CONFIG_PACKAGE_luci-app-wechatpush=y|g' .config
rm -rf feeds/luci/applications/luci-app-wechatpush package/luci-app-serverchan
git clone -b master https://github.com/tty228/luci-app-wechatpush package/custom2/luci-app-wechatpush


#更换msd_lite源为修改版（可以反向代理）
sed -i 's|PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=https://github.com/fichenx/msd_lite.git|g'  feeds/packages/net/msd_lite/Makefile
sed -i 's|PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=2024-12-16|g'  feeds/packages/net/msd_lite/Makefile
sed -i 's|PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=983f5c07527b0c87a6494db49eade57da3c516bf|g'  feeds/packages/net/msd_lite/Makefile
sed -i 's|PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=11039120524d97a23ebf57f4ac494464cff6dd07a843c0b968ef818920361965|g'  feeds/packages/net/msd_lite/Makefile

#添加luci-app-lucky、lucky
mk_dir="feeds/fichenx/lucky/Makefile"
mk_lede_dir="feeds/packages/net/lucky/Makefile"
rm -rf feeds/luci/applications/luci-app-lucky feeds/packages/net/lucky
#git_svn main https://github.com/gdy666/luci-app-lucky luci-app-lucky lucky
git_sparse_clone main https://github.com/gdy666/luci-app-lucky luci-app-lucky && mv -n luci-app-lucky feeds/luci/applications/luci-app-lucky
git_sparse_clone main https://github.com/gdy666/luci-app-lucky lucky && mv -n lucky feeds/packages/net/lucky
if [ -d "${mk_dir%/*}" ] && [ -f "$mk_dir" ]; then
    sed -i 's|Linux_$(LUCKY_ARCH)|Linux_$(LUCKY_ARCH)_wanji|g' "$mk_dir"
fi
if [ -d "${mk_lede_dir%/*}" ] && [ -f "$mk_lede_dir" ]; then
    sed -i 's|Linux_$(LUCKY_ARCH)|Linux_$(LUCKY_ARCH)_wanji|g' "$mk_lede_dir"
fi


#删除自带和breakingbadboy自定义版本的dockerd、docker及依赖containerd、runc，使用自定义docker版本
#rm -rf feeds/fichenx/dockerd feeds/fichenx/docker
rm -rf feeds/packages/utils/dockerd
git_sparse_clone main https://github.com/fichenx/openwrt-package dockerd && mv -n dockerd feeds/packages/utils/dockerd
#git_sparse_clone master https://github.com/coolsnowwolf/packages utils/dockerd && mv -n dockerd feeds/packages/utils/dockerd
rm -rf feeds/packages/utils/docker
git_sparse_clone main https://github.com/fichenx/openwrt-package docker && mv -n docker feeds/packages/utils/docker
#git_sparse_clone master https://github.com/coolsnowwolf/packages utils/docker && mv -n docker feeds/packages/utils/docker
#rm -rf feeds/packages/utils/containerd
#git_sparse_clone master https://github.com/coolsnowwolf/packages utils/containerd && mv -n containerd feeds/packages/utils/containerd
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=2.2.0/g' feeds/packages/utils/containerd/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=86e7a268fc73f5332522baef86082c1d6c17986e2957a9ad842ead35d1080fca/g' feeds/packages/utils/containerd/Makefile
sed -i 's/containerd-shim,containerd-shim-runc-v1,//g' feeds/packages/utils/containerd/Makefile
#rm -rf feeds/packages/utils/runc
#git_sparse_clone master https://github.com/coolsnowwolf/packages utils/runc && mv -n runc feeds/packages/utils/runc
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.3.4/g' feeds/packages/utils/runc/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=a9f9646c4c8990239f6462b408b22d9aa40ba0473a9fc642b9d6576126495eee/g' feeds/packages/utils/runc/Makefile

#########修复编译错误#########

##修复elfutils编译错误
#1、修复lede版elfutils0.188版编译错误
#sed -i "s|TARGET_CFLAGS += -D_GNU_SOURCE -Wno-unused-result -Wno-format-nonliteral|TARGET_CFLAGS += -D_GNU_SOURCE -Wno-unused-result -Wno-format-nonliteral -Wno-error=use-after-free|g" package/libs/elfutils/Makefile
##2、修复替换后openwrt官方版elfutils0.191版elfutils编译错误
#sed -i "s|CONFIG_GCC_USE_VERSION_11|CONFIG_GCC_USE_VERSION_12|g" package/custom2/elfutils/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.194/g' package/libs/elfutils/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=09e2ff033d39baa8b388a2d7fbc5390bfde99ae3b7c67c7daaf7433fbcf0f01e/g' package/libs/elfutils/Makefile
sed -i \
  -e 's/PKG_VERSION:=.*/PKG_VERSION:=0.194/' \
  -e 's/PKG_HASH:=.*/PKG_HASH:=09e2ff033d39baa8b388a2d7fbc5390bfde99ae3b7c67c7daaf7433fbcf0f01e/' \
  tools/elfutils/Makefile
rm -rf tools/elfutils/patches/012-backport-mips-support-readelf.patch


#取消编译libnetwork，防止出现冲突：
# * check_data_file_clashes: Package libnetwork wants to install file /workdir/openwrt/build_dir/target-aarch64_generic_musl/root-armvirt/usr/bin/docker-proxy
#         But that file is already provided by package  * dockerd 
# * opkg_install_cmd: Cannot install package libnetwork.
sed -i 's|CONFIG_PACKAGE_libnetwork=y|# CONFIG_PACKAGE_libnetwork is not set|g' .config


# NaïveProxy
#rm -rf package/naiveproxy
#git_sparse_clone main https://github.com/fichenx/openwrt-package naiveproxy && mv -n naiveproxy package/naiveproxy

#给n2n添加补丁文件，修正前两行语法顺序颠倒的错误
cp -rf $GITHUB_WORKSPACE/backup/001-fix-cmake-compatibility.patch $GITHUB_WORKSPACE/openwrt/feeds/packages/net/n2n/patches/

echo "========================="
echo " 自定义(ARMv8_imm_diy-part2) 配置完成……"