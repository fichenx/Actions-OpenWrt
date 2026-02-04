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
cp -rf $GITHUB_WORKSPACE/backup/001-fix-cmake-compatibility.patch $BASE_PATH/action_build/feeds/packages/net/n2n/patches/

#替换luci-app-timecontrol为gaobin89/luci-app-timecontrol
rm -rf feeds/luci/applications/luci-app-timecontrol
git_sparse_clone js https://github.com/gaobin89/luci-app-timecontrol luci-app-timecontrol && mv -n luci-app-timecontrol feeds/luci/applications/luci-app-timecontrol

##更换luci-theme-design
#rm -rf $BASE_PATH/action_build/feeds/luci/themes/luci-theme-design $BASE_PATH/action_build/feeds/fichenx/luci-theme-design
#git_sparse_clone dev https://github.com/fichenx/packages luci-theme-design && cp -af luci-theme-design $BASE_PATH/action_build/feeds/luci/themes/luci-theme-design
#mv -n luci-theme-design $BASE_PATH/action_build/feeds/fichenx/luci-theme-design
echo "========================="
echo " 自定义(fichen) 配置完成……"