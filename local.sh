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
/etc/init.d/irqbalance enable
/etc/init.d/dnsmasq enable
