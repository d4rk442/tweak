#!/usr/bin/env bash

echo -e "SCRIPT-START"
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 1.1.1.1
nameserver 1.0.0.1
DNS

echo -e "MANAGE-SYSTEM"
rm -f /etc/config/system
cat > /etc/config/system <<-SYST
config system
        option hostname 'QWRT'
        option ttylogin '0'
        option log_size '64'
        option urandom_seed '0'
        option timezone 'MYT-8'
        option zonename 'Asia/Kuala Lumpur'

config timeserver 'ntp'
        option enabled '1'
        option enable_server '0'
        list server '0.openwrt.pool.ntp.org'
        list server '1.openwrt.pool.ntp.org'
        list server '2.openwrt.pool.ntp.org'
        list server '3.openwrt.pool.ntp.org'
SYST
chmod +x /etc/config/system;

echo -e "CHANGE-FEEDS"
rm -f /etc/opkg/distfeeds.conf
cat > /etc/opkg/distfeeds.conf <<-DIST
src/gz openwrt_base https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/base
src/gz openwrt_luci https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://downloads.immortalwrt.org/releases/21.02-SNAPSHOT/packages/aarch64_cortex-a53/telephony
DIST
chmod +x /etc/opkg/distfeeds.conf;

echo -e "REMOVE-BASIC"
opkg update
opkg remove luci-i18n-openvpn-server-zh-cn --autoremove
opkg remove luci-app-openvpn-* --autoremove
opkg remove luci-i18n-sqm-* --autoremove
opkg remove luci-app-sqm --autoremove
opkg remove sqm-scripts --autoremove
opkg remove luci-i18n-turboacc-* --autoremove
opkg remove luci-app-turboacc --autoremove

echo -e "BYPASS-DNSMASQ"
rm -f /etc/config/dhcp-opkg
rm -f /etc/config/dhcp.save
rm -f /etc/dnsmasq.conf
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
chmod +x /etc/dnsmasq.conf

echo -e "INSTALL-BASIC"
opkg update
opkg install sudo nano curl htop vsftpd
opkg install isc-dhcp-client-ipv6 --force-overwrite
opkg install isc-dhcp-server-ipv6 --force-overwrite
opkg install isc-dhcp-relay-ipv6 --force-overwrite

echo -e "PATCH-FIREWALL"
rm -f /etc/config/firewall
wget -q -O  /etc/config/firewall "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/firewall";
chmod +x  /etc/config/firewall;
uci commit firewall

echo -e "CHANGE-SYS-MODEM"
uci set cpufreq.cpufreq.governor=ondemand;
uci set cpufreq.cpufreq.minifreq=2208000;
uci commit cpufreq;
uci set system.@system[0].zonename='Asia/Kuala Lumpur';
uci set system.@system[0].timezone='MYT-8';
uci commit system;
uci set luci.main.lang='auto';
uci commit luci.main;
uci -q delete system.ntp.server;
uci add_list system.ntp.server='0.openwrt.pool.ntp.org';
uci add_list system.ntp.server='1.openwrt.pool.ntp.org';
uci add_list system.ntp.server='2.openwrt.pool.ntp.org';
uci add_list system.ntp.server='3.openwrt.pool.ntp.org';
uci commit system.ntp;
/etc/init.d/sysntpd restart;
uci set network.globals.packet_steering=0;
uci commit network
uci set firewall.@defaults[0].flow_offloading='0';
uci set firewall.@defaults[0].flow_offloading_hw='0';
uci commit firewall;
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

echo -e "PATCH-SMP"
rm -f /etc/hotplug.d/net/20-smp-tune
wget -q -O /etc/hotplug.d/net/20-smp-tune "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/20-smp-tune";
chmod +x /etc/hotplug.d/net/20-smp-tune;

echo -e "PATCH-BOOT"
rm -f /etc/init.d/boot
wget -q -O /etc/init.d/boot "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/boot";
chmod +x /etc/init.d/boot;

echo -e "PATCH-ROOTER"
rm -f /etc/init.d/rooter
wget -q -O /etc/init.d/rooter "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/rooter";
chmod +x /etc/init.d/rooter;

echo -e "NSS-INIT"
rm -f /etc/init.d/qca-nss-ecm
wget -q -O /etc/init.d/qca-nss-ecm "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/qca-nss-ecm.init";
chmod +x /etc/init.d/qca-nss-ecm;

echo -e "FIREWALL-NSS"
rm -f /etc/firewall.d/qca-nss-ecm
wget -q -O /etc/firewall.d/qca-nss-ecm "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/qca-nss-ecm";
chmod +x /etc/firewall.d/qca-nss-ecm;

echo -e "SETTING-DHCP.SCRIPT"
rm -f /lib/netifd/dhcp.script
wget -q -O /lib/netifd/dhcp.script "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/dhcp.script";
chmod +x /lib/netifd/dhcp.script;

echo -e "CPU-BOOST"
rm -f /etc/init.d/cpu-boost
wget -q -O /etc/init.d/cpu-boost "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/cpu-boost";
chmod +x /etc/init.d/cpu-boost;

echo -e "SETTING-RCLOCAL"
rm -f /etc/rc.local
wget -q -O /etc/rc.local "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/rc.local";
chmod +x /etc/rc.local;

echo -e "BYPASS-TTL"
rm -f /etc/init.d/firewall-custom
wget -q -O /etc/init.d/firewall-custom "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/firewall-custom";
chmod +x /etc/init.d/firewall-custom;

echo -e "INSTALL-OOKLA"
rm -f /usr/bin/speedtest
wget -q -O /usr/bin/speedtest "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/speedtest"
chmod +x /usr/bin/speedtest;

