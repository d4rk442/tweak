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
uci set network.lan.dns='1.1.1.1 2606:4700:4700::1111';
uci commit network.lan;
uci set network.wan.peerdns='0';
uci delete network.wan.dns;
uci commit network.wan

echo -e "BYPASS-DNSMASQ"
rm -rf /etc/dnsmasq.conf
cat > /etc/dnsmasq.conf <<-DNSMASQ
#!/usr/bin/env bash
log-facility=-
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
net.ipv4.ip_forward=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.icmp_echo_ignore_all=1
net.ipv4.igmp_max_memberships=100
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_keepalive_time=120
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_dsack=1
net.ipv4.tcp_mtu_probing=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
net.netfilter.nf_conntrack_acct=1
net.netfilter.nf_conntrack_checksum=0
net.netfilter.nf_conntrack_max=16384
net.netfilter.nf_conntrack_tcp_timeout_established=7440
net.netfilter.nf_conntrack_udp_timeout=60
net.netfilter.nf_conntrack_udp_timeout_stream=180
# disable bridge firewalling by default
net.bridge.bridge-nf-call-arptables=0
net.bridge.bridge-nf-call-ip6tables=0
net.bridge.bridge-nf-call-iptables=0
CUSTOM

cat > /etc/sysctl.d/custom-bbr.conf <<-BBR
net.core.default_qdisc=fq_codel
net.ipv4.tcp_congestion_control=bbr
net.core.somaxconn=4096
net.core.rmem_default=1048576
net.core.rmem_max=16777216
net.core.netdev_max_backlog=16384
net.core.wmem_default=1048576
net.core.wmem_max=16777216
net.core.optmem_max=65536
net.ipv4.tcp_rmem=4096 1048576 2097152
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.udp_rmem_min=4096
net.ipv4.udp_wmem_min=4096
net.ipv4.tcp_max_syn_backlog=4096
net.ipv4.tcp_max_tw_buckets=2000000
net.ipv4.ip_local_port_range=10000 65535
BBR

echo -e "TWEAKER-BIASA"
rm -rf /overlay/upper/etc/hotplug.d/net/20-smp-tune
rm -rf /etc/hotplug.d/net/20-smp-tune
rm -rf /overlay/upper/etc/hotplug.d/iface/00-netstate
rm -rf /etc/hotplug.d/iface/00-netstate
wget -q -O /overlay/upper/etc/hotplug.d/net/20-smp-tune "https://raw.githubusercontent.com/d4rk442/tweak/main/20-smp-tune";
wget -q -O /etc/hotplug.d/net/20-smp-tune "https://raw.githubusercontent.com/d4rk442/tweak/main/20-smp-tune";
wget -q -O /overlay/upper/etc/hotplug.d/iface/00-netstate "https://raw.githubusercontent.com/d4rk442/tweak/main/00-netstate";
wget -q -O /etc/hotplug.d/iface/00-netstate "https://raw.githubusercontent.com/d4rk442/tweak/main/00-netstate";

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

echo -e "MANAGE-RCLOCAL"
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
echo f > /sys/class/net/br-lan/queues/rx-0/rps_cpus
echo f > /sys/class/net/wwan0/queues/rx-0/rps_cpus
echo f > /sys/class/net/wwan0_1/queues/rx-0/rps_cpus
echo 1500 > /sys/devices/platform/soc/8cf8800.usb3/8c00000.dwc3/xhci-hcd.1.auto/usb4/4-1/4-1:1.4/net/wwan0/net/wwan0_1/mtu
exit 0
RCD
chmod +x /etc/rc.local
/etc/rc.local enable
/etc/init.d/irqbalance enable
/etc/init.d/dnsmasq enable

rm -rf /root/*
reboot
echo -e "FINISH SCRIPT REBOOT............"
