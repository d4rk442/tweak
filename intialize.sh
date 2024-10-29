#!/bin/sh
. /lib/functions.sh

ROOTER=/usr/lib/rooter
ROOTER_LINK="/tmp/links"

echo "1546 1146" > /sys/bus/usb-serial/drivers/option1/new_id
echo "106c 3718" > /sys/bus/usb-serial/drivers/option1/new_id

CODENAME="ROOter "
if [ -f "/etc/codename" ]; then
	source /etc/codename
fi

MAX_MODEMS=1
MODCNT=$MAX_MODEMS

log() {
	modlog "STARTING MODEM" "$@"
}

do_zone() {
	local config=$1
	local name
	local network
     
    /etc/init.d/dnsmasq restart
    config_get network $1 network
    newnet=$network
	config_get name $1 name
	if [ $name = wan ]; then
		WAN1=$(echo $network | grep "wan1")
		if [ -z $WAN1 ]; then
			COUNTER=1
			while [ $COUNTER -le $MODCNT ]; do
				newnet="$newnet wan$COUNTER"
				let COUNTER=COUNTER+1
			done
			uci_set firewall "$config" network "$newnet"
			uci_commit firewall
			/etc/init.d/firewall restart
		fi
	fi
}

firstboot() {

	AP=$(uci -q get profile.default.apn)
	if [ -z "$AP" ]; then
		uci set profile.default.apn="internet"
		uci commit profile
	fi

	log "ROOter First Boot finalized"

	config_load firewall
	config_foreach do_zone zone

}

if [ -e /tmp/installing ]; then
	exit 0
fi


log " GETTING NETWORK"

mkdir -p $ROOTER_LINK

sed -i -e 's|/etc/savevar|#removed line|g' /etc/rc.local

[ -f "/etc/firstboot" ] || {
	firstboot
}

uci delete modem.Version
uci set modem.Version=version
uci set modem.Version.ver=$CODENAME
uci commit modem

PRO=$(uci -q get network.wan.proto)
if [ ! -z $PRO ]; then
	uci set network.wan.metric="1"
fi

SM=$(uci get modem.sms)
if [ -z $SM ]; then
	uci set modem.sms="sms"
	uci set modem.sms.menable="0"
	uci set modem.sms.slots="0"
fi

if [ -e /etc/config/failover ]; then
	uci delete failover.Wan
	EXX=$(uci get network.wan)
	if [ ! -z $EXX ]; then
		uci set failover.Wan=member
	fi
	uci delete failover.Hotspot
	uci set failover.Hotspot=member
	uci commit failover
	ENB=$(uci get failover.enabled.enabled)
	if [ $ENB = "1" ]; then
		if [ -e $ROOTER/connect/failover.sh ]; then
			log "Starting Failover System"
			$ROOTER/connect/failover.sh &
		fi
	fi
fi

uci commit modem
uci commit network

MODSTART=1
WWAN=0
USBN=0
ETHN=1
BASEPORT=0
WDMN=0
if
	ifconfig eth1 &>/dev/null
then
	if [ -e "/sys/class/net/eth1/device/bInterfaceProtocol" ]; then
		ETHN=1
	else
		ETHN=2
	fi
fi

COUNTER=1
while [ $COUNTER -le $MODCNT ]; do
	uci delete modem.modem$COUNTER
	uci set modem.modem$COUNTER=modem
	uci set modem.modem$COUNTER.empty=1

	IPEX=$(uci get modem.pinginfo$COUNTER.alive)
	if [ -z $IPEX ]; then
		uci set modem.pinginfo$COUNTER=pinfo$COUNTER
		uci set modem.pinginfo$COUNTER.alive="0"
	fi

	INEX=$(uci get modem.modeminfo$COUNTER)
	if [ -z $INEX ]; then
		uci set modem.modeminfo$COUNTER=minfo$COUNTER
	fi

	rm -f $ROOTER_LINK/getsignal$COUNTER
	rm -f $ROOTER_LINK/reconnect$COUNTER
	rm -f $ROOTER_LINK/create_proto$COUNTER
	$ROOTER/signal/status.sh $COUNTER "No Modem Present"

	uci -q delete network.wan$COUNTER
	uci set network.wan$COUNTER=interface
	uci set network.wan$COUNTER.proto=dhcp
	uci set network.wan$COUNTER.metric=$COUNTER"0"
	uci set network.wan$COUNTER.${ifname1}="wan"$COUNTER

	if [ -e /etc/config/mwan3 ]; then
		ENB=$(uci -q get mwan3.wan$COUNTER.enabled)
		if [ ! -z $ENB ]; then
			uci set mwan3.wan$COUNTER.enabled=0
		fi
	fi

	if [ -e /etc/config/failover ]; then
		uci delete failover.Modem$COUNTER
		uci set failover.Modem$COUNTER=member
	fi
	
OPING=$(uci -q get modem.ping.alive)
if [ ! -z $OPING ]; then
	uci delete modem.ping
fi

ifname1="ifname"
if [ -n "$tone" -o -e /etc/newstyle ]; then
	ifname1="device"
fi

	let COUNTER=COUNTER+1
done

if [ -e /etc/hotplug.d/10-motion ]; then
	rm -f /etc/hotplug.d/10-motion
fi
if [ -e /etc/hotplug.d/20-mjpg-streamer ]; then
	rm -f /etc/hotplug.d/20-mjpg-streamer
fi
if [ -e /etc/hotplug.d/50-printer ]; then
	rm -f /etc/hotplug.d/50-printer
fi
if [ -e $ROOTER/special.sh ]; then
	$ROOTER/special.sh
fi

echo 'MODSTART="'"$MODSTART"'"' > /tmp/variable.file
echo 'WWAN="'"$WWAN"'"' >> /tmp/variable.file
echo 'USBN="'"$USBN"'"' >> /tmp/variable.file
echo 'ETHN="'"$ETHN"'"' >> /tmp/variable.file
echo 'WDMN="'"$WDMN"'"' >> /tmp/variable.file
echo 'BASEPORT="'"$BASEPORT"'"' >> /tmp/variable.file

echo 'MODCNTX="'"$MODCNT"'"' > /tmp/modcnt
uci set modem.general.max=$MODCNT
uci set modem.general.modemnum=1
uci set modem.general.smsnum=1
uci set modem.general.miscnum=1

lua $ROOTER/gpiomodel.lua

HO=$(uci get system.@system[-1].hostname)
if [ $HO = "OpenWrt" ]; then
	uci set system.@system[-1].hostname="OpenWrt"
	uci commit system
fi

if [ -e /usr/lib/lua/luci/model/cbi/admin_system/cronnew.lua ]; then
	mv -f /usr/lib/lua/luci/model/cbi/admin_system/cronnew.lua /usr/lib/lua/luci/model/cbi/admin_system/crontab.lua
fi


if [ -f "/etc/firstboot" ]; then
	echo 'FIRSTBOOT="'"1"'"' > /etc/firstboot
else
	echo 'FIRSTBOOT="'"0"'"' > /etc/firstboot
	echo 'BOOTTIME="'"$(date +%s)"'"' > /tmp/boottime
fi

# end of bootup
echo "0" > /tmp/bootend.file

chown -R root:root /etc/dropbear/
chmod 700 /etc/dropbear/
chmod 644 /etc/dropbear/authorized_keys 2>/dev/null

if [ ! -z $tone ]; then
	[ -e /etc/newstyle ] || touch /etc/newstyle
	#reboot -f
fi
