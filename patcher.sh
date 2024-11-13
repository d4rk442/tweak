#!/usr/bin/env bash

echo -e "SCRIPT-START"
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 1.1.1.1
nameserver 1.0.0.1
DNS

echo -e "CHANGE-FEEDS"
cat > /etc/opkg/distfeeds.conf <<-DIST
src/gz openwrt_base https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/base
src/gz openwrt_luci https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/telephony
DIST
chmod +x /etc/opkg/distfeeds.conf;

opkg install nano
opkg install sudo
opkg install curl
opkg install htop
opkg install vsftpd
opkg install isc-dhcp-client-ipv6 --force-overwrite
opkg install isc-dhcp-server-ipv6 --force-overwrite
opkg install isc-dhcp-relay-ipv6 --force-overwrite

echo -e "PATCH-FIREWALL"
wget -q -O  /etc/config/firewall "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/firewall";
chmod +x  /etc/config/firewall;
uci commit firewall

echo -e "CHANGE-SYS-MODEM"
uci set cpufreq.cpufreq.governor=ondemand;
uci set cpufreq.cpufreq.minifreq=2208000;
uci commit cpufreq;
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
uci set firewall.@defaults[0].flow_offloading='0';
uci set firewall.@defaults[0].flow_offloading_hw='0';
uci commit firewall;
uci set network.globals.packet_steering=0;
uci commit network;
uci set network.lan.dns='1.1.1.1 1.0.0.1';
uci commit network.lan;
uci set network.wan.ifname='wwan0_1';
uci commit network.wan;
uci set network.wan.peerdns='0';
uci commit network.wan;
uci set network.wan1.peerdns='0';
uci commit network.wan1;
uci set network.wan6.disabled='1';
uci delete network.wan6;
uci set network.wan2.disabled='1';
uci delete network.wan2;
uci set network.vpn0.disabled='1';
uci delete network.vpn0;
uci set network.ipsec_server.disabled='1';
uci delete network.ipsec_server;
uci commit network;

echo -e "SETTING-DHCP.SCRIPT"
wget -q -O /lib/netifd/dhcp.script "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/dhcp.script";
chmod +x /lib/netifd/dhcp.script;

echo -e "TWEAK-SPEED-SYSCTL"
cat > /etc/sysctl.d/10-default.conf <<-DEF
kernel.panic=3
kernel.core_pattern=core

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
net.ipv4.tcp_keepalive_time=120
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
DEF
chmod +x /etc/sysctl.d/10-default.conf;

rm -f /etc/sysctl.d/12-tcp-bbr.conf

cat > /etc/sysctl.d/11-tweak-core.conf <<-POPS
net.core.default_qdisc=fq_codel
net.ipv4.tcp_congestion_control=bbr
POPS
chmod +x /etc/sysctl.d/11-tweak-core.conf;

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
chmod +x /etc/sysctl.d/11-nf-conntrack.conf;

echo -e "SCRIPT-FINISHING"
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 127.0.0.1
DNS

rm -rf /root/*
reboot