echo -e "TRANSLATING-MODEM"
wget -q -O /usr/lib/lua/luci/model/cbi/rooter/customize.lua "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/customize.lua";
chmod +x /usr/lib/lua/luci/model/cbi/rooter/customize.lua;
wget -q -O /usr/lib/lua/luci/view/rooter/debug.htm "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/debug.htm";
chmod +x /usr/lib/lua/luci/view/rooter/debug.htm;
wget -q -O /usr/lib/lua/luci/view/rooter/misc.htm "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/misc.htm";
chmod +x /usr/lib/lua/luci/view/rooter/misc.htm;
wget -q -O /usr/lib/lua/luci/controller/admin/modem.lua "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/modem.lua";
chmod +x /usr/lib/lua/luci/controller/admin/modem.lua;
wget -q -O /usr/lib/lua/luci/view/modlog/modlog.htm "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/modlog.htm";
chmod +x /usr/lib/lua/luci/view/modlog/modlog.htm;
wget -q -O /usr/lib/lua/luci/controller/modlog.lua "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/modlog.lua";
chmod +x /usr/lib/lua/luci/controller/modlog.lua;
wget -q -O /usr/lib/lua/luci/view/rooter/net_status.htm "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/net_status.htm";
chmod +x /usr/lib/lua/luci/view/rooter/net_status.htm;
wget -q -O /usr/lib/lua/luci/model/cbi/rooter/profiles.lua "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/profiles.lua";
chmod +x /usr/lib/lua/luci/model/cbi/rooter/profiles.lua;
wget -q -O /usr/lib/lua/luci/view/rooter/sms.htm "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/sms.htm";
chmod +x /usr/lib/lua/luci/view/rooter/sms.htm;
wget -q -O /usr/lib/lua/luci/controller/sms.lua "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/sms.lua";
chmod +x /usr/lib/lua/luci/controller/sms.lua;
wget -q -O /usr/lib/lua/luci/view/rooter/custom.htm "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/custom.htm";
chmod +x /usr/lib/lua/luci/view/rooter/custom.htm;

echo -e "TWEAK-SPEED-SYSCTL"
rm -f /etc/sysctl.d/10-default.conf
cat > /etc/sysctl.d/10-default.conf <<-DEF
kernel.panic=3
kernel.core_pattern=/tmp/%e.%t.%p.%s.core

net.ipv4.conf.default.arp_ignore=1
net.ipv4.conf.all.arp_ignore=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_errors_use_inbound_ifaddr=0
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_keepalive_time=120
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_dsack=1

net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
DEF
chmod +x /etc/sysctl.d/10-default.conf;

rm -f /etc/sysctl.d/11-nf-conntrack.conf
cat > /etc/sysctl.d/11-nf-conntrack.conf <<-DNF
net.netfilter.nf_conntrack_acct=1
net.netfilter.nf_conntrack_checksum=0
net.netfilter.nf_conntrack_max=16384
net.netfilter.nf_conntrack_expect_max=16384
net.netfilter.nf_conntrack_tcp_no_window_check=1
net.netfilter.nf_conntrack_tcp_timeout_established=3600
net.netfilter.nf_conntrack_udp_timeout=60
net.netfilter.nf_conntrack_udp_timeout_stream=180
DNF
chmod +x /etc/sysctl.d/11-nf-conntrack.conf;

rm -f /etc/sysctl.d/12-tcp-bbr.conf
cat > /etc/sysctl.d/12-tcp-bbr.conf <<-POPS
net.core.default_qdisc=fq_codel
net.ipv4.tcp_congestion_control=bbr
POPS
chmod +x /etc/sysctl.d/12-tcp-bbr.conf;

echo -e "INSTALL-XRAYMOD"
wget -q "https://github.com/d4rk442/tweak/raw/refs/heads/main/xray-core_1.7.2-1_aarch64_cortex-a53.ipk";
opkg install xray-core_1.7.2-1_aarch64_cortex-a53.ipk;

echo -e "INSTALL-PASSWALL"
wget -q "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/luci-app-passwall_4.66-8_all.ipk";
opkg install luci-app-passwall_4.66-8_all.ipk;

rm -f /etc/openwrt_release
cat > /etc/openwrt_release <<-IDD
DISTRIB_ID='OpenWrt'
DISTRIB_RELEASE='21.02-SNAPSHOT'
DISTRIB_TARGET='ipq807x/generic'
DISTRIB_ARCH='aarch64_cortex-a53'
DISTRIB_TAINTS='no-all busybox'
DISTRIB_REVISION='Dyno Tweak V1'
DISTRIB_DESCRIPTION='QWRT '
IDD
chmod +x /etc/openwrt_release

echo -e "MANAGE-WIFI"
rm -f /etc/config/wireless
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
chmod +x /etc/config/wireless;

echo -e "SCRIPT-FINISHING"
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 127.0.0.1
DNS


echo -e "FINISHING.........................."
uci commit
uci commit firewall
uci commit network
uci commit wireless
/etc/init.d/cpu-boost enable
/etc/init.d/cpu-boost start
/etc/init.d/firewall-custom enable
/etc/init.d/firewall-custom start
/etc/init.d/dnsmasq enable
/etc/init.d/dnsmasq start
/etc/init.d/openclash disable
/etc/init.d/pppoe-server disable
rm -f /etc/init.d/pppoe-server
/etc/init.d/pppoe-relay disable
rm -f /etc/init.d/pppoe-relay
/etc/init.d/qca-nss-ipsec disable
rm -f /etc/init.d/qca-nss-ipsec
/etc/init.d/qca-nss-ovpn disable
rm -f /etc/init.d/qca-nss-ovpn
/etc/rc.local enable
/etc/rc.local start

rm -f /root/*
echo -e "FINISH SCRIPT REBOOT............"
reboot
