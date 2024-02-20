#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: xdp-sockets-diag_support.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

if [[ "$REPO_URL" = "https://github.com/coolsnowwolf/lede" || "$REPO_URL" = "https://github.com/MilesPoupart/lede" ]]; then
  cat $GITHUB_WORKSPACE/backup/kmod-xdp-sockets-diag/xdp-sockets-diag_support.mk >> package/kernel/linux/modules/netsupport.mk
fi