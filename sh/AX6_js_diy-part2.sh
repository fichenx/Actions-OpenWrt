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
# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

#修改默认IP
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate

# web登陆密码从password修改为空
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

#固件版本号添加个人标识和日期
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "s/DISTRIB_DESCRIPTION='.*LEDE '/DISTRIB_DESCRIPTION='FICHEN($(TZ=UTC-8 date +%Y.%m.%d))@LEDE '/g" package/lean/default-settings/files/zzz-default-settings
[ ! -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "/DISTRIB_DESCRIPTION='*'/d" package/base-files/files/etc/openwrt_release
[ ! -e package/lean/default-settings/files/zzz-default-settings ] && echo "DISTRIB_DESCRIPTION='FICHEN($(TZ=UTC-8 date +%Y.%m.%d))@immortalwrt '" >> package/base-files/files/etc/openwrt_release

#修改主机名
sed -i "s/hostname='OpenWrt'/hostname='Redmi-AX6'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='ImmortalWrt'/hostname='Redmi-AX6'/g" package/base-files/files/bin/config_generate

#编译的固件文件名添加日期
#sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d")-$(VERSION_DIST_SANITIZED)/g' include/image.mk


#添加自动挂载磁盘脚本
#mkdir -p files/etc/hotplug.d/block && wget -O files/etc/hotplug.d/block/30-usbmount https://raw.githubusercontent.com/ficheny/P3TERX_Actions-OpenWrt/main/files/etc/hotplug.d/block/30-usbmount && chmod 755 files/etc/hotplug.d/block/30-usbmount

#添加6.6内核选项
sed -i '/KERNEL_PATCHVER:=6.1/a KERNEL_TESTING_PATCHVER:=6.6' target/linux/qualcommax/

#添加autocore-arm为默认依赖
sed -i 's/automount/automount autocore-arm/g' target/linux/qualcommax/Makefile

#修改插件位置
#sed -i '/sed -i "s\/services\/system\/g" \/usr\/lib\/lua\/luci\/controller\/cpufreq.lua/d'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i sed -i "s/services/system/g" /usr/lib/lua/luci/controller/cpufreq.lua'  package/lean/default-settings/files/zzz-default-settings

#禁止Turbo ACC 网络加速修改net.bridge.bridge-nf-call-iptables的值为1(修改为1后旁路由需开启ip动态伪装，影响下行带宽)。
#sed -i '/exit 0/i sed -i "s/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& return 0/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& return 1/g" /etc/init.d/qca-nss-ecm'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i sed -i "s/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& sysctl -w dev.nss.general.redirect=1/\\#[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& sysctl -w dev.nss.general.redirect=1/g" /etc/init.d/qca-nss-ecm'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i /etc/init.d/qca-nss-ecm disable' package/lean/default-settings/files/zzz-default-settings

##########固件主题添加&修改#########

#更换lede源码中自带argon主题
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-argon feeds/fichenx/luci-theme-argon && git clone https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-design feeds/luci/applications/luci-app-design-config && git_svn main https://github.com/fichenx/packages luci-theme-design luci-app-design-config

#添加luci-theme-design(Js版)
rm -rf feeds/fichenx/luci-theme-design
git clone -b js https://github.com/papagaye744/luci-theme-design package/custom2/luci-theme-design


#修改默认主题
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon-mod/root/etc/uci-defaults/90_luci-theme-argon
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
#sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-netgear/root/etc/uci-defaults/30_luci-theme-netgear
#sed -i 's|luci-theme-bootstrap|luci-theme-design|g' feeds/luci/collections/luci/Makefile

sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-light/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-ssl-nginx/Makefile

#####design主题导航栏设置######
#sed -i 's/shadowsocksr/bypass/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's|services/openclash|services/bypass|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's/system\/admin/docker\/containers/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's|openclash.png|ssr.png|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm




##########添加&修改插件#########



#nps（修改nps源为yisier）
rm -rf feeds/packages/net/nps
cp -rf $GITHUB_WORKSPACE/backup/nps feeds/packages/net/nps
#sed -i 's/PKG_SOURCE_URL:=.*/PKG_SOURCE_URL:=https:\/\/codeload.github.com\/yisier\/nps\/tar.gz\/v$(PKG_VERSION)?/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.26.18/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=29da044262071a1fa53ce7169c6427ee4f12fc0ada60ef7fb52fabfd165afe91/g' feeds/packages/net/nps/Makefile
#luci-app-nps（修改nps显示位置）
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-nps/luasrc/controller/nps.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-nps/luasrc/view/nps/nps_status.htm
#luci-app-nps（修改nps服务器允许域名）
sed -i 's|^server.datatype = "ipaddr"|--server.datatype = "ipaddr"|g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's|^server.datatype="ipaddr"|--server.datatype="ipaddr"|g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's|Must an IPv4 address|IPv4 address or domain name|g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's|Must an IPv4 address|IPv4 address or domain name|g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po
sed -i 's|必须是 IPv4 地址|IPv4 地址或域名|g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po


#为lede源恢复mac80211v5.15.33驱动依赖kmod-qcom-qmi-helpers
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo 'define KernelPackage/qcom-qmi-helpers' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  SUBMENU:=$(OTHER_MENU)' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  TITLE:=Qualcomm QMI Helpers' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  KCONFIG:=CONFIG_QCOM_QMI_HELPERS' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  FILES:=$(LINUX_DIR)/drivers/soc/qcom/qmi_helpers.ko' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  AUTOLOAD:=$(call AutoProbe,qmi_helpers)' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo 'endef' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo 'define KernelPackage/qcom-qmi-helpers/description' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  Qualcomm QMI Helpers' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo 'endef' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '$(eval $(call KernelPackage,qcom-qmi-helpers))' >> package/kernel/linux/modules/other.mk

#为1ede添加luci-app-wechatpush
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-wechatpush
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i 's|CONFIG_PACKAGE_luci-app-serverchan=y|CONFIG_PACKAGE_luci-app-wechatpush=y|g' .config
[ -e package/lean/default-settings/files/zzz-default-settings ] && git clone -b master https://github.com/tty228/luci-app-wechatpush package/custom2/luci-app-wechatpush

# 替换lede自带watchcat为官方最新版
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/utils/watchcat
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn master https://github.com/openwrt/packages utils/watchcat
# 替换watchcat为第三方luci(lua版luci)
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn main https://github.com/fichenx/packages luci-app-watchcat-plus

#更换msd_lite为最新版（immortalwrt源）
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/msd_lite
#[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn master https://github.com/immortalwrt/packages  net/msd_lite

#golang
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/lang/golang
[ -e package/lean/default-settings/files/zzz-default-settings ] && cp -rf $GITHUB_WORKSPACE/general/golang feeds/packages/lang/golang

#为immortalwrt添加turboacc
[ ! -e package/lean/default-settings/files/zzz-default-settings ] && curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

#为immortalwrt添加luci-app-mwan3helper-chinaroute（MWAN3 分流助手）(lua版luci)
[ ! -e package/lean/default-settings/files/zzz-default-settings ] && git clone -b main https://github.com/padavanonly/luci-app-mwan3helper-chinaroute package/luci-app-mwan3helper-chinaroute


#更换旧版lede代码中的ath11k-firmware源（旧源已失效）
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf package/firmware/ath11k-firmware/Makefile
#[ -e package/lean/default-settings/files/zzz-default-settings ] && cp -rf $GITHUB_WORKSPACE/backup/AX6/package/firmware/ath11k-firmware/Makefile package/firmware/ath11k-firmware/Makefile

#更换miniupnpd为最新版（immortalwrt源）
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/miniupnpd
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn master https://github.com/immortalwrt/packages net/miniupnpd

#替换luci-app-socat为https://github.com/chenmozhijin/luci-app-socat(lua版)
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-socat
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn main https://github.com/chenmozhijin/luci-app-socat luci-app-socat

#添加luci-app-lucky(lua版)
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-lucky feeds/packages/net/lucky
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_svn main  https://github.com/gdy666/luci-app-lucky luci-app-lucky lucky

#更换luci-app-ikoolproxy为3.8.5-8(lua版luci)
[ -e package/lean/default-settings/files/zzz-default-settings ] && git clone -b main https://github.com/ilxp/luci-app-ikoolproxy.git package/custom2/luci-app-ikoolproxy

#########修复编译错误#########
#为bypass添加redsocks2依赖。
#svn co https://github.com/fw876/helloworld/trunk/redsocks2 package/redsocks2

#修复 shadowsocksr-libev libopenssl-legacy 依赖问题
sed -i 's/ +libopenssl-legacy//g' feeds/fichenx/shadowsocksr-libev/Makefile

##修复elfutils编译错误
#1、修复lede版elfutils0.188版编译错误
sed -i "s|TARGET_CFLAGS += -D_GNU_SOURCE -Wno-unused-result -Wno-format-nonliteral|TARGET_CFLAGS += -D_GNU_SOURCE -Wno-unused-result -Wno-format-nonliteral -Wno-error=use-after-free|g" package/libs/elfutils/Makefile
#2、修复替换后openwrt官方版elfutils0.191版elfutils编译错误
sed -i "s|CONFIG_GCC_USE_VERSION_11|CONFIG_GCC_USE_VERSION_12|g" package/custom2/elfutils/Makefile

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

#恢复breakings替换的autocore Makefile文件
sed -i 's/DEPENDS:=@(.*/DEPENDS:=@(arm||aarch64) \\/g' package/lean/autocore/Makefile

#修复breakings替换zlib后的编译问题
git_sparse_clone main https://github.com/openwrt/openwrt package/libs/zlib && mv -n zlib package/libs/zlib
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.3.1/g' tools/zlib/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23/g' tools/zlib/Makefile

#./scripts/feeds update -a
#./scripts/feeds install -a
