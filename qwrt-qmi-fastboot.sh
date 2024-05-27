echo -e "START TUNING"
rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 1.1.1.1
nameserver 1.0.0.1
DNS

rm -rf /etc/opkg/distfeeds.conf
cat > /etc/opkg/distfeeds.conf <<-DIST
src/gz openwrt_base https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/base
src/gz openwrt_luci https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/telephony
DIST

opkg update
opkg install irqbalance
opkg install nano
opkg install htop
opkg install sudo

echo -e "REMOVE OPENVPN"
opkg remove --autoremove luci-i18n-ipsec-server-zh-cn luci-app-ipsec-server strongswan-* 
opkg remove --autoremove luci-i18n-ipsec-server-zh-cn luci-app-ipsec-server strongswan-* 
opkg remove --autoremove luci-i18n-ipsec-server-zh-cn luci-app-ipsec-server strongswan-* 
opkg remove --autoremove luci-i18n-openvpn-server-zh-cn luci-app-openvpn-server openvpn-*
opkg remove --autoremove luci-i18n-openvpn-server-zh-cn luci-app-openvpn-server openvpn-*
opkg remove --autoremove luci-i18n-openvpn-server-zh-cn luci-app-openvpn-server openvpn-*

opkg update
opkg install dnsmasq-full

opkg remove --autoremove luci-i18n-zerotier-zh-cn luci-app-zerotier
opkg remove --autoremove luci-i18n-zerotier-zh-cn luci-app-zerotier
opkg remove --autoremove luci-i18n-zerotier-zh-cn luci-app-zerotier

rm -rf /overlay/upper/etc/luci-app-ipsec-server
rm -rf /overlay/upper/etc/luci-i18n-ipsec-server-zh-cn
rm -rf /overlay/upper/etc/luci-i18n-openvpn-server-zh-cn
rm -rf /overlay/upper/etc/luci-openvpn

rm -rf /overlay/upper/etc/config/luci-app-ipsec-server
rm -rf /overlay/upper/etc/config/openvpn

rm -rf /etc/config/luci-app-ipsec-server
rm -rf /etc/config/luci-i18n-ipsec-server-zh-cn
rm -rf /etc/config/luci-i18n-openvpn-server-zh-cn
rm -rf /etc/config/luci-openvpn

rm -rf /etc/config/luci-app-ipsec-server
rm -rf /etc/config/openvpn

opkg update
opkg install dnsmasq-full

echo -e "INSTALL DNSMASQ"
rm -rf /etc/dnsmasq.conf
cat > /etc/dnsmasq.conf <<-DNSMASQ
#!/usr/bin/env bash
log-facility=-
DNSMASQ

rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
search lan
nameserver 127.0.0.1
nameserver ::1
DNS

echo -e "BYPASS TTL64"

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
uci commit system.ntp;
/etc/init.d/sysntpd restart;
uci set network.wan.ifname='wwan0_1';
uci commit network.wan;
uci set network.wan6.ifname='wwan0_1';
uci commit network.wan6

rm -rf /overlay/upper/etc/config/network
cat > /overlay/upper/etc/config/network <<-NETTY1
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd0d:1c3a:2ae7::/48'

config interface 'lan'
        option type 'bridge'
        option ifname 'eth0 eth1 eth2 eth3 eth4'
        option proto 'static'
        option ipaddr '192.168.1.1'
        option netmask '255.255.255.0'
        option multicast_querier '0'
        option igmp_snooping '0'
        option ip6assign '60'
        option force_link '1'

config interface 'wan'
        option ifname 'wwan0_1'
        option proto 'dhcp'
        option metric '1'

config interface 'wan6'
        option ifname 'wwan0_1'
        option proto 'dhcpv6'

config interface 'wan1'
        option proto 'qmi'
        option device '/dev/cdc-wdm0'
        option metric '10'
        option currmodem '1'
NETTY1

rm -rf /etc/config/network
cat > /etc/config/network <<-NETTY
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd0d:1c3a:2ae7::/48'

config interface 'lan'
        option type 'bridge'
        option ifname 'eth0 eth1 eth2 eth3 eth4'
        option proto 'static'
        option ipaddr '192.168.1.1'
        option netmask '255.255.255.0'
        option multicast_querier '0'
        option igmp_snooping '0'
        option ip6assign '60'
        option force_link '1'

config interface 'wan'
        option ifname 'wwan0_1'
        option proto 'dhcp'
        option metric '1'

config interface 'wan6'
        option ifname 'wwan0_1'
        option proto 'dhcpv6'

config interface 'wan1'
        option proto 'qmi'
        option device '/dev/cdc-wdm0'
        option metric '10'
        option currmodem '1'
NETTY

rm -rf /overlay/upper/etc/firewall.user
cat > /overlay/upper/etc/firewall.user <<-FFE
#!/bin/sh
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
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
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
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
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
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
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64
FFW

echo -e "BYPASS SMP-TUNE"
chmod +x /overlay/upper/etc/hotplug.d/net/20-smp-tune
rm -rf /overlay/upper/etc/hotplug.d/net/20-smp-tune
rm -rf /overlay/upper/etc/hotplug.d/net/99-smp-tune
wget -O /overlay/upper/etc/hotplug.d/net/99-smp-tune https://raw.githubusercontent.com/d4rk442/tweak/main/99-smp-tune
chmod 755 /overlay/upper/etc/hotplug.d/net/99-smp-tune

chmod +x /etc/hotplug.d/net/20-smp-tune
rm -rf /etc/hotplug.d/net/20-smp-tune
rm -rf /etc/hotplug.d/net/99-smp-tune
wget -O /etc/hotplug.d/net/99-smp-tune https://raw.githubusercontent.com/d4rk442/tweak/main/99-smp-tune
chmod 755 /etc/hotplug.d/net/99-smp-tune

echo -e "BYPASS IRQBALANCE"
rm -rf /etc/config/irqbalance
cat > /etc/config/irqbalance <<-IRQ
config irqbalance 'irqbalance'
             option enable '1'

             option interval '1'
IRQ
chmod 755 /etc/config/irqbalance

echo -e "TUNING NETWORK"
rm -rf /etc/rc.local
cat > /etc/rc.local <<-RCD
#!/bin/sh -e
# rc.local
# By default this script does nothing.
/etc/init.d/irqbalance start
#/etc/init.d/passwall start
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo ondemand > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
sysctl net.core.default_qdisc=cake
sysctl net.ipv4.tcp_congestion_control=bbr
exit 0
RCD
chmod +x /etc/rc.local
/etc/rc.local enable
/etc/rc.local start

echo -e "FINISH SCRIPT REBOOT............"

rm -rf /root/*
