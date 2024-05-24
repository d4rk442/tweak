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
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
done
ROOTTTL

rm -rf /overlay/upper/etc/ttl.user
cat > /overlay/upper/etc/ttl.user <<-TTLETC
# TTL Setting
#
#IPV4 TTL
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTLETC

rm -rf /overlay/upper/etc/ttl.user.bk
cat > /overlay/upper/etc/ttl.user.bk <<-TTLBK
# TTL Setting
#
#IPV4 TTL
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTLBK

rm -rf /etc/ttl.user
cat > /etc/ttl.user <<-TTLUSER
# TTL Setting
#
#IPV4 TTL
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTLUSER

rm -rf /etc/ttl.user.bk
cat > /etc/ttl.user.bk <<-TTLUSERBK
# TTL Setting
#
#IPV4 TTL
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
TTLUSERBK

rm -rf /overlay/upper/etc/firewall.user
cat > /overlay/upper/etc/firewall.user <<-FFE
#!/bin/sh
#IPV4 TTL
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
FFE

rm -rf /etc/firewall.user
cat > /etc/firewall.user <<-FFW
#!/bin/sh
#IPV4 TTL
iptables -t mangle -I POSTROUTING -o br-lan -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
iptables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i br-lan -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -j TTL --ttl-set 64
#IPV6 TTL
ip6tables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING -o wwan0_1 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set 64
ip6tables -t mangle -I PREROUTING -i wwan0_1 -j TTL --ttl-set 64
FFW

echo -e "TWEAK SYSCTL"
rm -rf /etc/sysctl.conf
cat > /etc/sysctl.conf <<-SYS1
#
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
#
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
        option multicast_querier '0'
        option igmp_snooping '0'
        option ip6assign '60'
        option force_link '1'

config interface 'wan'
        option ifname 'wwan0_1'
        option proto 'dhcp'
        option dns '1.1.1.1 1.0.0.1'
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
        option multicast_querier '0'
        option igmp_snooping '0'
        option ip6assign '60'
        option force_link '1'

config interface 'wan'
        option ifname 'wwan0_1'
        option proto 'dhcp'
        option dns '1.1.1.1 1.0.0.1'
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
#sysctl -w net.ipv6.conf.all.disable_ipv6=1
#sysctl -w net.ipv6.conf.default.disable_ipv6=1
#### add delay prior to application
#sleep 10
modprobe dns_resolver
modprobe tcp_bbr
#modprobe cake
modprobe bfq
modprobe nft_flow_offload
modprobe lib80211
modprobe lib80211_crypt_ccmp
modprobe loop
#systemctl start firewalld
#### extras
/etc/init.d/irqbalance start
echo fq_codel > /proc/sys/net/core/default_qdisc
#sysctl net.ipv4.tcp_fastopen=3
#sysctl net.core.busy_read=50
sysctl net.ipv4.tcp_slow_start_after_idle=0

echo "1" /proc/sys/fs/leases-enable
echo "0" > /proc/sys/fs/dir-notify-enable
echo "20" > /proc/sys/fs/lease-break-time
echo "0" > /proc/sys/vm/overcommit_memory

sudo echo always > /sys/kernel/mm/transparent_hugepage/enabled
sudo echo always > /sys/kernel/mm/transparent_hugepage/defrag

sysctl -w kernel.sched_scaling_enable=1
sysctl sched_scaling_enable=1
sysctl sched_tunable_scaling=2
sysctl /proc/sys/kernel/sched_child_runs_first=1
#sysctl /proc/sys/kernel/sched_min_granularity_ns=1000000
#sysctl /proc/sys/kernel/sched_wakeup_granularity_ns=2000000
sysctl /proc/sys/kernel/sched_latency_ns=40000

sudo apparmor_parser -r /etc/apparmor.d/*snap-confine*
sudo apparmor_parser -r /var/lib/snapd/apparmor/profiles/snap-confine*
systemctl enable --now apparmor.service

###### CONFIGURE SCHEDULER
################################
### currently [none], [kyber], [bfq], [mq-deadline]
#$(sudo fdisk -l | grep '^/dev/[a-z]*[0-9]' | awk '$2 == "*"' | cut -d" " -f1 | cut -c1-8)
for i in $(find /sys/block -type l); do
  echo "bfq" > $i/queue/scheduler;
  echo "0" > $i/queue/add_random;
  echo "0" > $i/queue/iostats;
  echo "0" > $i/queue/io_poll
  echo "2" > $i/queue/nomerges
  echo "512" > $i/queue/nr_requests
  echo "4096" > $i/queue/read_ahead_kb
  echo "0" > $i/queue/rotational
  echo "2" > $i/queue/rq_affinity
  echo "write through" > $i/queue/write_cache
  echo "4" > $i/queue/iosched/quantum
  echo "80" > $i/queue/iosched/fifo_expire_sync
  echo "330" > $i/queue/iosched/fifo_expire_async
  echo "12582912" > $i/queue/iosched/back_seek_max
  echo "1" > $i/queue/iosched/back_seek_penalty
  echo "60" > $i/queue/iosched/slice_sync
  echo "50" > $i/queue/iosched/slice_async
  echo "2" > $i/queue/iosched/slice_async_rq
  echo "0" > $i/queue/iosched/slice_idle
  echo "0" > $i/queue/iosched/group_idle
  echo "1" > $i/queue/iosched/low_latency
  echo "100" > $i/queue/iosched/target_latency
done;

echo "write through" | sudo tee /sys/block/*/queue/write_cache

