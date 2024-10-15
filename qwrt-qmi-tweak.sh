echo -e "SCRIPT-START"
rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 1.1.1.2
nameserver 1.0.0.2
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
opkg remove --autoremove luci-i18n-openvpn-server-zh-cn
opkg remove --autoremove luci-i18n-openvpn-*
opkg remove --autoremove luci-i18n-ipsec-server-zh-cn
opkg remove --autoremove luci-app-ipsec-server*

opkg install nano
opkg install sudo
opkg install curl
opkg install htop
opkg install irqbalance

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
uci set network.wan.ifname='wwan0_1';
uci commit network.wan;
uci set network.wan6.ifname='wwan0_1';
uci commit network.wan6;
uci set network.lan.dns='1.1.1.1 2606:4700:4700::1111';
uci commit network.lan;
uci commit firewall;
uci set network.globals.packet_steering=1;
uci commit network;
uci set network.wan1.peerdns='0';
uci delete network.wan1.dns;
uci commit network.wan1;
uci set network.wan.peerdns='0';
uci delete network.wan.dns;
uci commit network.wan;
uci set network.wan6.peerdns='0';
uci delete network.wan6.dns;
uci commit network.wan6;

echo -e "BYPASS-DNSMASQ"
rm -rf /etc/config/dhcp-opkg
rm -rf /etc/config/dhcp.save
rm -rf /etc/dnsmasq.conf
cat > /etc/dnsmasq.conf <<-DNSMASQ
#!/usr/bin/env bash
bind-dynamic
bogus-priv
log-facility=-
local-ttl=60
interface=*
DNSMASQ

echo -e "BYPASS-TTL"
cat > /etc/firewall.d/firewall.user <<-TTL
iptables -t mangle -F
ip6tables -t mangle -F
ip6tables -t mangle -I POSTROUTING -o wwan0 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j HL --hl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j HL --hl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTL
chmod 755 /etc/firewall.d/firewall.user
uci commit firewall

cat /dev/ttyUSB2 &
echo "AT+CMGR=1" > /dev/ttyUSB2
echo "AT+CFUN=1" > /dev/ttyUSB2

echo -e "TWEAK-SPEED-SYSCTL"
rm -rf /etc/sysctl.d/10-default.conf
cat > /etc/sysctl.d/10-default.conf <<-DEF
kernel.panic=3
kernel.core_pattern=/tmp/%e.%t.%p.%s.core
fs.suid_dumpable=2

fs.protected_hardlinks=1
fs.protected_symlinks=1

net.ipv4.conf.default.arp_ignore=1
net.ipv4.conf.all.arp_ignore=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.igmp_max_memberships=100
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_keepalive_time=120
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_timestamps=1                                                                 net.ipv4.tcp_sack=1
net.ipv4.tcp_dsack=1

net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.all.disable_ipv6=0
net.ipv6.conf.default.disable_ipv6=0
DEF

rm -rf /etc/sysctl.d/11-nf-conntrack.conf
cat > /etc/sysctl.d/11-nf-conntrack.conf <<-CONS
net.netfilter.nf_conntrack_acct=1
net.netfilter.nf_conntrack_checksum=0
net.netfilter.nf_conntrack_max=65535
net.netfilter.nf_conntrack_expect_max=65535
net.netfilter.nf_conntrack_tcp_timeout_time_wait=30
net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30
net.netfilter.nf_conntrack_tcp_timeout_established=7440
net.netfilter.nf_conntrack_udp_timeout=60
net.netfilter.nf_conntrack_udp_timeout_stream=180
CONS

rm -rf /etc/sysctl.d/custom-bbr.conf
cat > /etc/sysctl.d/custom-bbr.conf <<-BBR
net.core.rmem_default=65536
net.core.wmem_default=65536
net.core.optmem_max=65535
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_rmem=4096 65536 16777216
net.ipv4.tcp_mem=4096 65536 16777216
net.ipv4.udp_mem=4096 65536 16777216
net.ipv4.udp_rmem_min=4096
net.ipv4.udp_wmem_min=4096
net.core.netdev_max_backlog=3000
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_moderate_rcvbuf=1
BBR

echo -e "INSTALL-PASSWALL"
wget https://github.com/d4rk442/tweak/raw/refs/heads/main/xray-core_1.7.2-1_aarch64_cortex-a53.ipk
opkg install xray-core_1.7.2-1_aarch64_cortex-a53.ipk
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
rm -rf /etc/rc.local
cat > /etc/rc.local <<-RCD
#TWEAK
sysctl net.ipv4.tcp_congestion_control=bbr
echo f > /sys/class/net/br-lan/queues/rx-0/rps_cpus
echo f > /sys/class/net/wwan0/queues/rx-0/rps_cpus
echo f > /sys/class/net/wwan0_1/queues/rx-0/rps_cpus
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
exit 0
RCD

rm -rf /etc/config/wireless
cat > /etc/config/wireless <<-WIFI

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
        option ssid 'WK-VISTANA-5G'
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
        option ssid 'WK-VISTANA-2.4'
        option encryption 'psk'
        option key '112233445566'
WIFI

chmod +x /etc/rc.local
/etc/rc.local enable

rm -rf /root/*
reboot
echo -e "FINISH SCRIPT REBOOT............"
