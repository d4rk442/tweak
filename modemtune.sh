echo -e "START TUNING"

rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 1.1.1.1
nameserver 1.0.0.1
DNS

rm -rf /etc/opkg/distfeeds.conf
cat > /etc/opkg/distfeeds.conf <<-DIST
src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a53/base
src/gz openwrt_luci https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a53/telephony
DIST

opkg update
opkg install irqbalance
opkg install nano-full
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
rm -rf /overlay/upper/etc/mluci-i18n-ipsec-server-zh-cn
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
nameserver 1.1.1.1
nameserver 1.0.0.1
DNS

rm -rf /tmp/resolv.conf
cat > /tmp/resolv.conf <<-DNS
search lan
nameserver 127.0.0.1
nameserver ::1
DNS

echo -e "BYPASS TTL64"

uci set system.@system[0].zonename='Asia/Kuala Lumpur';uci commit system;uci set luci.main.lang='auto';uci commit luci.main;uci -q delete system.ntp.server;
uci add_list system.ntp.server='my.pool.ntp.org';uci add_list system.ntp.server='ntp.google.com';uci add_list system.ntp.server='ntp.windows.com';uci add_list system.ntp.server='ntp.cloudflare.com';uci commit system.ntp;/etc/init.d/sysntpd restart;uci set network.wan.ifname='wwan0_1';uci commit network.wan;uci set network.wan6.ifname='wwan0_1';uci commit network.wan6

rm -rf /etc/hotplug.d/iface/19-rooter
cat > /etc/hotplug.d/iface/19-rooter <<-ROOTTTL
#!/bin/sh
#
# /etc/hotplug.d/iface/19-rooter
#

log() {
         logger -t "19-ROOTER" "$@"
}

for I in `seq 1 $(uci get modem.general.modemnum)`
do
         IFACE="wan"$I

         [ "$ACTION" = ifup -o "$ACTION" = ifupdate ] || exit 0
         if [ ${INTERFACE} = "$IFACE" ]; then
                 if [ ${ACTION} = "ifup" ]; then
                         # TTL fix
                         if [ 1 = 0 ]; then
                                 ttl=$(uci -q get modem.modeminfo$I.ttl)
                                 if [ -z $ttl ]; then
                                         ttl=0
                                 fi
                                 if [ $ttl -eq 0 ]; then
                                         ENB=$(uci get ttl.ttl.enabled)
                                         if [ ! -z "$ENB" ]; then
                                                 #exst=$(cat /etc/firewall.user | grep " mangle .* $DEVICE " | wc -l)
                                                 #[ "$exst" -eq 4 ] || /usr/lib/custom/ttlx.sh
                                                 /usr/lib/custom/ttlx.sh
                                         fi
                                 fi
                         fi
                         MTU=$(uci get modem.modeminfo$I.mtu)
                         if [ -z $MTU ]; then
                                 MTU=1500
                         fi
                         if [ -n "$MTU" ]; then
                                 ip link set mtu $MTU dev $DEVICE
                                 logger -t "Custom MTU" $DEVICE set to $MTU
                         fi
                 fi
         fi
#IPV4 TTL
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -A POSTROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -A PREROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
done
ROOTTTL

rm -rf /overlay/upper/etc/ttl.user
cat > /overlay/upper/etc/ttl.user <<-TTLETC
# TTL Setting
#
#IPV4 TTL
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -A POSTROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -A PREROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTLETC

rm -rf /overlay/upper/etc/ttl.user.bk
cat > /overlay/upper/etc/ttl.user.bk <<-TTLBK
# TTL Setting
#
#IPV4 TTL
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -A POSTROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -A PREROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTLBK

rm -rf /etc/ttl.user
cat > /etc/ttl.user <<-TTLUSER
# TTL Setting
#
#IPV4 TTL
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -A POSTROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -A PREROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTLUSER

rm -rf /etc/ttl.user.bk
cat > /etc/ttl.user.bk <<-TTLUSERBK
# TTL Setting
#
#IPV4 TTL
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -A POSTROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -A PREROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTLUSERBK

rm -rf /overlay/upper/etc/firewall.user
cat > /overlay/upper/etc/firewall.user <<-FFE
#!/bin/sh
#IPV4 TTL
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -A POSTROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -A PREROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
FFE