###### FILESYSTEM
################################
echo "0" > /proc/sys/fs/dir-notify-enable
echo "20" > /proc/sys/fs/lease-break-time
echo "1" > /proc/sys/vm/compact_unevictable_allowed
echo "5" > /proc/sys/vm/dirty_background_ratio
echo "12000" > /proc/sys/vm/dirty_expire_centisecs
echo "80" > /proc/sys/vm/dirty_ratio
echo "3000" > /proc/sys/vm/dirty_writeback_centisecs
echo "1" > /proc/sys/vm/oom_dump_tasks
echo "1" > /proc/sys/vm/oom_kill_allocating_task
echo "1200" > /proc/sys/vm/stat_interval
echo "10" > /proc/sys/vm/vfs_cache_pressure
echo "0" > /proc/sys/vm/swappiness

### IMPROVE SYSTEM MEMORY MANAGEMENT ###
# Increase size of file handles and inode cache
sysctl fs.file-max=2097152
### GENERAL NETWORK SECURITY OPTIONS ###
# Number of times SYNACKs for passive TCP connection.
#sysctl net.ipv4.tcp_synack_retries=2
# Allowed local port range
sysctl net.ipv4.ip_local_port_range=2000 65535
# Protect Against TCP Time-Wait
#sysctl net.ipv4.tcp_rfc1337=1
# Decrease the time default value for tcp_fin_timeout connection
sysctl net.ipv4.tcp_fin_timeout=15
# Decrease the time default value for connections to keep alive
sysctl net.ipv4.tcp_keepalive_time=300
sysctl net.ipv4.tcp_keepalive_probes=5
sysctl net.ipv4.tcp_keepalive_intvl=15
### TUNING NETWORK PERFORMANCE ###
# Default Socket Receive Buffer
#sysctl net.core.rmem_default=31457280
# Maximum Socket Receive Buffer
#sysctl net.core.rmem_max=12582912
# Default Socket Send Buffer
#sysctl net.core.wmem_default=31457280
# Maximum Socket Send Buffer
#sysctl net.core.wmem_max=12582912
# Increase number of incoming connections
#sysctl net.core.somaxconn=4096
# Increase number of incoming connections backlog
#sysctl net.core.netdev_max_backlog=65536
# Increase the maximum amount of option memory buffers
#sysctl net.core.optmem_max=25165824
# Increase the maximum total buffer-space allocatable
# This is measured in units of pages (4096 bytes)
#sysctl net.ipv4.tcp_mem=65536 131072 262144
#sysctl net.ipv4.udp_mem=65536 131072 262144
# Increase the read-buffer space allocatable
#sysctl net.ipv4.tcp_rmem=8192 87380 16777216
#sysctl net.ipv4.udp_rmem_min=16384
# Increase the write-buffer-space allocatable
#sysctl net.ipv4.tcp_wmem=8192 65536 16777216
#sysctl net.ipv4.udp_wmem_min=16384
# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
#sysctl net.ipv4.tcp_max_tw_buckets=1440000
#sysctl net.ipv4.tcp_tw_recycle=1
#sysctl net.ipv4.tcp_tw_reuse=1

sysctl fs.xfs.xfssyncd_centisecs=10000

###### CPU
################################
### governor
function setgov ()
{
    echo "performance" | sudo tee /sys/devices/system/cpu/cpufreq/policy*/scaling_governor
}
### workqueues
chmod 666 /sys/module/workqueue/parameters/power_efficient
chown root /sys/module/workqueue/parameters/power_efficient
bash -c 'echo "N"  > /sys/module/workqueue/parameters/power_efficient'

###### EXTRAS
################################
### kernel panic
sysctl -e -w kernel.panic_on_oops=0
sysctl -e -w kernel.panic=0
### rcu
echo "0" > /sys/kernel/rcu_expedited
echo "1" > /sys/kernel/rcu_normal
### entropy
echo "96" > /proc/sys/kernel/random/urandom_min_reseed_secs
echo "1024" > /proc/sys/kernel/random/write_wakeup_threshold
### hibernation
#echo "deep" > /sys/power/mem_sleep
### extras
echo "Y" > /sys/module/cryptomgr/parameters/notests
echo "1" > /sys/module/hid/parameters/ignore_special_drivers
echo "N" > /sys/module/drm_kms_helper/parameters/poll
echo "N" > /sys/module/printk/parameters/always_kmsg_dump

