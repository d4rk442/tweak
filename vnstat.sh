opkg install luci-app-vnstat vnstati

mkdir /etc/vnstat /www3/myadmin/vnstat
sed -i 's@^\(DatabaseDir\).*@\1 "/etc/vnstat"@' /etc/vnstat.conf
vnstat -u -i wwan0
vnstat -u -i wwan0_1
vnstat -u -i br-lan

echo "*/5 * * * * vnstat -u" >> /etc/crontabs/root

cat > /etc/graphs-vnstat.sh << \EOF
#!/bin/sh
# vnstati image generation script.
# Source:  https://code.google.com/p/x-wrt/source/browse/package/webif/files/www/cgi-bin/webif/graphs-vnstat.sh
 
WWW_D=/www3/myadmin/vnstat # output images to here
LIB_D=`awk -F \" '/^DatabaseDir/ { print $2 }' /etc/vnstat.conf` # db location
BIN=/usr/bin/vnstati  # which vnstati
 
outputs="s h d t m"   # what images to generate
 
# Sanity checks
[ -d "$WWW_D" ] || mkdir -p "$WWW_D" # make the folder if it doesn't exist.

# End of config changes
interfaces="$(ls -1 $LIB_D)"
 
if [ -z "$interfaces" ]; then
    echo "No database found, nothing to do."
    echo "A new database can be created with the following command: "
    echo "    vnstat -u -i eth0"
    exit 0
else
    for interface in $interfaces; do
        for output in $outputs; do
            $BIN -${output} -i $interface -o $WWW_D/vnstat_${interface}_${output}.png
        done
    done
fi
 
exit 1
EOF

chmod a+x /etc/graphs-vnstat.sh
echo "0 2 * * * /etc/graphs-vnstat.sh" >> /etc/crontabs/root

cat > /www3/myadmin/vnstat/index.html << EOF
<META HTTP-EQUIV="refresh" CONTENT="300">
<html>
  <head>
    <title>Traffic of OpenWRT interfaces</title>
  </head>
  <body>
EOF

for IFCE in $(ls -1 `awk -F \" '/^DatabaseDir/ { print $2 }' /etc/vnstat.conf`); do
cat >> /www3/myadmin/vnstat/index.html << EOF
    <h2>Traffic of Interface $IFCE</h2>
    <table>
        <tbody>
            <tr>
                <td>
                    <img src="vnstat_${IFCE}_s.png" alt="$IFCE Summary" />
                </td>
                <td>
                    <img src="vnstat_${IFCE}_h.png" alt="$IFCE Hourly" />
                </td>
            </tr>
            <tr>
                <td valign="top">
                    <img src="vnstat_${IFCE}_d.png" alt="$IFCE Daily" />
                </td>
                <td valign="top">
                    <img src="vnstat_${IFCE}_t.png" alt="$IFCE Top 10" />
                    <br />
                    <img src="vnstat_${IFCE}_m.png" alt="$IFCE Monthly" />
                </td>
            </tr>
        </tbody>
    </table>
EOF
done

cat >> /www3/myadmin/vnstat/index.html << EOF
  </body>
</html>
EOF
