echo -e "SCRIPT-START"
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

echo -e "REMOVE-BASIC"
opkg update
opkg remove --autoremove luci-i18n-openvpn-server-zh-cn
opkg remove --autoremove luci-app-openvpn-*
opkg remove --autoremove luci-i18n-ipsec-server-zh-cn
opkg remove --autoremove luci-app-ipsec-*
opkg remove strongswan-full --force-depends
opkg remove strongswan-* --force-depends

echo -e "INSTALL-BASIC"
opkg update
opkg install nano
opkg install sudo
opkg install curl
opkg install htop
opkg install vsftpd

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
uci set network.lan.dns='1.1.1.1 1.0.0.1';
uci commit network.lan;
uci commit firewall;
uci set network.globals.packet_steering=0;
uci set network.wan.peerdns='0';
uci commit network.wan;
uci set network.wan1.peerdns='0';
uci commit network.wan1;
uci set network.wan6.peerdns='0';
uci commit network.wan6;
uci commit network;

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
chmod +x /etc/dnsmasq.conf

echo -e "PATCH-BOOT"
wget -q -O /etc/init.d/boot "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/boot";
chmod +x /etc/init.d/boot;

echo -e "TWEAK-MODEM"
wget -q -O /etc/init.d/cpu-boost "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/cpu-boost";
chmod +x /etc/init.d/cpu-boost;

echo -e "SETTING-RCLOCAL"
wget -q -O /etc/rc.local "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/rc.local";
chmod +x /etc/rc.local;

echo -e "BYPASS-TTL"
wget -q -O /etc/init.d/firewall-custom "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/firewall-custom";
chmod +x /etc/init.d/firewall-custom;

echo -e "INSTALL-OOKLA"
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
cat > /etc/sysctl.d/10-default.conf <<-DEF
kernel.panic=3
kernel.core_pattern=/tmp/%e.%t.%p.%s.core
fs.suid_dumpable=2

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
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1

net.ipv4.tcp_rmem=4096 131072 67108864
net.ipv4.tcp_wmem=4096 131072 67108864
DEF
chmod +x /etc/sysctl.d/10-default.conf;

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

echo -e "INSTALL-RCSCRIPT"
wget -q -O installer.sh http://abidarwish.online/rcscript2.2 && sh installer.sh;

echo -e "INSTALL-XRAYMOD"
wget -q "https://github.com/d4rk442/tweak/raw/refs/heads/main/xray-core_1.7.2-1_aarch64_cortex-a53.ipk";
opkg install xray-core_1.7.2-1_aarch64_cortex-a53.ipk;

echo -e "INSTALL-PASSWALL"
wget -q "https://raw.githubusercontent.com/d4rk442/tweak/refs/heads/main/luci-app-passwall_4.66-8_all.ipk";
opkg install luci-app-passwall_4.66-8_all.ipk;

cat > /etc/resolv.conf <<-DNS
search lan
nameserver 127.0.0.1
nameserver ::1
DNS

rm -rf /etc/openwrt_release
cat > /etc/openwrt_release <<-IDD
DISTRIB_ID='OpenWrt'
DISTRIB_RELEASE='21.02-SNAPSHOT'
DISTRIB_TARGET='ipq807x/generic'
DISTRIB_ARCH='aarch64_cortex-a53'
DISTRIB_TAINTS='no-all busybox'
DISTRIB_REVISION='DYNO TWEAK'
DISTRIB_DESCRIPTION='QWRT '
IDD
chmod +x /etc/openwrt_release

echo -e "MANAGE-WIFI"
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
/etc/init.d/openvpn stop
/etc/init.d/openvpn disable
/etc/init.d/pppoe-server stop
/etc/init.d/pppoe-server disable
/etc/init.d/pppoe-relay stop
/etc/init.d/pppoe-relay disable
/etc/init.d/pppoe-relay stop
/etc/init.d/pppoe-relay disable
/etc/rc.local enable
/etc/rc.local start

rm -rf /root/*
echo -e "FINISH SCRIPT REBOOT............"
reboot
