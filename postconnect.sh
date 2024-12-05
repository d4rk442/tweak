#!/bin/sh 

ROOTER=/usr/lib/rooter
ROOTER_LINK="/tmp/links"

log() {
	modlog "PostConnect $CURRMODEM" "$@"
}

CURRMODEM=$1
idV=$(uci -q get modem.modem$CURRMODEM.idV)
idP=$(uci -q get modem.modem$CURRMODEM.idP)
CPORT=$(uci get modem.modem$CURRMODEM.commport)

log "Running PostConnect script"

cat > /tmp/resolv.conf.auto <<-DNS001
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
DNS001

cat > /etc/resolv.conf <<-DNS002
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
DNS002

cat > /tmp/resolv.conf <<-DNS003
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
DNS003

if [ -e /usr/lib/scan/emailchk.sh ]; then
	/usr/lib/scan/emailchk.sh &
fi
