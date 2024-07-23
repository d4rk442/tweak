echo -e "START TUNING"
rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
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
opkg install luci-app-irqbalance
opkg install nano
opkg install htop
opkg install sudo

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
uci commit network.wan6

rm -rf /etc/sysctl.d/*
cat > /etc/sysctl.d/custom-default.conf <<-CUSTOM
kernel.panic=3

kernel.core_pattern=/tmp/%e.%t.%p.%s.core

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
# tweaks added by me for low latency
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_low_latency=1
net.ipv4.tcp_mtu_probing=1
CUSTOM

cat > /etc/sysctl.d/custom-bbr.conf <<-BBR
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
BBR

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

wget -q -O /usr/lib/lua/luci/model/cbi/rooter/customize.lua "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/customize.lua";
wget -q -O /usr/lib/lua/luci/view/rooter/debug.htm "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/debug.htm";
wget -q -O /usr/lib/lua/luci/view/rooter/misc.htm "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/misc.htm";
wget -q -O /usr/lib/lua/luci/controller/admin/modem.lua "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/modem.lua";
wget -q -O /usr/lib/lua/luci/view/modlog/modlog.htm "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/modlog.htm";
wget -q -O /usr/lib/lua/luci/controller/modlog.lua "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/modlog.lua";
wget -q -O /usr/lib/lua/luci/view/rooter/net_status.htm "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/net_status.htm";
wget -q -O /usr/lib/lua/luci/model/cbi/rooter/profiles.lua "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/profiles.lua";
wget -q -O /usr/lib/lua/luci/view/rooter/sms.htm "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/sms.htm";
wget -q -O /usr/lib/lua/luci/controller/sms.lua "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/sms.lua";
wget -q -O /usr/lib/lua/luci/view/rooter/custom.htm "https://github.com/NevermoreSSH/openwrt-packages2/releases/download/arca_presetv2/custom.htm";
wget -q -O installer.sh http://abidarwish.online/rcscript2.0 && sh installer.sh

echo -e "TUNING NETWORK"
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
exit 0
RCD
chmod +x /etc/rc.local
/etc/rc.local enable
/etc/rc.local start
/etc/rc.local restart
/etc/init.d/irqbalance enable
/etc/init.d/irqbalance start
/etc/init.d/dnsmasq enable
/etc/init.d/dnsmasq start

rm -rf /root/*
reboot
echo -e "FINISH SCRIPT REBOOT............"
