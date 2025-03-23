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


# 1.修改默认ip
sed -i 's/192.168.1.1/192.168.1.110/g' package/base-files/files/bin/config_generate

# 2.修改主机名
sed -i 's/OpenWrt/OneCloud/g' package/base-files/files/bin/config_generate

# 5.修改默认主题
sed -i "s/luci-static\/bootstrap/luci-static\/argon/g" feeds/luci/modules/luci-base/root/etc/config/luci

# 7.修正连接数
# sed -i '/will not survive a reimage/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
sed -i '/will not survive a reimage/a fs.file-max=102400\nnet.ipv4.neigh.default.gc_thresh1=512\nnet.ipv4.neigh.default.gc_thresh2=2048\nnet.ipv4.neigh.default.gc_thresh3=4096\nnet.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_max=65536' >>package/kernel/linux/files/sysctl-nf-conntrack.conf

# AdguardHome core
# mkdir -p files/usr/bin
# AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep /AdGuardHome_linux_armv7 | awk -F '"' '{print $4}')
# wget -qO- $AGH_CORE | tar xOvz > files/usr/bin/AdGuardHome
# chmod +x files/usr/bin/AdGuardHome

# 下载openclash内核,如果 core 文件夹不存在，创建文件夹
if [ ! -d "./files/etc/openclash/core" ]; then
  mkdir -p files/etc/openclash/core
fi
# CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-armv7.tar.gz"
# CLASH_TUN_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/master/premium\?ref\=core | grep download_url | grep armv7 | awk -F '"' '{print $4}')
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/meta/clash-linux-armv7.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
GEO_MMDB_URL="https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb"
# wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
# wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat
wget -qO- $GEO_MMDB_URL > files/etc/openclash/Country.mmdb

# resize
chmod +x files/root/expand-root.sh
chmod +x files/root/resize.sh

#修改默认时区
sed -i "s/timezone='UTC'/timezone='CST-8'/g" package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" package/base-files/files/bin/config_generate


# uwsgi - fix timeout
# sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
# sed -i '/limit-as/c\limit-as = 5000' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# disable error log
# sed -i "s/procd_set_param stderr 1/procd_set_param stderr 0/g" feeds/packages/net/uwsgi/files/uwsgi.init

# uwsgi - performance
# sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini


