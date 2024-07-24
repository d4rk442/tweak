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
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
net.core.netdev_max_backlog=16384
net.core.somaxconn=4096
net.core.rmem_default=1048576
net.core.rmem_max=16777216
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
