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


##########固件配置修改#########
# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

#修改默认IP
sed -i 's/192.168.1.1/192.168.125.1/g' package/base-files/files/bin/config_generate

# web登陆密码从password修改为空
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

#固件版本号添加个人标识和日期
#sed -i "s/DISTRIB_DESCRIPTION='.*OpenWrt '/DISTRIB_DESCRIPTION='FICHEN($(TZ=UTC-8 date +%Y.%m.%d))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "s/DISTRIB_DESCRIPTION='.*LEDE '/DISTRIB_DESCRIPTION='FICHEN($(TZ=UTC-8 date +%Y.%m.%d))@LEDE '/g" package/lean/default-settings/files/zzz-default-settings

#编译的固件文件名添加日期
#sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d")-$(VERSION_DIST_SANITIZED)/g' include/image.mk

#添加自动挂载磁盘脚本
#mkdir -p files/etc/hotplug.d/block && wget -O files/etc/hotplug.d/block/30-usbmount https://raw.githubusercontent.com/ficheny/P3TERX_Actions-OpenWrt/main/files/etc/hotplug.d/block/30-usbmount && chmod 755 files/etc/hotplug.d/block/30-usbmount

#修改主机名
sed -i "s/hostname='OpenWrt'/hostname='MiWiFi-mini'/g" package/base-files/files/bin/config_generate

#修改插件位置
#sed -i '/sed -i "s\/services\/system\/g" \/usr\/lib\/lua\/luci\/controller\/cpufreq.lua/d'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i sed -i "s/services/system/g" /usr/lib/lua/luci/controller/cpufreq.lua'  package/lean/default-settings/files/zzz-default-settings


#添加关机选项（https://github.com/sirpdboy/luci-app-poweroffdevice）
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/poweroff.htm > ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_system/poweroff.htm 
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/system.lua > ./feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua

##########固件主题添加&修改#########
#更换lede源码中自带argon主题
#rm -rf feeds/luci/themes/luci-theme-argon && git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-design && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-theme-design && mv -n luci-theme-design feeds/luci/themes/luci-theme-design
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-design-config && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-app-design-config && mv -n luci-theme-design feeds/luci/applications/luci-app-design-config

#design主题导航栏设置
#sed -i 's/shadowsocksr/bypass/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
sed -i 's|services/openclash|services/bypass|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's/system\/admin/docker\/containers/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
sed -i 's|openclash.png|ssr.png|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm

#修改默认主题
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon-mod/root/etc/uci-defaults/90_luci-theme-argon
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-netgear/root/etc/uci-defaults/30_luci-theme-netgear
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-light/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-ssl-nginx/Makefile


##########添加&修改插件#########
#9.禁止Turbo ACC 网络加速修改net.bridge.bridge-nf-call-iptables的值为1(修改为1后旁路由需开启ip动态伪装，影响下行带宽)。
#sed -i '/exit 0/i sed -i "s/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& return 0/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& return 1/g" /etc/init.d/qca-nss-ecm'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i sed -i "s/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& sysctl -w dev.nss.general.redirect=1/\\#[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& sysctl -w dev.nss.general.redirect=1/g" /etc/init.d/qca-nss-ecm'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i /etc/init.d/qca-nss-ecm disable' package/lean/default-settings/files/zzz-default-settings

#为bypass添加redsocks2依赖。
#svn co https://github.com/fw876/helloworld/trunk/redsocks2 package/redsocks2


#nps（修改nps源为yisier）
rm -rf feeds/packages/net/nps
cp -rf $GITHUB_WORKSPACE/backup/nps feeds/packages/net
#sed -i 's/PKG_SOURCE_URL:=.*/PKG_SOURCE_URL:=https:\/\/codeload.github.com\/yisier\/nps\/tar.gz\/v$(PKG_VERSION)?/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.26.18/g' feeds/packages/net/nps/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=29da044262071a1fa53ce7169c6427ee4f12fc0ada60ef7fb52fabfd165afe91/g' feeds/packages/net/nps/Makefile
#luci-app-nps（修改nps显示位置）
sed -i 's/"services"/"vpn"/g'  feeds/luci/applications/luci-app-nps/luasrc/controller/nps.lua
sed -i 's/\[services\]/\[vpn\]/g'  feeds/luci/applications/luci-app-nps/luasrc/view/nps/nps_status.htm
#luci-app-nps（修改nps服务器允许域名）
sed -i 's/^server.datatype = "ipaddr"/--server.datatype = "ipaddr"/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/luasrc/model/cbi/nps.lua
sed -i 's/Must an IPv4 address/IPv4 address or domain name/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po
sed -i 's/必须是 IPv4 地址/IPv4 地址或域名/g' feeds/luci/applications/luci-app-nps/po/zh-cn/nps.po

#luci-app-serverchan
rm -rf feeds/luci/applications/luci-app-serverchan
cp -af feeds/fichenx/luci-app-serverchan feeds/luci/applications/luci-app-serverchan

#恢复breakings替换的autocore Makefile文件
sed -i 's/DEPENDS:=@(.*/DEPENDS:=@(arm||aarch64) \\/g' package/lean/autocore/Makefile


