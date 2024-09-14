echo -e "SCRIPT-START"
rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
DNS

echo -e "CHANGE-FEEDS"
rm -rf /etc/opkg/distfeeds.conf
cat > /etc/opkg/distfeeds.conf <<-DIST
src/gz openwrt_base https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/base
src/gz openwrt_luci https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/telephony
DIST

echo -e "INSTALL-BASIC"
opkg update
opkg remove --autoremove luci-i18n-sqm-*
opkg remove --autoremove luci-app-sqm

opkg install nano
opkg install sudo
opkg install curl
opkg install htop
opkg install irqbalance
opkg install xray-core
opkg install luci-app-sqm

echo -e "CHANGE-SYS-MODEM"
uci set cpufreq.cpufreq.governor=performance;
uci set cpufreq.cpufreq.minifreq=2208000;
uci commit cpufreq;
uci set turboacc.config.bbr_cca=0;
uci commit turboacc;
uci set system.@system[0].zonename='Asia/Kuala Lumpur';
uci commit system;
uci set luci.main.lang='auto';
uci commit luci.main;
uci -q delete system.ntp.server;
uci add_list system.ntp.server='my.pool.ntp.org';
uci add_list system.ntp.server='ntp.google.com';
uci add_list system.ntp.server='ntp.windows.com';
uci add_list system.ntp.server='ntp.cloudflare.com';
uci commit system.ntp;
/etc/init.d/sysntpd restart;
uci set network.wan.ifname='wwan0_1';
uci commit network.wan;
uci set network.wan6.ifname='wwan0_1';
uci commit network.wan6;
uci set network.lan.dns='127.0.0.1 ::1';
uci commit network.lan;
uci set firewall.@defaults[0].flow_offloading='0';
uci set firewall.@defaults[0].flow_offloading_hw='0';
uci commit firewall;
uci set network.globals.packet_steering=1;
uci commit network;
uci set network.wan1.peerdns='0';
uci delete network.wan1.dns;
uci commit network.wan1
uci set network.wan.peerdns='0';
uci delete network.wan.dns;
uci commit network.wan
uci set network.wan6.peerdns='0';
uci delete network.wan6.dns;
uci commit network.wan6

uci set network.globals.ula_prefix=''
uci commit network
uci set dhcp.lan.ra='relay'
uci set dhcp.lan.dhcpv6='relay'
uci set dhcp.lan.ndp='relay'
uci commit dhcp
uci set dhcp.wan6=dhcp
uci set dhcp.wan6.interface='wan6'
uci set dhcp.wan6.ignore='1'
uci set dhcp.wan6.master='1'
uci set dhcp.wan6.dhcpv6='relay'
uci set dhcp.wan6.ra='relay'
uci set dhcp.wan6.ndp='relay'
uci commit dhcp

echo -e "BYPASS-DNSMASQ"
rm -rf /etc/dnsmasq.conf
cat > /etc/dnsmasq.conf <<-DNSMASQ
#!/usr/bin/env bash
bind-dynamic
bogus-priv
no-resolv
strict-order
log-facility=-
local-ttl=60
interface=*
server=1.1.1.1
server=1.0.0.1
DNSMASQ

echo -e "BYPASS-TTL"
rm -rf /overlay/upper/etc/firewall.user
cat > /overlay/upper/etc/firewall.user <<-FFE
#!/bin/sh
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64
FFE

rm -rf /etc/firewall.user
cat > /etc/firewall.user <<-FFW
#!/bin/sh
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64
FFW

rm -rf /overlay/upper/etc/ttl.user.bk
cat > /overlay/upper/etc/ttl.user.bk <<-FFE
#!/bin/sh
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64
FFE

rm -rf /etc/ttl.user.bk
cat > /etc/ttl.user.bk <<-FFW
#!/bin/sh
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64
FFW

iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64
uci commit firewall

echo -e "TWEAK-SPEED"
rm -rf /etc/sysctl.d/*
cat > /etc/sysctl.d/custom-default.conf <<-CUSTOM
kernel.panic=3
kernel.core_pattern=/tmp/%e.%t.%p.%s.core

net.ipv4.conf.default.arp_ignore=1
net.ipv4.conf.all.arp_ignore=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_errors_use_inbound_ifaddr=0
net.ipv4.igmp_max_memberships=100
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_dsack=1

net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.all.disable_ipv6=0
net.ipv6.conf.default.disable_ipv6=0

net.netfilter.nf_conntrack_acct=1
net.netfilter.nf_conntrack_checksum=0
net.netfilter.nf_conntrack_max=65535
net.netfilter.nf_conntrack_tcp_timeout_time_wait=30
net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30
net.netfilter.nf_conntrack_tcp_timeout_established=7440
net.netfilter.nf_conntrack_udp_timeout=60
net.netfilter.nf_conntrack_udp_timeout_stream=180
CUSTOM

cat > /etc/sysctl.d/custom-bbr.conf <<-BBR
net.core.default_qdisc=fq_codel
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_default=87380
net.core.wmem_default=65536
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_mem=4096 65536 16777216
net.core.netdev_max_backlog=2500
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_moderate_rcvbuf=1
BBR

echo -e "INSTALL-PASSWALL"
wget http://abidarwish.online/arcadyan/luci-app-passwall_4.66-8_all.ipk
opkg install luci-app-passwall_4.66-8_all.ipk

echo -e "SETTING-IRQ"
rm -rf /etc/config/irqbalance
cat > /etc/config/irqbalance <<-IRQ
config irqbalance 'irqbalance'
             option enable '1'

             option interval '1'
IRQ

rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
search lan
nameserver 127.0.0.1
nameserver ::1
DNS

rm -rf /etc/openwrt_release
cat > /etc/openwrt_release <<-IDD
DISTRIB_ID='CUSTOM TWEAK'
DISTRIB_RELEASE='21.02-SNAPSHOT'
DISTRIB_TARGET='ipq807x/generic'
DISTRIB_ARCH='aarch64_cortex-a53'
DISTRIB_TAINTS='no-all busybox'
DISTRIB_DESCRIPTION='QWRT TWEAK BY DYNO'
IDD

echo -e "MANAGE-RCLOCAL"
/etc/init.d/irqbalance enable
/etc/init.d/dnsmasq enable
rm -rf /etc/rc.local
cat > /etc/rc.local <<-RCD
#!/bin/sh -e
# This starts wifi on boot up

for radio in 'radio0' 'radio1'
do
    # Radio doesn't exist.
    uci -q get wireless."$radio" || continue

    # Enable wifi radios
    uci -q set wireless."$radio".disabled=0
    uci -q commit wireless

done
wifi up
#TweakBin

#TWEAK
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64
sysctl net.ipv4.tcp_congestion_control=bbr
sysctl net.ipv6.conf.all.disable_ipv6=0
sysctl net.ipv6.conf.default.disable_ipv6=0
echo f > /sys/class/net/br-lan/queues/rx-0/rps_cpus
echo f > /sys/class/net/wwan0/queues/rx-0/rps_cpus
echo f > /sys/class/net/wwan0_1/queues/rx-0/rps_cpus
exit 0
RCD
chmod +x /etc/rc.local
/etc/rc.local enable

rm -rf /root/*
reboot
echo -e "FINISH SCRIPT REBOOT............"
