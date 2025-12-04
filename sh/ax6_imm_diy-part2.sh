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
#给n2n添加补丁文件，修正前两行语法顺序颠倒的错误
BASE_PATH=$(cd $(dirname $0)/../ && pwd)
cp -rf $GITHUB_WORKSPACE/backup/001-fix-cmake-compatibility.patch $BASE_PATH/action_build/feeds/packages/net/n2n/patches/

echo "========================="
echo " 自定义(fichen) 配置完成……"