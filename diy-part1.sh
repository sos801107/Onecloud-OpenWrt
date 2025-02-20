#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# 汇总常用插件

function merge_package() {
    # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    if [[ $# -lt 3 ]]; then
    	echo "Syntax error: [$#] [$*]" >&2
        return 1
    fi
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    # 使用循环逐个移动文件夹
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}

merge_package main https://github.com/kenzok8/small-package package/app luci-app-adguardhome
merge_package v5 https://github.com/sbwml/luci-app-mosdns package/app luci-app-mosdns mosdns v2dat
merge_package main https://github.com/kenzok8/small-package package/app luci-app-fileassistant

merge_package main https://github.com/nikkinikki-org/OpenWrt-nikki package/app luci-app-nikki
merge_package main https://github.com/nikkinikki-org/OpenWrt-nikki package/app nikki

echo 'src-git lucky https://github.com/gdy666/luci-app-lucky.git' >>feeds.conf.default
git clone -b js --depth 1 https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/app/luci-app-unblockneteasemusic
git clone -b master https://github.com/sbwml/luci-app-qbittorrent package/app/qbittorrent

echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;main" >> "feeds.conf.default"
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> "feeds.conf.default"

# 开发版openclash
merge_package dev https://github.com/vernesong/OpenClash package/app luci-app-openclash
# 下载openclash内核,如果 core 文件夹不存在，创建文件夹
if [ ! -d "./files/etc/openclash/core" ]; then
  mkdir -p files/etc/openclash/core
fi

CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-armv7.tar.gz"
CLASH_TUN_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/master/premium\?ref\=core | grep download_url | grep armv7 | awk -F '"' '{print $4}')
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-armv7.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
GEO_MMDB_URL="https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb"

wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat
wget -qO- $GEO_MMDB_URL > files/etc/openclash/Country.mmdb

# kiddin9
shopt -s extglob
SHELL_FOLDER=$(dirname $(readlink -f "$0"))
merge_package main https://github.com/lxiaya/openwrt-onecloud target/linux target/linux/amlogic
sed -i "s/wpad-openssl/wpad-basic-mbedtls/" target/linux/amlogic/image/Makefile
sed -i "s/neon-vfpv4/vfpv4/" target/linux/amlogic/meson8b/target.mk
rm -rf package/feeds/routing/batman-adv

./scripts/feeds update -a

merge_package openwrt-23.05 https://github.com/coolsnowwolf/luci feeds/luci/applications applications/luci-app-pppwn
merge_package master https://github.com/coolsnowwolf/packages feeds/packages/multimedia multimedia/pppwn-cpp

merge_package openwrt-24.10 https://github.com/immortalwrt/luci feeds/luci/applications applications/luci-app-msd_lite
merge_package openwrt-24.10 https://github.com/immortalwrt/packages feeds/packages/net net/msd_lite

./scripts/feeds install -a


# 主题

# echo '### Argon Theme Config ###'
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b master  https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config # if have
git clone https://github.com/jerrykuku/luci-app-argon-config.git feeds/luci/applications/luci-app-argon-config

./scripts/feeds update -a
./scripts/feeds install -a