rm -rf /etc/firewall.user
cat > /etc/firewall.user <<-FFW
#!/bin/sh
#IPV4 TTL
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -A POSTROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -A PREROUTING -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
FFW

echo -e "TWEAK SYSCTL"
rm -rf /etc/sysctl.conf
cat > /etc/sysctl.conf <<-SYS1
net.ipv4.ip_default_ttl=64
net.ipv6.conf.all.hop_limit = 64
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_retries2 = 6
net.ipv4.tcp_keepalive_probes = 4
net.netfilter.nf_conntrack_generic_timeout = 60
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_established = 600
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 30
net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 60
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 60
net.netfilter.nf_conntrack_udp_timeout_stream = 60
SYS1

rm -rf /overlay/upper/etc/sysctl.d/*
rm -rf /overlay/upper/etc/sysctl.d/qca-nss-ecm.conf
cat > /overlay/upper/etc/sysctl.d/qca-nss-ecm.conf <<-SYS2
#nf_conntrack_tcp_no_window_check is 0 by default, set it to 1
net.netfilter.nf_conntrack_tcp_no_window_check=1
net.netfilter.nf_conntrack_max=65535
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
SYS2

rm -rf /overlay/upper/etc/sysctl.d/99-tweaker.conf
cat > /overlay/upper/etc/sysctl.d/99-tweaker.conf <<-SYS
net.ipv4.ip_default_ttl=64
net.ipv6.conf.all.hop_limit = 64
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_retries2 = 6
net.ipv4.tcp_keepalive_probes = 4
net.netfilter.nf_conntrack_generic_timeout = 60
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_established = 600
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 30
net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 60
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 60
net.netfilter.nf_conntrack_udp_timeout_stream = 60
SYS
sysctl -p

echo -e "TUNING NETWORK"
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
        option dns '1.1.1.1 1.0.0.1'
        option multicast_querier '0'
        option igmp_snooping '0'
        option ip6assign '60'
        option force_link '1'

config interface 'wan'
        option ifname 'wwan0_1'
        option proto 'dhcp'
        option metric '1'
        option ttl '64'

config interface 'wan6'
        option ifname 'wwan0_1'
        option proto 'dhcpv6'
        option ttl '64'

config interface 'wan1'
        option proto 'dhcp'
        option _orig_bridge 'false'
        option metric '10'
        option ttl '64'
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
        option dns '1.1.1.1 1.0.0.1'
        option multicast_querier '0'
        option igmp_snooping '0'
        option ip6assign '60'
        option force_link '1'

config interface 'wan'
        option ifname 'wwan0_1'
        option proto 'dhcp'
        option metric '1'
        option ttl '64'

config interface 'wan6'
        option ifname 'wwan0_1'
        option proto 'dhcpv6'
        option ttl '64'

config interface 'wan1'
        option proto 'dhcp'
        option _orig_bridge 'false'
        option metric '10'
        option ttl '64'
NETTY

echo -e "BYPASS SMP-TUNE"
rm -rf /overlay/upper/etc/hotplug.d/net/20-smp-tune
rm -rf /overlay/upper/etc/hotplug.d/net/99-smp-tune
wget -O /overlay/upper/etc/hotplug.d/net/99-smp-tune https://raw.githubusercontent.com/d4rk442/tweak/main/99-smp-tune

rm -rf /etc/hotplug.d/net/20-smp-tune
rm -rf /etc/hotplug.d/net/99-smp-tune
wget -O /etc/hotplug.d/net/99-smp-tune https://raw.githubusercontent.com/d4rk442/tweak/main/99-smp-tune

echo -e "BYPASS IRQBALANCE"
rm -rf /etc/config/irqbalance
cat > /etc/config/irqbalance <<-IRQ
config irqbalance 'irqbalance'
             option enable '1'

             option interval '1'
IRQ

rm -rf /etc/rc.local
cat > /etc/rc.local <<-RCD
#!/bin/sh -e
# rc.local
# By default this script does nothing.
/etc/init.d/irqbalance start
exit 0
RCD
chmod +x /etc/rc.local
/etc/rc.local enable

echo -e "FINISH SCRIPT REBOOT............"

rm -rf /root/*
reboot
