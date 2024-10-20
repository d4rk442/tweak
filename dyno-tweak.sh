echo -e "SCRIPT-START"
rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 1.1.1.1
nameserver 1.0.0.1
DNS

echo -e "REMOVE-BASIC"
opkg update
opkg remove --autoremove luci-i18n-openvpn-server-zh-cn
opkg remove --autoremove luci-i18n-openvpn-*
opkg remove --autoremove luci-i18n-ipsec-server-zh-cn
opkg remove --autoremove luci-app-ipsec-server*

opkg install nano
opkg install sudo
opkg install curl
opkg install htop
opkg install luci-i18n-qos-en --force-overwrite
opkg install luci-i18n-base-en --force-overwrite
opkg install luci-i18n-firewall-en --force-overwrite
opkg install luci-i18n-sqm-en --force-overwrite
opkg install luci-i18n-statistics-en --force-overwrite

echo -e "CHANGE-SYS-MODEM"
uci set cpufreq.cpufreq.governor=ondemand;
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
uci set network.wan.ifname='wwan0_1';
uci commit network.wan;
uci set network.wan6.ifname='wwan0_1';
uci commit network.wan6;
uci set network.lan.dns='1.1.1.1 2606:4700:4700::1111';
uci commit network.lan;
uci set firewall.@defaults[0].flow_offloading='0';
uci set firewall.@defaults[0].flow_offloading_hw='0';
uci commit firewall;
uci set network.globals.packet_steering=1;
uci set network.wan.peerdns='0';
uci delete network.wan.dns;
uci commit network.wan;
uci set network.wan1.peerdns='0';
uci delete network.wan1.dns;
uci commit network.wan1;
uci set network.wan6.peerdns='0';
uci delete network.wan6.dns;
uci commit network.wan6;
uci commit network;
uci commit;

uci set dhcp.wan6=dhcp;
uci set dhcp.wan6.interface='wan6';
uci set dhcp.wan6.ignore='1';
uci commit dhcp;

echo -e "BYPASS-DNSMASQ"
rm -rf /etc/config/dhcp-opkg
rm -rf /etc/config/dhcp.save
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
rm -rf /etc/init.d/firewall-custom
cat > /etc/init.d/firewall-custom <<-FRW
#!/bin/sh /etc/rc.common

START=99

start() {

logger -t firewall-custom "Starting custom firewall rules"

iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64

}

stop() {

logger -t firewall-custom "Stopping custom firewall rules"

iptables -t mangle -D POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -D POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -D PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -D PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -D POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -D POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -D PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -D PREROUTING -i wwan0_1 -j HL --hl-set 64

}
FRW
chmod +x /etc/init.d/firewall-custom

echo -e "TWEAK-SPEED-SYSCTL"
cat > /etc/sysctl.d/10-default.conf <<-DEF
kernel.panic=3
kernel.core_pattern=/tmp/%e.%t.%p.%s.core

fs.protected_hardlinks=1
fs.protected_symlinks=1

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

net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_moderate_rcvbuf=1
DEF

cat > /etc/sysctl.d/11-nf-conntrack.conf <<-CONS
net.netfilter.nf_conntrack_acct=1
net.netfilter.nf_conntrack_checksum=0
net.netfilter.nf_conntrack_max=65535
net.netfilter.nf_conntrack_tcp_timeout_established=7440
net.netfilter.nf_conntrack_udp_timeout=60
net.netfilter.nf_conntrack_udp_timeout_stream=180
net.netfilter.nf_conntrack_helper=1
net.netfilter.nf_conntrack_buckets=16384
net.netfilter.nf_conntrack_expect_max=16384
CONS

echo -e "INSTALL-RCSCRIPT"
wget -q -O installer.sh http://abidarwish.online/rcscript2.2 && sh installer.sh

echo -e "INSTALL-PASSWALL"
wget https://github.com/d4rk442/tweak/raw/refs/heads/main/xray-core_1.7.2-1_aarch64_cortex-a53.ipk
opkg install xray-core_1.7.2-1_aarch64_cortex-a53.ipk
wget http://abidarwish.online/arcadyan/luci-app-passwall_4.66-8_all.ipk
opkg install luci-app-passwall_4.66-8_all.ipk

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

echo -e "MANAGE-CPU"
rm -rf /etc/init.d/cpu-force
cat > /etc/init.d/cpu-force <<-FRW
#!/bin/sh /etc/rc.common

START=99

start() {

logger -t cpu-force "Starting custom cpu-force rules"

sysctl net.ipv4.tcp_congestion_control=bbr
echo -n f > /sys/class/net/wwan0_1/queues/rx-0/rps_cpus
echo -n f > /sys/class/net/wwan0/queues/rx-0/rps_cpus
echo -n f > /sys/class/net/br-lan/queues/rx-0/rps_cpus

}

stop() {

logger -t cpu-force "Stopping custom cpu-force rules"

sysctl net.ipv4.tcp_congestion_control=cubic
echo -n 0 > /sys/class/net/wwan0_1/queues/rx-0/rps_cpus
echo -n 0 > /sys/class/net/wwan0/queues/rx-0/rps_cpus
echo -n 0 > /sys/class/net/br-lan/queues/rx-0/rps_cpus

}
FRW
chmod +x /etc/init.d/cpu-force

echo -e "MANAGE-WIFI"
config wifi-device 'wifi0'
        option type 'qcawificfg80211'
        option macaddr 'ec:6c:9a:b8:4c:e0'
        option hwmode '11axa'
        option country 'US'
        option channel '128'
        option htmode 'HT160'
        option txpower '30'

config wifi-iface 'ath0'
        option device 'wifi0'
        option network 'lan'
        option mode 'ap'
        option wmm '1'
        option rrm '1'
        option qbssload '1'
        option ssid 'QWRT-5G'
        option encryption 'psk'
        option key '112233445566'

config wifi-device 'wifi1'
        option type 'qcawificfg80211'
        option channel '1'
        option macaddr 'ec:6c:9a:b8:4c:df'
        option hwmode '11axg'
        option country 'US'
        option htmode 'HT20'
        option txpower '30'

config wifi-iface 'ath1'
        option device 'wifi1'
        option network 'lan'
        option mode 'ap'
        option wmm '1'
        option rrm '1'
        option qbssload '1'
        option ssid 'QWRT-2.4'
        option encryption 'psk'
        option key '112233445566'
WIFI
chmod +x /etc/config/wireless

rm -rf /etc/rc.local
cat > /etc/rc.local <<-RCD
#!/bin/sh -e
exit 0
RCD

uci commit
uci commit firewall
uci commit network
uci commit wireless
/etc/init.d/firewall-custom enable
/etc/init.d/firewall-custom start
/etc/init.d/cpu-force enable
/etc/init.d/cpu-force start
/etc/init.d/dnsmasq enable
/etc/init.d/dnsmasq start
/etc/rc.local enable
/etc/rc.local start

rm -rf /root/*
reboot
echo -e "FINISH SCRIPT REBOOT............"
