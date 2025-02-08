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
sed -i 's/192.168.1.1/192.168.2.3/g' package/base-files/files/bin/config_generate

# 2.修改主机名
sed -i 's/OpenWrt/OneCloud/g' package/base-files/files/bin/config_generate

# 5.修改默认主题
sed -i "s/luci-static\/bootstrap/luci-static\/argon/g" feeds/luci/modules/luci-base/root/etc/config/luci

# 7.修正连接数
# sed -i '/will not survive a reimage/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
sed -i '/will not survive a reimage/a fs.file-max=102400\nnet.ipv4.neigh.default.gc_thresh1=512\nnet.ipv4.neigh.default.gc_thresh2=2048\nnet.ipv4.neigh.default.gc_thresh3=4096\nnet.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_max=65536' >>package/kernel/linux/files/sysctl-nf-conntrack.conf

# 替换终端为bash
# sed -i 's/\/bin\/ash/\/bin\/bash/' package/base-files/files/etc/passwd

# 删除默认密码
# sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/lean/default-settings/files/zzz-default-settings

# 禁用wifi
sed -i 's/${defaults ? 0 : 1}/1/g' package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改wifi名字
sed -i 's/OpenWrt/OneCloud/g' package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc

#修改默认时区
sed -i "s/timezone='UTC'/timezone='CST-8'/g" package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" package/base-files/files/bin/config_generate
