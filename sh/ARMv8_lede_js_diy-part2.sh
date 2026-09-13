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

echo "开始 自定义（fichen） 配置……"
echo "========================="

#启用ccache编译器缓存，加速每日重复编译（仅作用于编译主机，不改变固件产物）
#CONFIG_CCACHE位于DEVEL菜单下，默认缓存目录为./.ccache（与工作流缓存路径一致）
sed -i '/^CONFIG_DEVEL=/d;/^CONFIG_CCACHE=/d' .config
echo 'CONFIG_DEVEL=y' >> .config
echo 'CONFIG_CCACHE=y' >> .config

function git_sparse_clone() {
  branch="$1" rurl="$2" && shift 2
  rootdir="$PWD"
  git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl temp_sparse || {
    echo "克隆仓库失败：$rurl"
    return 1
  }  
  cd temp_sparse || {
    echo "进入目录失败：temp_sparse"
    return 1
  }
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
git clone -b js https://github.com/papagaye744/luci-theme-design feeds/luci/themes/luci-theme-design

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
rm -rf feeds/packages/net/nps
git_sparse_clone master https://github.com/immortalwrt/packages net/nps && mv -n nps feeds/packages/net/nps
#cp -rf $GITHUB_WORKSPACE/res/nps feeds/packages/net/nps

#luci-app-nps（修改nps服务器允许域名）
sed -i 's/^server.datatype = "ipaddr"/--server.datatype = "ipaddr"/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po
sed -i 's/必须是 IPv4 地址/IPv4 地址或域名/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po

#添加luci-app-wechatpush(js版)
sed -i 's|CONFIG_PACKAGE_luci-app-serverchan=y|CONFIG_PACKAGE_luci-app-wechatpush=y|g' .config
rm -rf feeds/luci/applications/luci-app-wechatpush package/luci-app-serverchan
git clone -b master https://github.com/tty228/luci-app-wechatpush package/custom2/luci-app-wechatpush

#luci-app-bypass(lua版)
#git_sparse_clone master "https://github.com/kiddin9/openwrt-packages" "kiddin9" luci-app-bypass && mv -n luci-app-bypass package/luci-app-bypass
git_svn main https://github.com/fichenx/packages luci-app-bypass

#添加luci-app-npc(lua版)
git_svn master https://github.com/Hyy2001X/AutoBuild-Packages luci-app-npc

#使用官方最新samba4
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=4.19.4/g' feeds/packages/net/samba4/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=4026d93b866db198c8ca1685b0f5d52793f65c6e63cb364163af661fdff0968c/g' feeds/packages/net/samba4/Makefile
rm -rf feeds/packages/net/samba4
rm -rf feeds/packages/lang/perl
git_sparse_clone master https://github.com/openwrt/packages net/samba4 && mv -n samba4 feeds/packages/net/samba4
git_sparse_clone master https://github.com/openwrt/packages lang/perl && mv -n perl feeds/packages/lang/perl

#更换msd_lite为最新版（immortalwrt源）
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/msd_lite
#[ -e package/lean/default-settings/files/zzz-default-settings ] && git_sparse_clone master https://github.com/immortalwrt/packages net/msd_lite && mv -n msd_lite feeds/packages/net/msd_lite
##更换msd_lite源为修改版（可以反向代理）
#sed -i 's|PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=https://github.com/fichenx/msd_lite.git|g'  feeds/packages/net/msd_lite/Makefile
#sed -i 's|PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=2024-12-16|g'  feeds/packages/net/msd_lite/Makefile
#sed -i 's|PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=983f5c07527b0c87a6494db49eade57da3c516bf|g'  feeds/packages/net/msd_lite/Makefile
#sed -i 's|PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=11039120524d97a23ebf57f4ac494464cff6dd07a843c0b968ef818920361965|g'  feeds/packages/net/msd_lite/Makefile


#还原golang版本为1.20
#rm -rf feeds/packages/lang/golang
#svn export https://github.com/coolsnowwolf/packages/trunk/lang/golang feeds/packages/lang/golang

# 替换自带watchcat为https://github.com/gngpp/luci-app-watchcat-plus
rm -rf feeds/packages/utils/watchcat
#git_svn master https://github.com/openwrt/packages utils/watchcat
git_sparse_clone master https://github.com/openwrt/packages utils/watchcat && mv -n watchcat feeds/packages/utils/watchcat
# 替换watchcat为第三方luci(lua版luci)
git_svn main https://github.com/fichenx/packages luci-app-watchcat-plus

#删除lede自带uwsgi
rm -rf feeds/packages/net/uwsgi
#git_svn openwrt-23.05 https://github.com/openwrt/packages net/uwsgi
git_sparse_clone openwrt-23.05 https://github.com/openwrt/packages net/uwsgi && mv -n uwsgi feeds/packages/net/uwsgi

#更换miniupnpd为最新版（immortalwrt源）
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/miniupnpd
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn master https://github.com/immortalwrt/packages net/miniupnpd

#替换luci-app-socat为https://github.com/chenmozhijin/luci-app-socat(lua版)
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-socat
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn main https://github.com/chenmozhijin/luci-app-socat luci-app-socat

#更换luci-app-ikoolproxy为3.8.5-8(lua版luci)
#git_svn main https://github.com/ilxp/luci-app-ikoolproxy luci-app-ikoolproxy koolproxy
[ -e package/lean/default-settings/files/zzz-default-settings ] && git clone -b main https://github.com/ilxp/luci-app-ikoolproxy.git package/custom2/luci-app-ikoolproxy

#添加luci-app-lucky、lucky
mk_dir="feeds/fichenx/lucky/Makefile"
mk_lede_dir="feeds/packages/net/lucky/Makefile"
rm -rf feeds/luci/applications/luci-app-lucky feeds/packages/net/lucky
#git_svn main https://github.com/gdy666/luci-app-lucky luci-app-lucky lucky
git_sparse_clone main https://github.com/gdy666/luci-app-lucky luci-app-lucky && mv -n luci-app-lucky feeds/luci/applications/luci-app-lucky
git_sparse_clone main https://github.com/gdy666/luci-app-lucky lucky && mv -n lucky feeds/packages/net/lucky
##使用在线lucky万吉版本
#if [ -d "${mk_dir%/*}" ] && [ -f "$mk_dir" ]; then
#    sed -i 's|Linux_$(LUCKY_ARCH)|Linux_$(LUCKY_ARCH)_wanji|g' "$mk_dir"
#fi
#if [ -d "${mk_lede_dir%/*}" ] && [ -f "$mk_lede_dir" ]; then
#    sed -i 's|Linux_$(LUCKY_ARCH)|Linux_$(LUCKY_ARCH)_wanji|g' "$mk_lede_dir"
#fi
##使用本地lucky万吉版本
update_lucky() {
    local lucky_dir="feeds/packages/net/lucky"

    # 默认关闭lucky
    local lucky_conf="feeds/packages/net/lucky/files/luckyuci"
    if [ -f "$lucky_conf" ]; then
        sed -i "s/option enabled '1'/option enabled '0'/g" "$lucky_conf"
        sed -i "s/option logger '1'/option logger '0'/g" "$lucky_conf"
    fi

    # 从补丁文件名中提取版本号
    local version
    version=$(find "$GITHUB_WORKSPACE/res" -name "lucky_*.tar.gz" -printf "%f\n" | head -n 1 | sed -n 's/^lucky_\(.*\)_Linux.*$/\1/p')
    if [ -z "$version" ]; then
        echo "Warning: 未找到 lucky 补丁文件，跳过更新。" >&2
        return 0
    fi

    local makefile_path="feeds/packages/net/lucky/Makefile"
    if [ ! -f "$makefile_path" ]; then
        echo "Warning: lucky Makefile not found. Skipping." >&2
        return 0
    fi

    echo "正在更新 lucky Makefile..."
    # 使用本地补丁文件，而不是下载
    local patch_line="\\t[ -f \${GITHUB_WORKSPACE}/res/lucky_${version}_Linux_\$(LUCKY_ARCH)_wanji.tar.gz ] && install -Dm644 \${GITHUB_WORKSPACE}/res/lucky_${version}_Linux_\$(LUCKY_ARCH)_wanji.tar.gz \$(PKG_BUILD_DIR)/\$(PKG_NAME)_\$(PKG_VERSION)_Linux_\$(LUCKY_ARCH).tar.gz"
    # 确保 Build/Prepare 部分存在，然后在其后添加我们的行
    if grep -q "Build/Prepare" "$makefile_path"; then
        sed -i "/Build\\/Prepare/a\\$patch_line" "$makefile_path"
        # 删除任何现有的 wget 命令
        sed -i '/wget/d' "$makefile_path"
        echo "lucky Makefile 更新完成。"
    else
        echo "Warning: lucky Makefile 中未找到 'Build/Prepare'。跳过。" >&2
    fi
}
update_lucky

#升级feeds/packages/net/smartdns
rm -rf feeds/packages/net/smartdns
git_sparse_clone main https://github.com/fichenx/openwrt-package smartdns && mv -n smartdns feeds/packages/net/smartdns
#强制smartdns单线程编译
sed -i 's/^PKG_BUILD_PARALLEL:=1/PKG_BUILD_PARALLEL:=0/' feeds/packages/net/smartdns/Makefile

#删除fichenx feed中的dockerd、docker及依赖containerd、runc，使用packages feed(coolsnowwolf)默认版本
rm -rf feeds/fichenx/dockerd feeds/fichenx/docker feeds/fichenx/containerd feeds/fichenx/runc

#替换luci-app-timecontrol为gaobin89/luci-app-timecontrol
rm -rf feeds/luci/applications/luci-app-timecontrol
git_sparse_clone js https://github.com/gaobin89/luci-app-timecontrol luci-app-timecontrol && mv -n luci-app-timecontrol feeds/luci/applications/luci-app-timecontrol

#########修复编译错误#########

#修复odhcpd编译错误：GCC12对dhcpv6-ia.c的maybe-uninitialized误报被-Werror提升为错误
#error: '*(__int128 unsigned *)(&first_key[0])' may be used uninitialized
mkdir -p package/network/services/odhcpd/patches
cp -fv $GITHUB_WORKSPACE/patch/odhcpd/001-fix-gcc12-maybe-uninitialized-first_key.patch package/network/services/odhcpd/patches/

#修复icu编译错误：coolsnowwolf feed的icu72.1旧configure不兼容ccache包装的CC，
#误把ccache识别为clang后编译器链接测试失败（C compiler cannot create executables），
#参照openwrt官方icu新版Makefile，对icu目标侧configure改用不带ccache的编译器（幂等）
sed -i 's|CC="$(TARGET_CC)"|CC="$(TARGET_CC_NOCACHE)"|;s|CXX="$(TARGET_CXX)"|CXX="$(TARGET_CXX_NOCACHE)"|' feeds/packages/libs/icu/Makefile

#修复vim-fuller打包失败：coolsnowwolf feed的vim8.2 Makefile中，生成runtime目录的
#Build/Compile/vim-runtime被CONFIG_PACKAGE_vim-runtime/vim-help条件守卫，而vim-fuller/
#install的$(CP)依赖该目录；只选vim-fuller时目录未生成，报cannot stat .../vim82。
#将守卫改为恒真，使runtime无条件生成（不选vim-runtime包则不打入固件，幂等）
sed -i 's|ifneq ($(CONFIG_PACKAGE_vim-runtime)$(CONFIG_PACKAGE_vim-help),)|ifeq (y,y)|' feeds/packages/utils/vim/Makefile

#取消编译libnetwork，防止出现冲突：
# * check_data_file_clashes: Package libnetwork wants to install file /workdir/openwrt/build_dir/target-aarch64_generic_musl/root-armvirt/usr/bin/docker-proxy
#         But that file is already provided by package  * dockerd 
# * opkg_install_cmd: Cannot install package libnetwork.
sed -i 's|CONFIG_PACKAGE_libnetwork=y|# CONFIG_PACKAGE_libnetwork is not set|g' .config

# NaïveProxy
rm -rf package/naiveproxy
git_sparse_clone main https://github.com/fichenx/openwrt-package naiveproxy && mv -n naiveproxy package/naiveproxy

echo "========================="
echo " 自定义(fichen) 配置完成……"