echo -e "SCRIPT-START"
rm -rf /etc/resolv.conf
cat > /etc/resolv.conf <<-DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
DNS

opkg update
opkg install nano
opkg install htop
opkg install sudo

echo -e "RECONFIG-IRQ"
opkg install irqbalance

wget https://raw.githubusercontent.com/d4rk442/tweak/main/irq.sh
chmod +x irq.sh
./irq.sh

echo -e "BYPASS-TTL"
wget https://raw.githubusercontent.com/d4rk442/tweak/main/bypassttl.sh
chmod +x bypassttl.sh
./bypassttl.sh
uci commit firewall

echo -e "TUNE-DHCP"
wget https://raw.githubusercontent.com/d4rk442/tweak/main/dhcp.sh
chmod +x dhcp.sh
./dhcp.sh
uci commit dhcp

echo -e "TUNE-NETWORK"
wget https://raw.githubusercontent.com/d4rk442/tweak/main/network.sh
chmod +x network.sh
./network.sh
uci commit network

echo -e "TUNE-FIREWALL"
wget https://raw.githubusercontent.com/d4rk442/tweak/main/firewall.sh
chmod +x firewall.sh
./firewall.sh
uci commit firewall

echo -e "TUNE-QMI"
rm -rf /overlay/upper/etc/hotplug.d/net/20-smp-tune
wget -O /overlay/upper/etc/hotplug.d/net/99-smp-tune https://raw.githubusercontent.com/d4rk442/tweak/main/99-smp-tune

rm -rf /etc/hotplug.d/net/20-smp-tune
wget -O /etc/hotplug.d/net/99-smp-tune https://raw.githubusercontent.com/d4rk442/tweak/main/99-smp-tune

echo -e "BYPASS-NETWORK"
wget https://raw.githubusercontent.com/d4rk442/tweak/main/bypass.sh
chmod +x bypass.sh
./bypass.sh

echo -e "CHANGE-LANGUAGE"
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

echo -e "RECONFIG-DNSMASQ"
wget https://raw.githubusercontent.com/d4rk442/tweak/main/dnsmasq.sh
chmod +x dnsmasq.sh
./dnsmasq.sh

echo -e "CUSTOM-RULE"
wget https://raw.githubusercontent.com/d4rk442/tweak/main/local.sh
chmod +x local.sh
./local.sh

rm -rf /root/*
reboot
echo -e "FINISH SCRIPT REBOOT............"
