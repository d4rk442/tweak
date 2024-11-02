#SCRIPT BYPASS TTL FW4/NFTABLES

cat > /etc/ttl64.user <<-TT64
#CUSTOM TTL64 FIREWALL BY DYNO

nft add rule inet fw4 mangle_prerouting iifname usb0 ip ttl set 64
nft add rule inet fw4 mangle_prerouting iifname wwan0 ip ttl set 64
nft add rule inet fw4 mangle_prerouting iifname wwan0_1 ip ttl set 64


nft add rule inet fw4 mangle_postrouting oifname usb0 ip ttl set 64
nft add rule inet fw4 mangle_postrouting oifname wwan0 ip ttl set 64
nft add rule inet fw4 mangle_postrouting oifname wwan0_1 ip ttl set 64
TT64
chmod 755 /etc/ttl64.user

cat > /etc/config/firewall <<-FWW64
#CUSTOM FIREWALL CONFIG

config defaults
	option syn_flood '1'
	option input 'REJECT'
	option output 'ACCEPT'
	option forward 'REJECT'
	option flow_offloading '1'
	option flow_offloading_hw '1'

config zone
	option name 'lan'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'
	list network 'lan'

config zone
	option name 'wan'
	option input 'REJECT'
	option output 'ACCEPT'
	option forward 'REJECT'
	option masq '1'
	option mtu_fix '1'
	list network '5g'

config forwarding
	option src 'lan'
	option dest 'wan'

config rule
	option name 'Allow-DHCP-Renew'
	option src 'wan'
	option proto 'udp'
	option dest_port '68'
	option target 'ACCEPT'
	option family 'ipv4'

config rule
	option name 'Allow-Ping'
	option src 'wan'
	option proto 'icmp'
	option icmp_type 'echo-request'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-IGMP'
	option src 'wan'
	option proto 'igmp'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-DHCPv6'
	option src 'wan'
	option proto 'udp'
	option dest_port '546'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-MLD'
	option src 'wan'
	option proto 'icmp'
	option src_ip 'fe80::/10'
	list icmp_type '130/0'
	list icmp_type '131/0'
	list icmp_type '132/0'
	list icmp_type '143/0'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Input'
	option src 'wan'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	list icmp_type 'router-solicitation'
	list icmp_type 'neighbour-solicitation'
	list icmp_type 'router-advertisement'
	list icmp_type 'neighbour-advertisement'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Forward'
	option src 'wan'
	option dest '*'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-IPSec-ESP'
	option src 'wan'
	option dest 'lan'
	option proto 'esp'
	option target 'ACCEPT'

config rule
	option name 'Allow-ISAKMP'
	option src 'wan'
	option dest 'lan'
	option dest_port '500'
	option proto 'udp'
	option target 'ACCEPT'

config include
	option path '/etc/ttl64.user'
	option fw4_compatible '1'
	option enabled '1'

config include 'qcanssecm'
	option type 'script'
	option path '/etc/firewall.d/qca-nss-ecm'

config include 'passwall'
	option type 'script'
	option path '/var/etc/passwall.include'
	option reload '1'

config include 'passwall_server'
	option type 'script'
	option path '/var/etc/passwall_server.include'
	option reload '1'
FWW64
chmod 755 /etc/config/firewall

rm -rf /etc/nftables.d/*
cat > /etc/nftables.d/11-mangle-ttl-64.nft <<-NFF64
#CUSTOM NFT TTL64 BY DYNO

chain mangle_postrouting_ttl64 {
     type filter hook postrouting priority 300; policy accept;
     counter ip ttl set 64
}

chain mangle_prerouting_ttl64 {
     type filter hook prerouting priority 300; policy accept;
      counter ip ttl set 64
}
NFF64
chmod 755 /etc/nftables.d/11-mangle-ttl-64.nft
uci commit firewall

/etc/init.d/firewall restart
rm -rf /root/nft-ttl64.sh