###### TCP SETTINGS
################################
echo "128" > /proc/sys/net/core/netdev_max_backlog
echo "0" > /proc/sys/net/core/netdev_tstamp_prequeue
echo "0" > /proc/sys/net/ipv4/cipso_cache_bucket_size
echo "0" > /proc/sys/net/ipv4/cipso_cache_enable
echo "0" > /proc/sys/net/ipv4/cipso_rbm_strictvalid
echo "0" > /proc/sys/net/ipv4/igmp_link_local_mcast_reports
echo "24" > /proc/sys/net/ipv4/ipfrag_time
echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control
echo "1" > /proc/sys/net/ipv4/tcp_ecn
echo "0" > /proc/sys/net/ipv4/tcp_fwmark_accept
echo "320" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "21600" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "1800" > /proc/sys/net/ipv4/tcp_probe_interval
echo "1" > /proc/sys/net/ipv4/tcp_no_metrics_save
echo "0" > /proc/sys/net/ipv4/tcp_slow_start_after_idle
echo "0" > /proc/sys/net/ipv6/calipso_cache_bucket_size
echo "0" > /proc/sys/net/ipv6/calipso_cache_enable
echo "48" > /proc/sys/net/ipv6/ip6frag_time

echo "1" > /proc/sys/net/ipv4/net.ipv4.tcp_rfc1337
echo "1" > /proc/sys/net/ipv4/net.ipv4.tcp_window_scaling
echo "1" > /proc/sys/net/ipv4/net.ipv4.tcp_workaround_signed_windows
echo "1" > /proc/sys/net/ipv4/net.ipv4.tcp_sack
echo "1" > /proc/sys/net/ipv4/net.ipv4.tcp_fack
echo "1" > /proc/sys/net/ipv4/net.ipv4.tcp_low_latency
echo "0" > /proc/sys/net/ipv4/net.ipv4.ip_no_pmtu_disc
echo "1" > /proc/sys/net/ipv4/net.ipv4.tcp_mtu_probing
echo "2" > /proc/sys/net/ipv4/net.ipv4.tcp_frto
echo "2" > /proc/sys/net/ipv4/net.ipv4.tcp_frto_response

sysctl net.core.somaxconn=1000
sysctl net.core.netdev_max_backlog=5000
sysctl net.core.rmem_max=16777216
sysctl net.core.wmem_max=16777216
sysctl net.ipv4.tcp_wmem=4096 12582912 16777216
sysctl net.ipv4.tcp_rmem=4096 12582912 16777216
sysctl net.ipv4.tcp_max_syn_backlog=8096
sysctl net.ipv4.tcp_slow_start_after_idle=0
sysctl net.ipv4.tcp_tw_reuse=1
sysctl net.ipv4.ip_local_port_range=10240 65535

for i in $(find /sys/class/net -type l); do
  echo "128" > $i/tx_queue_len;
done;

###### OMIT DEBUGGING
################################
echo "0" > /proc/sys/debug/exception-trace
echo "0 0 0 0" > /proc/sys/kernel/printk

echo "Y" > /sys/module/printk/parameters/console_suspend

for i in $(find /sys/ -name debug_mask); do
echo "0" > $i;
done
for i in $(find /sys/ -name debug_level); do
echo "0" > $i;
done
for i in $(find /sys/ -name edac_mc_log_ce); do
echo "0" > $i;
done
for i in $(find /sys/ -name edac_mc_log_ue); do
echo "0" > $i;
done
for i in $(find /sys/ -name enable_event_log); do
echo "0" > $i;
done
for i in $(find /sys/ -name log_ecn_error); do
echo "0" > $i;
done
for i in $(find /sys/ -name snapshot_crashdumper); do
echo "0" > $i;
done
if [ -e /sys/module/logger/parameters/log_mode ]; then
 echo "2" > /sys/module/logger/parameters/log_mode
fi;

wl -i eth0 interference 3
wl -i eth1 interference 3
wl -i eth2 interference 3
ifconfig eth0 txqueuelen 2
ifconfig eth1 txqueuelen 2
ifconfig eth2 txqueuelen 2
echo 262144 > /proc/sys/net/core/rmem_max
echo 262144 > /proc/sys/net/core/wmem_max
echo "4096 16384 262144" > /proc/sys/net/ipv4/tcp_wmem
echo "4096 87380 262144" > /proc/sys/net/ipv4/tcp_rmem
echo 1000 > /proc/sys/net/core/netdev_max_backlog
echo 16384 > /proc/sys/net/ipv4/netfilter/ip_conntrack_max
echo 16384 > /sys/module/nf_conntrack/parameters/hashsize

#systemctl start fstrim.timer

echo 2 > /proc/irq/49/smp_affinity
echo 2 > /proc/irq/50/smp_affinity

###### END

exit 0
RCD

echo -e "FINISH SCRIPT REBOOT............"

rm -rf /root/*
reboot
