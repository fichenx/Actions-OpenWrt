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

echo "开始 自定义（fichen） 配置……"
echo "========================="
#给n2n添加补丁文件，修正前两行语法顺序颠倒的错误
BASE_PATH=$(cd $(dirname $0)/../ && pwd)
cp -rf $GITHUB_WORKSPACE/patch/001-fix-cmake-compatibility.patch $BASE_PATH/action_build/feeds/packages/net/n2n/patches/
#删除n2n无效补丁
rm -rf $BASE_PATH/action_build/feeds/packages/net/n2n/patches/110-cmake.patch

#替换luci-app-timecontrol为gaobin89/luci-app-timecontrol
rm -rf $BASE_PATH/action_build/feeds/luci/applications/luci-app-timecontrol
git_sparse_clone js https://github.com/gaobin89/luci-app-timecontrol luci-app-timecontrol && mv -n luci-app-timecontrol $BASE_PATH/action_build/feeds/luci/applications/luci-app-timecontrol

##更换luci-theme-design
#rm -rf $BASE_PATH/action_build/feeds/luci/themes/luci-theme-design $BASE_PATH/action_build/feeds/fichenx/luci-theme-design
#git_sparse_clone dev https://github.com/fichenx/packages luci-theme-design && cp -af luci-theme-design $BASE_PATH/action_build/feeds/luci/themes/luci-theme-design
#mv -n luci-theme-design $BASE_PATH/action_build/feeds/fichenx/luci-theme-design

#给libubox加补丁，禁止非字面格式字符串的警告
#mkdir -p $BASE_PATH/action_build/package/libs/libubox/patches && \
#cp -f $GITHUB_WORKSPACE/patch/100-remove-format-nonliteral.patch $BASE_PATH/action_build/package/libs/libubox/patches/

#添加luci-app-lucky、lucky
mk_dir="$BASE_PATH/action_build/feeds/fichenx/lucky/Makefile"
mk_lede_dir="$BASE_PATH/action_build/feeds/packages/net/lucky/Makefile"
rm -rf $BASE_PATH/action_build/feeds/luci/applications/luci-app-lucky $BASE_PATH/action_build/feeds/packages/net/lucky
#git_svn main https://github.com/gdy666/luci-app-lucky luci-app-lucky lucky
git_sparse_clone main https://github.com/gdy666/luci-app-lucky luci-app-lucky && mv -n luci-app-lucky $BASE_PATH/action_build/feeds/luci/applications/luci-app-lucky
git_sparse_clone main https://github.com/gdy666/luci-app-lucky lucky && mv -n lucky $BASE_PATH/action_build/feeds/packages/net/lucky
##使用在线lucky万吉版本
#if [ -d "${mk_dir%/*}" ] && [ -f "$mk_dir" ]; then
#    sed -i 's|Linux_$(LUCKY_ARCH)|Linux_$(LUCKY_ARCH)_wanji|g' "$mk_dir"
#fi
#if [ -d "${mk_lede_dir%/*}" ] && [ -f "$mk_lede_dir" ]; then
#    sed -i 's|Linux_$(LUCKY_ARCH)|Linux_$(LUCKY_ARCH)_wanji|g' "$mk_lede_dir"
#fi
##使用本地lucky万吉版本
update_lucky() {
    local lucky_dir="$BASE_PATH/action_build/feeds/packages/net/lucky"

    # 默认关闭lucky
    local lucky_conf="$BASE_PATH/action_build/feeds/packages/net/lucky/files/luckyuci"
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

    local makefile_path="$BASE_PATH/action_build/feeds/packages/net/lucky/Makefile"
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
#update_lucky

#强制smartdns单线程编译
sed -i 's/^PKG_BUILD_PARALLEL:=1/PKG_BUILD_PARALLEL:=0/' $BASE_PATH/action_build/feeds/packages/net/smartdns/Makefile

#替换sing-box为官方原版
rm -rf $BASE_PATH/action_build/feeds/fichenx/sing-box
git_sparse_clone master https://github.com/immortalwrt/packages net/sing-box && mv -n sing-box $BASE_PATH/action_build/feeds/fichenx/sing-box

echo "========================="
echo " 自定义(fichen) 配置完成……"
