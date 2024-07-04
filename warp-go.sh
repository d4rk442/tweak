#!/usr/bin/env bash

# Current script version number and new features
VERSION='1.1.8'

# IP API Service Provider
IP_API=("http://ip-api.com/json/" "https://api.ip.sb/geoip" "https://ifconfig.co/json" "https://www.cloudflare.com/cdn-cgi/trace")
ISP=("isp" "isp" "asn_org")
IP=("query" "ip" "ip")

# Determine the minimum number of characters in Teams token
TOKEN_LENGTH=800

# Environment variables are used to set noninteractive installation mode in Debian or Ubuntu operating systems
export DEBIAN_FRONTEND=noninteractive

trap "rm -f /tmp/warp-go*; exit 1" INT

E[0]="Language:\n 1.English (default) \n 2.Simplified Chinese"
C[0]="${E[0]}"
E[1]="Support Alpine edge system."
C[1]="Support Alpine edge system"
E[2]="warp-go h (help)\n warp-go o (temporary warp-go switch)\n warp-go u (uninstall WARP web interface and warp-go)\n warp-go v (sync script to latest version)\n warp-go i (replace IP with Netflix support)\n warp-go 4/6 ( WARP IPv4/IPv6 single-stack)\n warp-go d (WARP dual-stack)\n warp-go n (WARP IPv4 non-global)\n warp-go g (WARP global/non-global switching)\n warp-go e (output wireguard and sing-box configuration file)\n warp-go a (Change to Free, WARP+ or Teams account)"
C[2]="warp-go h (help)\n warp-go o (temporary warp-go switch)\n warp-go u (uninstall WARP network interface and warp-go)\n warp-go v (sync scripts to latest version)\n warp-go i (change to Netflix-supported IP)\n warp-go 4/6 (WARP IPv4/IPv6 single stack)\n warp-go d (WARP dual stack)\n warp-go n (WARP IPv4 non-global)\n warp-go g (WARP global/non-global switch)\n warp-go e (export wireguard and sing-box configuration files)\n warp-go a (switch to Free, WARP+ or Teams account)"
E[3]="This project is designed to add WARP network interface for VPS, using warp-go core, using various interfaces of CloudFlare-WARP, integrated wireguard-go, can completely replace WGCF. Save Hong Kong, Toronto and other VPS, can also get WARP IP. Thanks again @CoiaPrant and his team. Project address: https://gitlab.com/ProjectWARP/warp-go/-/tree/master/"
C[3]="This project is designed to add WARP network interface to VPS, using wire-go core program, taking advantage of various interfaces of CloudFlare-WARP, integrating wireguard-go, and can completely replace WGCF. It has saved VPS in Hong Kong, Toronto, etc. and can also obtain WARP IP. Thanks again to @CoiaPrant and his team. Project address: https://gitlab.com/ProjectWARP/warp-go/-/tree/master/"
E[4]="Choose:"
C[4]="Please select:"
E[5]="You must run the script as root. You can type sudo -i and then download and run it again. Feedback:[https://github.com/fscarmen/warp-sh/issues]"
C[5]="The script must be run as root. You can enter sudo -i and re-download and run it. Report the issue: [https://github.com/fscarmen/warp-sh/issues]"
E[6]="This script only supports Debian, Ubuntu, CentOS, Arch or Alpine systems, Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[6]="This script only supports Debian, Ubuntu, CentOS, Arch or Alpine systems, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[7]="Curren operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[7]="The current operation is \$SYS\\\n. \$SYSTEM \${MAJOR[int]} and the following systems are not supported. Please report the issue at: [https://github.com/fscarmen/warp-sh/issues]"
E[8]="Install dependence-list:"
C[8]="Installation dependency list:"
E[9]="Step 3/3: Best MTU and Endpoint found."
C[9]="Progress 3/3: Optimal MTU and Endpoint found"
E[10]="No suitable solution was found for modifying the warp-go configuration file warp.conf and the script aborted. When you see this message, please send feedback on the bug to:[https://github.com/fscarmen/warp-sh/issues]"
C[10]="No suitable solution was found to modify the warp-go configuration file warp.conf. The script aborted. When you see this message, please report the bug to: [https://github.com/fscarmen/warp-sh/issues]"
E[11]="Warp-go is not installed yet."
C[11]="warp-go is not installed yet"
E[12]="To install, press [y] and other keys to exit:"
C[12]="Press [y] if you want to install, press other keys to exit:"
E[13]="\$(date +'%F %T') Try \${i}. Failed. IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG. Retry after \${l} seconds. Brush ip runing time:\$DAY days \$HOUR hours \$MIN minutes \$SEC seconds"
C[13]="\$(date +'%F %T') Unlock failed after trying for the \${i}th time, IPv\$NF: \$WAN \$COUNTRY \$ASNORG, retest after \${l} seconds, refresh IP running time: \$DAY day\$HOUR hour\$MIN minute\$SEC second"
E[14]="1. Brush WARP IPv4 (default)\n 2. Brush WARP IPv6"
C[14]="1. Brush WARP IPv4 (default)\n 2. Brush WARP IPv6"
E[15]="The current Netflix region is:\$REGION. To unlock the current region please press [y]. For other addresses please enter two regional abbreviations \(e.g. hk,sg, default:\$REGION\):"
C[15]="The current Netflix region is:\$REGION. To unlock the current region, please press y. If you need another address, please enter the two-digit region abbreviation\(such as hk, sg, default:\$REGION\):"
E[16]="\$(date +'%F %T') Region: \$REGION Done. IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG. Retest after 1 hour. Brush ip runing time:\$DAY days \$HOUR hours \$MIN minutes \$SEC seconds"
C[16]="\$(date +'%F %T') region\$REGION unlocked successfully, IPv\$NF: \$WAN \$COUNTRY \$ASNORG, retest after 1 hour, refresh IP running time: \$DAY day\$HOUR hour\$MIN minute\$SEC second"
E[17]="WARP network interface and warp-go have been completely removed!"
C[17]="WARP network interface and warp-go have been completely removed!"
E[18]="Successfully synchronized the latest version"
C[18]="Success! The latest script and version number have been synchronized"
E[19]="New features"
C[19]="New functions"
E[20]="Maximum \${j} attempts to get WARP IP..."
C[20]="Background acquisition of WARP IP, maximum attempts\${j} times..."
E[21]="Can't find the account file: /opt/warp-go/warp.conf.You can uninstall and reinstall it."
C[21]="Cannot find account file: /opt/warp-go/warp.conf, you can uninstall and reinstall"
E[22]="Current Teams account is not available. Switch back to free account automatically."
C[22]="The current Teams account is unavailable, automatically switch back to the free account"
E[23]="Failed more than \${j} times, script aborted. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[23]="Failed more than \${j} times, script aborted, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[24]="non-"
C[24]="非"
E[25]="Successfully got WARP \$ACCOUNT_TYPE network.\\\n Running in \${GLOBAL_TYPE}global mode."
C[25]="Successfully obtained WARP \$ACCOUNT_TYPE network\\\n running in \${GLOBAL_TYPE} global mode"
E[26]="WARP+ quota"
C[26]="Remaining flow"
E[27]="WARP is turned off. It could be turned on again by [warp-go o]"
C[27]="WARP has been paused. You can restart it with warp-go o"
E[28]="WARP Non-global mode cannot switch between single and double stacks."
C[28]="Single and double stacks cannot be switched in WARP non-global mode"
E[29]="To switch to global mode, press [y] and other keys to exit:"
C[29]="To switch to global mode, press [y], other keys to exit:"
E[30]="Cannot switch to the same form as the current one."
C[30]="Cannot switch to the same form as the current one"
E[31]="Switch \${WARP_BEFORE[m]} to \${WARP_AFTER1[m]}"
C[31]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER1[m]}"
E[32]="Switch \${WARP_BEFORE[m]} to \${WARP_AFTER2[m]}"
C[32]="\${WARP_BEFORE[m]} becomes \${WARP_AFTER2[m]}"
E[33]="WARP network interface can be switched as follows:\\\n 1. \${OPTION[1]}\\\n 2. \${OPTION[2]}\\\n 0. Exit script"
C[33]="WARP network interface can be switched as follows:\\\n 1. \${OPTION[1]}\\\n 2. \${OPTION[2]}\\\n 0. Exit script"
E[34]="Please enter the correct number"
C[34]="Please enter a correct number"
E[35]="Checking VPS infomation..."
C[35]="Check the environment..."
E[36]="The TUN module is not loaded. You should turn it on in the control panel. Ask the supplier for more help. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[36]="TUN module is not loaded. Please enable it in the management backend or contact the supplier to learn how to enable it. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[37]="Curren architecture \$(uname -m) is not supported. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[37]="The current architecture \$(uname -m) is not supported yet, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[38]="If there is a WARP+ License, please enter it, otherwise press Enter to continue:"
C[38]="If you have a WARP+ License, please enter it. If not, press Enter to continue:"
E[39]="Input errors up to 5 times.The script is aborted."
C[39]="The input error has occurred 5 times, the script will exit"
E[40]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\${i} times remaining\):"
C[40]="License should be 26 characters long. Please re-enter WARP+ License. If there is no character, press Enter to continue\(remaining\${i} times\):"
E[41]="Please customize the device name (Default is [warp-go] if left blank):"
C[41]="Please customize the device name (if not entered, the default is [warp-go]):"
E[42]="Please Input WARP+ license:"
C[42]="Please enter WARP+ License:"
E[43]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\${i} times remaining\): "
C[43]="License should be 26 characters, please re-enter WARP+ License \(\${i} times remaining\): "
E[44]="Please enter the Teams Token (You can easily available at https://web--public--warp-team-api--coia-mfs4.code.run. Or use the one provided by the script if left blank):"
C[44]="Please enter the Teams Token (can be easily obtained through https://web--public--warp-team-api--coia-mfs4.code.run, if left blank, the one provided by the script will be used):"
E[45]="Token error, please re-enter Teams token \(remaining \${i} times\):"
C[45]="Token error, please re-enter Teams token \(remaining\${i} times\):"
E[46]="Current account type is: \$ACCOUNT_TYPE\\\t \$PLUS_QUOTA\\\n \$CHANGE_TYPE"
C[46]="The current account type is: \$ACCOUNT_TYPE\\\t \$PLUS_QUOTA\\\n \$CHANGE_TYPE"
E[47]="1. Continue using the free account without changing.\n 2. Change to WARP+ account.\n 3. Change to Teams account. (You can easily available at https://web--public--warp-team-api--coia-mfs4.code.run. Or use the one provided by the script if left blank)\n 0. Return to the main menu."
C[47]="1. Continue to use the free account without changing\n 2. Change to a WARP+ account\n 3. Change to a Teams account (can be easily obtained through https://web--public--warp-team-api--coia-mfs4.code.run, if left blank, use the one provided by the script)\n 0. Return to the main menu"
E[48]="1. Change to free account.\n 2. Change to WARP+ account.\n 3. Change to another WARP Teams account. (You can easily available at https://web--public--warp-team-api--coia-mfs4.code.run. Or use the one provided by the script if left blank)\n 0. Return to the main menu."
C[48]="1. Change to a free account\n 2. Change to a WARP+ account\n 3. Change to another Teams account (can be easily obtained through https://web--public--warp-team-api--coia-mfs4.code.run, if left blank, use the one provided by the script)\n 0. Return to the main menu"
E[49]="1. Change to free account.\n 2. Change to another WARP+ account.\n 3. Change to Teams account. (You can easily available at https://web--public--warp-team-api--coia-mfs4.code.run. Or use the one provided by the script if left blank)\n 0. Return to the main menu."
C[49]="1. Change to a free account\n 2. Change to another WARP+ account\n 3. Change to a Teams account (easily available via https://web--public--warp-team-api--coia-mfs4.code.run, if left blank, use the one provided by the script)\n 0. Return to the main menu"
E[50]="Registration of WARP\${k} account failed, script aborted. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[50]="Failed to register WARP\${k} account, script aborted, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[51]="Warp-go not yet installed. No account registered. Script aborted. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[51]="warp-go is not installed yet, no account is registered, script aborted, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[52]="Wireguard configuration file: /opt/warp-go/wgcf.conf\n"
C[52]="Wireguard configuration file: /opt/warp-go/wgcf.conf\n"
E[53]="Warp-go installed. Script aborted. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[53]="warp-go has been installed, script aborted, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[54]="Is there a WARP+ or Teams account?\n  1. WARP+\n  2. Teams\n  3. Use free account (default)"
C[54]="If you have a WARP+ or Teams account, please select\n 1. WARP+\n 2. Teams\n 3. Use a free account (default)"
E[55]="Please choose the priority:\n  1. IPv4\n  2. IPv6\n  3. Use initial settings (default)"
C[55]="Please select the priority:\n 1. IPv4\n 2. IPv6\n 3. Use VPS initial settings (default)"
E[56]="Download warp-go zip file unsuccessful. Script exits. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[56]="Failed to download warp-go compressed file, script exited, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[57]="Warp-go file does not exist, script exits. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[57]="Warp-go file does not exist, script exits, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[58]="Maximum \${j} attempts to register WARP\${k} account..."
C[58]="Registering WARP\${k} accounts, maximum attempts\${j} times..."
E[59]="Try \${i}"
C[59]="\${i}th attempt"
E[60]="Step 1/3: Install dependencies..."
C[60]="Progress 1/3: Installing system dependencies..."
E[61]="Step 2/3: Install warp-go..."
C[61]="Progress 2/3: warp-go has been installed"
E[62]="Congratulations! WARP \$ACCOUNT_TYPE has been turn on. Total time spent:\$(( end - start )) seconds.\\\n Number of script runs in the day: \$TODAY. Total number of runs: \$TOTAL."
C[62]="Congratulations! WARP \$ACCOUNT_TYPE has been enabled, total time taken: \$(( end - start )) seconds\\\nNumber of script runs today: \$TODAY, total number of runs: \$TOTAL"
E[63]="Warp-go installation failed. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[63]="warp-go installation failed, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[64]="Add WARP IPv4 global network interface for \${NATIVE[n]}, IPv4 priority \(bash warp-go.sh 4\)"
C[64]="Add WARP IPv4 global network interface for \${NATIVE[n]}, IPv4 preferred\(bash warp-go.sh 4\)"
E[65]="Add WARP IPv4 global network interface for \${NATIVE[n]}, IPv6 priority \(bash warp-go.sh 4\)"
C[65]="Add WARP IPv4 global network interface for \${NATIVE[n]}, IPv6 preferred\(bash warp-go.sh 4\)"
E[66]="Add WARP IPv6 global network interface for \${NATIVE[n]}, IPv4 priority \(bash warp-go.sh 6\)"
C[66]="Add WARP IPv6 global network interface for \${NATIVE[n]}, IPv4 preferred\(bash warp-go.sh 6\)"
E[67]="Add WARP IPv6 global network interface for \${NATIVE[n]}, IPv6 priority \(bash warp-go.sh 6\)"
C[67]="Add WARP IPv6 global network interface for \${NATIVE[n]}, IPv6 preferred\(bash warp-go.sh 6\)"
E[68]="Add WARP dual-stacks global network interface for \${NATIVE[n]}, IPv4 priority \(bash warp-go.sh d\)"
C[68]="Add WARP dual-stack global network interface for \${NATIVE[n]}, IPv4 preferred\(bash warp-go.sh d\)"
E[69]="Add WARP dual-stacks global network interface for \${NATIVE[n]}, IPv6 priority \(bash warp-go.sh d\)"
C[69]="Add WARP dual-stack global network interface for \${NATIVE[n]}, IPv6 preferred\(bash warp-go.sh d\)"
E[70]="Add WARP dual-stacks non-global network interface for \${NATIVE[n]}, IPv4 priority \(bash warp-go.sh n\)"
C[70]="Add WARP dual-stack non-global network interface for \${NATIVE[n]}, IPv4 preferred\(bash warp-go.sh n\)"
E[71]="Add WARP dual-stacks non-global network interface for \${NATIVE[n]}, IPv6 priority \(bash warp-go.sh n\)"
C[71]="Add WARP dual-stack non-global network interface for \${NATIVE[n]}, IPv6 preferred\(bash warp-go.sh n\)"
E[72]="Turn off warp-go (warp-go o)"
C[72]="关闭 warp-go (warp-go o)"
E[73]="Turn on warp-go (warp-go o)"
C[73]="打开 warp-go (warp-go o)"
E[74]="\${WARP_BEFORE[m]} switch to \${WARP_AFTER1[m]} \${SHORTCUT1[m]}"
C[74]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER1[m]} \${SHORTCUT1[m]}"
E[75]="\${WARP_BEFORE[m]} switch to \${WARP_AFTER2[m]} \${SHORTCUT2[m]}"
C[75]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER2[m]} \${SHORTCUT2[m]}"
E[76]="Switch to WARP \${GLOBAL_AFTER}global network interface  \(warp-go g\)"
C[76]="Switch to WARP \${GLOBAL_AFTER} global network interface\(warp-go g\)"
E[77]="Change to Free, WARP+ or Teams account \(warp-go a\)"
C[77]="Change to Free, WARP+ or Teams account\(warp-go a\)"
E[78]="Change the WARP IP to support Netflix (warp-go i)"
C[78]="Change IP to support Netflix (warp-go i)"
E[79]="Export wireguard and sing-box configuration file (warp-go e)"
C[79]="Export wireguard and sing-box configuration files (warp-go e)"
E[80]="Uninstall the WARP interface and warp-go (warp-go u)"
C[80]="Uninstall WARP network interface and warp-go (warp-go u)"
E[81]="Exit"
C[81]="Exit script"
E[82]="Sync the latest version"
C[82]="Synchronize the latest version"
E[83]="Device Name"
C[83]="Device Name"
E[84]="Version"
C[84]="Script version"
E[85]="New features"
C[85]="New functions"
E[86]="System infomation"
C[86]="System Information"
E[87]="Operating System"
C[87]="Current operating system"
E[88]="Kernel"
C[88]="kernel"
E[89]="Architecture"
C[89]="Processor architecture"
E[90]="Virtualization"
C[90]="Virtualization"
E[91]="WARP \$TYPE Interface is on"
C[91]="WARP \$TYPE network interface is enabled"
E[92]="Running in \${GLOBAL_TYPE}global mode"
C[92]="Run in \${GLOBAL_TYPE} global mode"
E[93]="WARP network interface is not turned on"
C[93]="WARP network interface is not enabled"
E[94]="Native dualstack"
C[94]="Native dual stack"
E[95]="Run again with warp-go [option] [lisence], such as"
C[95]="Run again with warp-go [option] [lisence], such as"
E[96]="dualstack"
C[96]="Dual stack"
E[97]="The account type is Teams and does not support changing IP\n 1. Change to free (default)\n 2. Change to plus\n 3. Quit"
C[97]="Account type is Teams, IP change is not supported\n 1. Change to free (default)\n 2. Change to plus\n 3. Exit"
E[98]="Non-global"
C[98]="non-global"
E[99]="global"
C[99]="Global"
E[100]="IPv\$PRIO priority"
C[100]="IPv\$PRIO priority"
E[101]="Sing-box configuration file: /opt/warp-go/singbox.json\n"
C[101]="Sing-box configuration file: /opt/warp-go/singbox.json\n"
E[102]="WAN interface network protocol must be [static] on OpenWrt."
C[102]="The network transmission protocol of the WAN interface of the OpenWrt system must be [static address]"
E[103]="Unlimited"
C[103]="Unlimited"
E[104]="Failed to get the registration information from API. Script exits. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[104]="API cannot obtain registration information, script exits, issue feedback: [https://github.com/fscarmen/warp-sh/issues]"
E[105]="upgrade successful."
C[105]="Upgrade successful"
E[106]="upgrade failed. The free account will remain in use."
C[106]="Upgrade failed, free account will be used."
E[107]="All endpoints of WARP cannot be connected. Ask the supplier for more help. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[107]="All WARP endpoints cannot be connected. It is possible that UDP is restricted. Please contact the vendor to learn how to enable it. Report the problem: [https://github.com/fscarmen/warp-sh/issues]"
E[108]="Cannot detect any IPv4 or IPv6. The script is aborted. Feedback: [https://github.com/fscarmen/warp-sh/issues]"
C[108]="No IPv4 or IPv6 detected. Script aborted, issue reported: [https://github.com/fscarmen/warp-sh/issues]"

# Custom font color, read function
warning() { echo -e "\033[31m\033[01m$*\033[0m"; } # red
error() { echo -e "\033[31m\033[01m$*\033[0m"; rm -f /tmp/warp-go*; exit 1; }  # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; } # green
hint() { echo -e "\033[33m\033[01m$*\033[0m"; } # yellow
reading() { read -rp "$(info "$1")" "$2"; }
text() { eval echo "\${${L}[$*]}"; }
text_eval() { eval echo "\$(eval echo "\${${L}[$*]}")"; }

# Custom Google Translate Function
translate() {
  [ -n "$@" ] && EN="$@"
  ZH=$(curl -km8 -sSL "https://translate.google.com/translate_a/t?client=any_client_id_works&sl=en&tl=zh&q=${EN//[[:space:]]/%20}" 2>/dev/null)
  [[ "$ZH" =~ ^\[\".+\"\]$ ]] && cut -d \" -f2 <<< "$ZH"
}

# Statistics of script execution times for the day and cumulatively
statistics_of_run-times() {
  local COUNT=$(curl --retry 2 -ksm2 "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffscarmen%2Fwarp%2Fmain%2Fwarp-go.sh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false" 2>&1 | grep -m1 -oE "[0-9]+[ ]+/[ ]+[0-9]+") &&
  TODAY=$(cut -d " " -f1 <<< "$COUNT") &&
  TOTAL=$(cut -d " " -f3 <<< "$COUNT")
}

# Select the language. First check the language selection in /opt/warp-go/language. If not, let the user select it. The default is English.
select_language() {
  UTF8_LOCALE=$(locale -a 2>/dev/null | grep -iEm1 "UTF-8|utf8")
  [ -n "$UTF8_LOCALE" ] && export LC_ALL="$UTF8_LOCALE" LANG="$UTF8_LOCALE" LANGUAGE="$UTF8_LOCALE"

  case "$(cat /opt/warp-go/language 2>&1)" in
    E )
      L=E
      ;;
    C )
      L=C
      ;;
    * )
      L=E && [[ -z "$OPTION" || "$OPTION" = [ahvi46d] ]] && hint "\n $(text 0) \n" && reading " $(text 4) " LANGUAGE
      [ "$LANGUAGE" = 2 ] && L=C
  esac
}

# The script must be run as root
check_root_virt() {
  [ "$(id -u)" != 0 ] && error " $(text 5) "

  # Determine virtualization, choose Wireguard kernel module or Wireguard-Go
  if [ "$1" = Alpine ]; then
    VIRT=$(virt-what)
  else
    [ $(type -p systemd-detect-virt) ] && VIRT=$(systemd-detect-virt)
    [[ -z "$VIRT" && $(type -p hostnamectl) ]] && VIRT=$(hostnamectl | awk '/Virtualization:/{print $NF}')
  be
}

# Multiple ways to determine the operating system, try until there is a value. Only Debian 9/10/11, Ubuntu 18.04/20.04/22.04 or CentOS 7/8 are supported. If it is not the above operating system, exit the script
check_operating_system() {
  if [ -s /etc/os-release ]; then
    SYS="$(grep -i pretty_name /etc/os-release | cut -d \" -f2)"
  elif [ $(type -p hostnamectl) ]; then
    SYS="$(hostnamectl | grep -i system | cut -d : -f2)"
  elif [ $(type -p lsb_release) ]; then
    SYS="$(lsb_release -sd)"
  elif [ -s /etc/lsb-release ]; then
    SYS="$(grep -i description /etc/lsb-release | cut -d \" -f2)"
  elif [ -s /etc/redhat-release ]; then
    SYS="$(grep . /etc/redhat-release)"
  elif [ -s /etc/issue ]; then
    SYS="$(grep . /etc/issue | cut -d '\' -f1 | sed '/^[ ]*$/d')"
  be

  # Customize some functions of Alpine system
  alpine_warp_restart() {
    kill -15 $(pgrep warp-go) 2>/dev/null
    /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf 2>&1 &
  }
  alpine_wgcf_enable() { echo -e "/opt/warp-go/tun.sh\n/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf 2>&1 &" > /etc/local.d/warp-go.start; chmod +x /etc/local.d/warp-go.start; rc-update add local; }
  openwrt_wgcf_enable() { echo -e "@reboot /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf" >> /etc/crontabs/root; }

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky|amazon linux" "alpine" "arch linux" "openwrt")
  RELEASE=("Debian" "Ubuntu" "CentOS" "Alpine" "Arch" "OpenWrt")
  EXCLUDE=("---")
  MAJOR=("9" "16" "7" "" "" "")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "apk update -f" "pacman -Sy" "opkg update")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "apk add -f" "pacman -S --noconfirm" "opkg install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "apk del -f" "pacman -Rcnsu --noconfirm" "opkg remove --force-depends")
  SYSTEMCTL_START=("systemctl start warp-go" "systemctl start warp-go" "systemctl start warp-go" "/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf" "systemctl start warp-go" "/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf")
  SYSTEMCTL_STOP=("systemctl stop warp-go" "systemctl stop warp-go" "systemctl stop warp-go" "kill -15 $(pgrep warp-go)" "systemctl stop warp-go" "kill -15 $(pgrep warp-go)")
  SYSTEMCTL_RESTART=("systemctl restart warp-go" "systemctl restart warp-go" "systemctl restart warp-go" "alpine_warp_restart" "systemctl restart wg-quick@wgcf" "alpine_warp_restart")
  SYSTEMCTL_ENABLE=("systemctl enable --now warp-go" "systemctl enable --now warp-go" "systemctl enable --now warp-go" "alpine_wgcf_enable" "systemctl enable --now warp-go")

  for int in "${!REGEX[@]}"; do
    [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done

  # Customized system for each factory
  if [ -z "$SYSTEM" ]; then
    [ $(type -p yum) ] && int=2 && SYSTEM='CentOS' || error " $(text 6) "
  be

  [ "$SYSTEM" = OpenWrt ] && [[ ! $(uci show network.wan.proto 2>/dev/null | cut -d \' -f2)$(uci show network.lan.proto 2>/dev/null | cut -d \' -f2) =~ 'static' ]] && error " $(text 102) "

  # Exclude the specific systems included in EXCLUDE first, other systems need to be compared with the major release versions
  for ex in "${EXCLUDE[@]}"; do [[ ! "${SYS,,}"  =~ $ex ]]; done &&
  [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text_eval 7) "
}

check_arch() {
  # Determine the processor architecture
  case "$(uname -m)" in
    aarch64 )
      ARCHITECTURE=arm64
      ;;
    x86)
      ARCHITECTURE=386
      ;;
    x86_64 )
      CPU_FLAGS=$(cat /proc/cpuinfo | grep flags | head -n 1 | cut -d: -f2)
      case "$CPU_FLAGS" in
        *avx512* )
          ARCHITECTURE=amd64v4
          ;;
        *avx2* )
          ARCHITECTURE=amd64v3
          ;;
        *sse3* )
          ARCHITECTURE=amd64v2
          ;;
        * )
          ARCHITECTURE=amd64
      esac
      ;;
    s390x )
      ARCHITECTURE=s390x
      ;;
    * )
      error " $(text_eval 37) "
  esac
}

# Install system dependencies and define ping commands
check_dependencies() {
  # For Alpine and OpenWrt systems, upgrade the library and reinstall dependencies
  if [[ "$SYSTEM" =~ Alpine|OpenWrt ]]; then
    DEPS_CHECK=("ping" "curl" "wget" "grep" "bash" "xxd" "ip" "python3" "tar" "virt-what")
    DEPS_INSTALL=("iputils-ping" "curl" "wget" "grep" "bash" "xxd" "iproute2" "python3" "tar" "virt-what")
  else
    # For CentOS systems, xxd needs to rely on vim-common
    [ "${SYSTEM}" = 'CentOS' ] && ${PACKAGE_INSTALL[int]} vim-common
    DEPS_CHECK=("ping" "xxd" "wget" "curl" "systemctl" "ip" "python3")
    DEPS_INSTALL=("iputils-ping" "xxd" "wget" "curl" "systemctl" "iproute2" "python3")
  be

  for c in "${!DEPS_CHECK[@]}"; do
    [ ! $(type -p ${DEPS_CHECK[c]}) ] && [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[c]}" ]] && DEPS+=(${DEPS_INSTALL[c]})
  done

  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 8) ${DEPS[@]} \n"
    ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
    ${PACKAGE_INSTALL[int]} ${DEPS[@]} >/dev/null 2>&1
  be

  PING6='ping -6' && [ $(type -p ping6) ] && PING6='ping6'
}

# Check the installation status of warp-go. STATUS: 0-Not installed; 1-Installed but not started; 2-Installed and starting; 3-Script installation in progress
check_install() {
  if [ -s /opt/warp-go/warp.conf ]; then
    [[ "$(ip link show | awk -F': ' '{print $2}')" =~ "WARP" ]] && STATUS=2 || STATUS=1
  else
    STATUS=0
    {
      # Pre-download warp-go and add execution permissions. If it fails to be obtained due to gitlab interface problems, the default is v1.0.8
      latest=$(wget -qO- -T2 -t1 https://gitlab.com/api/v4/projects/ProjectWARP%2Fwarp-go/releases | awk -F '"' '{for (i=0; i<NF; i++) if ($i=="tag_name") {print $(i+2); exit}}' | sed "s/v//")
      latest=${latest:-'1.0.8'}
      wget --no-check-certificate -T5 -qO- /tmp/warp-go.tar.gz https://gitlab.com/fscarmen/warp/-/raw/main/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz | tar xz -C /tmp/ warp-go
      chmod +x /tmp/warp-go
    }&
  be
}

# Check IPv4 IPv6 information, WARP Ineterface enabled, normal or Plus account and IP information
ip4_info() {
  unset IP4 COUNTRY4 ASNORG4 TRACE4 PLUS4 WARPSTATUS4 ERROR4
  IP4_API=${IP_API[0]} && ISP4=${ISP[0]} && IP4_KEY=${IP[0]}
  TRACE4=$(curl --retry 5 -ks4m5 ${IP_API[3]} $INTERFACE4 | grep warp | sed "s/warp=//g")
  if [ -n "$TRACE4" ]; then
    IP4=$(curl --retry 7 -ks4m5 -A Mozilla $IP4_API $INTERFACE4)
    [[ -z "$IP4" || "$IP4" =~ 'error code' ]] && IP4_API=${IP_API[2]} && ISP4=${ISP[2]} && IP4_KEY=${IP[2]} && IP4=$(curl --retry 3 -ks4m5 -A Mozilla $IP4_API $INTERFACE4)
    if [[ -n "$IP4" && ! "$IP4" =~ 'error code' ]]; then
      WAN4=$(expr "$IP4" : '.*'$IP4_KEY'\":[ ]*\"\([^"]*\).*')
      COUNTRY4=$(expr "$IP4" : '.*country\":[ ]*\"\([^"]*\).*')
      ASNORG4=$(expr "$IP4" : '.*'$ISP4'\":[ ]*\"\([^"]*\).*')
    be
  be
}

ip6_info() {
  unset IP6 COUNTRY6 ASNORG6 TRACE6 PLUS6 WARPSTATUS6 ERROR6
  IP6_API=${IP_API[1]} && ISP6=${ISP[1]} && IP6_KEY=${IP[1]}
  TRACE6=$(curl --retry 5 -ks6m5 ${IP_API[3]} $INTERFACE6 | grep warp | sed "s/warp=//g")
  if [ -n "$TRACE6" ]; then
    IP6=$(curl --retry 7 -ks6m5 -A Mozilla $IP6_API $INTERFACE6)
    [[ -z "$IP6" || "$IP6" =~ 'error code' ]] && IP6_API=${IP_API[2]} && ISP6=${ISP[2]} && IP6_KEY=${IP[2]} && IP6=$(curl --retry 3 -ks6m5 -A Mozilla $IP6_API $INTERFACE6)
    if [[ -n "$IP6" && ! "$IP6" =~ 'error code' ]]; then
      WAN6=$(expr "$IP6" : '.*'$IP6_KEY'\":[ ]*\"\([^"]*\).*')
      COUNTRY6=$(expr "$IP6" : '.*country\":[ ]*\"\([^"]*\).*')
      ASNORG6=$(expr "$IP6" : '.*'$ISP6'\":[ ]*\"\([^"]*\).*')
    be
  be
}

# Help
help() { hint " $(text 2) "; }

# IPv4 / IPv6 Priority Settings
stack_priority() {
  if [ "$SYSTEM" != OpenWrt ]; then
    [ "$OPTION" = s ] && case "$PRIORITY_SWITCH" in
      4 )
        PRIORITY=1
        ;;
      6 )
        PRIORITY=2
        ;;
      d )
        :
        ;;
      * )
        hint "\n $(text 55) \n" && reading " $(text 4) " PRIORITY
    esac

    [ -s /etc/gai.conf ] && sed -i '/^precedence \:\:ffff\:0\:0/d;/^label 2002\:\:\/16/d' /etc/gai.conf
    case "$PRIORITY" in
      1 )
        echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
        ;;
      2 )
        echo "label 2002::/16   2" >> /etc/gai.conf
    esac
  be
}

# IPv4 / IPv6 priority results
result_priority() {
  PRIO=(0 0)
  if [ -s /etc/gai.conf ]; then
    grep -qsE "^precedence[ ]+::ffff:0:0/96[ ]+100" /etc/gai.conf && PRIO[0]=1
    grep -qsE "^label[ ]+2002::/16[ ]+2" /etc/gai.conf && PRIO[1]=1
  be
  case "${PRIO[*]}" in
    '1 0' )
      PRIO=4
      ;;
    '0 1' )
      PRIO=6
      ;;
    * )
      [[ "$(curl -ksm8 -A Mozilla ${IP_API[3]} | grep 'ip=' | cut -d= -f2)" =~ ^([0-9]{1,3}\.){3} ]] && PRIO=4 || PRIO=6
  esac
  PRIORITY_NOW=$(text_eval 100)

  # If the shortcut switches the priority level, display the result
  [ "$OPTION" = s ] && hint "\n $PRIORITY_NOW \n"
}

need_install() {
  [ "$STATUS" = 0 ] && warning " $(text 11) " && reading " $(text 12) " TO_INSTALL
  [[ $TO_INSTALL = [Yy] ]] && install
}

# Change to support Netflix WARP IP adapted from the mature work of [luoxue-bot], address [https://github.com/luoxue-bot/warp_auto_change_ip]
change_ip() {
  need_install
  warp_restart() {
    warning " $(text_eval 13) "
    cp -f /opt/warp-go/warp.conf{,.tmp1}
    [ -s /opt/warp-go/License ] && k='+' || k=' free'
    register_api warp.conf.tmp2
    sed -i '1,6!d' /opt/warp-go/warp.conf.tmp2
    tail -n +7 /opt/warp-go/warp.conf.tmp1 >> /opt/warp-go/warp.conf.tmp2
    mv /opt/warp-go/warp.conf.tmp2 /opt/warp-go/warp.conf
    bash <(curl -m8 -sSL https://gitlab.com/fscarmen/warp/-/raw/main/api.sh) --file /opt/warp-go/warp.conf.tmp1 --cancle >/dev/null 2>&1
    rm -f /opt/warp-go/warp.conf.tmp*
    ${SYSTEMCTL_RESTART[int]}
    sleep $l
  }

  # Check that the account type is Team and cannot be changed
  if grep -qE 'Type[ ]+=[ ]+team' /opt/warp-go/warp.conf; then
    hint "\n $(text 97) \n" && reading " $(text 4) " CHANGE_ACCOUNT
    case "$CHANGE_ACCOUNT" in
      2 )
        update_license
        echo "$LICENSE" > /opt/warp-go/License
        echo "$NAME" > /opt/warp-go/Device_Name
        ;;
      3 ) exit 0
    esac
  be

  # Set the time zone to make the timestamp accurate and display the script running time. Chinese is GMT+8 and English is UTC; Set UA
  ip_start=$(date +%s)
  echo "$SYSTEM" | grep -qE "Alpine" && ( [ "$L" = C ] && timedatectl set-timezone Asia/Shanghai || timedatectl set-timezone UTC )
  UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

  # Detect Netflix Title according to lmc999 script. If it cannot be obtained, use the default value
  local LMC999=($(curl -sSLm4 https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh | awk -F 'title/' '/netflix.com\/title/{print $2}' | cut -d\" -f1))
  RESULT_TITLE=(${LMC999[*]:0:2})
  REGION_TITLE=${LMC999[2]}
  [[ ! "${RESULT_TITLE[0]}" =~ ^[0-9]+$ ]] && RESULT_TITLE[0]='81280792'
  [[ ! "${RESULT_TITLE[1]}" =~ ^[0-9]+$ ]] && RESULT_TITLE[1]='70143836'
  [[ ! "$REGION_TITLE" =~ ^[0-9]+$ ]] && REGION_TITLE='80018499'

  # Detect WARP single-stack and dual-stack services
  unset T4 T6
  if grep -q "#AllowedIPs" /opt/warp-go/warp.conf; then
    T4=1; T6=1
  else
    grep -q "0\.\0\/0" 2>/dev/null /opt/warp-go/warp.conf && T4=1 || T4=0
    grep -q "\:\:\/0" 2>/dev/null /opt/warp-go/warp.conf && T6=1 || T6=0
  be
  case "$T4$T6" in
    01 )
      NF='6'
      ;;
    10 )
      NF='4'
      ;;
    11 )
      hint "\n $(text 14) \n" && reading " $(text 4) " NETFLIX
      NF='4' && [ "$NETFLIX" = 2 ] && NF='6'
  esac

  # Enter the unlock area
  if [ -z "$EXPECT" ]; then
    [ -n "$NF" ] && REGION=$(tr 'a-z' 'A-Z' <<< "$(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g')")
    REGION=${REGION:-'US'}
    reading " $(text_eval 15) " EXPECT
    until [[ -z "$EXPECT" || "$EXPECT" = [Yy] || "$EXPECT" =~ ^[A-Za-z]{2}$ ]]; do
      reading " $(text_eval 15) " EXPECT
    done
    [[ -z "$EXPECT" || "$EXPECT" = [Yy] ]] && EXPECT="$REGION"
  be

  # Unlock detection program. i = number of attempts; b = number of current account registrations; j = maximum number of failed account registrations; l = waiting time for retry after account registration fails;
  i=0; j=10; l=8
  while true; do
    b=0
    (( i++ )) || true
    ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
    ip${NF}_info
    WAN=$(eval echo \$WAN$NF) && ASNORG=$(eval echo \$ASNORG$NF)
    [ "$L" = C ] && COUNTRY=$(translate "$(eval echo \$COUNTRY$NF)") || COUNTRY=$(eval echo \$COUNTRY$NF)
    unset RESULT REGION
    for p in ${!RESULT_TITLE[@]}; do
      RESULT[p]=$(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/${RESULT_TITLE[p]}")
      [ "${RESULT[p]}" = 200 ] && break
    done

    if [[ "${RESULT[@]}" =~ 200 ]]; then
      REGION=$(tr 'a-z' 'A-Z' <<< "$(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g')")
      REGION=${REGION:-'US'}
      echo "$REGION" | grep -qi "$EXPECT" && info " $(text_eval 16) " && rm -f /opt/warp-go/warp.conf.tmp1 && i=0 && sleep 1h || warp_restart
    else
      warp_restart
    be
  done
}

# Shut down the WARP network interface and delete warp-go
uninstall() {
  unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 INTERFACE4 INTERFACE6

  # If the warp_unlock project is already installed, uninstall it first
  [ -s /usr/bin/warp_unlock.sh ] && bash <(curl -sSL https://gitlab.com/fscarmen/warp_unlock/-/raw/main/unlock.sh) -U -$L

  # uninstall
  systemctl disable --now warp-go >/dev/null 2>&1
  kill -15 $(pgrep warp-go) >/dev/null 2>&1
  bash <(curl -m8 -sSL https://gitlab.com/fscarmen/warp/-/raw/main/api.sh) --file /opt/warp-go/warp.conf --cancle >/dev/null 2>&1
  rm -rf /opt/warp-go /lib/systemd/system/warp-go.service /usr/bin/warp-go /tmp/warp-go*
  [ -s /opt/warp-go/tun.sh ] && rm -f /opt/warp-go/tun.sh && sed -i '/tun.sh/d' /etc/crontab

  # Display uninstall results
  ip4_info; [ "$L" = C ] && [ -n "$COUNTRY4" ] && COUNTRY4=$(translate "$COUNTRY4")
  ip6_info; [ "$L" = C ] && [ -n "$COUNTRY6" ] && COUNTRY6=$(translate "$COUNTRY6")
  info " $(text 17)\n IPv4: $WAN4 $COUNTRY4 $ASNORG4\n IPv6: $WAN6 $COUNTRY6 $ASNORG6 "
}

# Synchronize scripts to the latest version
ver() {
  mkdir -p /tmp; rm -f /tmp/warp-go.sh
  wget -T2 -O /tmp/warp-go.sh https://gitlab.com/fscarmen/warp/-/raw/main/warp-go.sh
  if [ -s /tmp/warp-go.sh ]; then
    mv /tmp/warp-go.sh /opt/warp-go/
    chmod +x /opt/warp-go/warp-go.sh
    ln -sf /opt/warp-go/warp-go.sh /usr/bin/warp-go
    info " $(text 18): $(grep ^VERSION /opt/warp-go/warp-go.sh | sed "s/.*=//g")  $(text 19): $(grep "${L}\[1\]" /opt/warp-go/warp-go.sh | cut -d \" -f2) "
  be
  exit
}

# i = current number of attempts, j = number of attempts to be made
net() {
  unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 WARPSTATUS4 WARPSTATUS6
  i=1; j=5
  grep -qE "^AllowedIPs[ ]+=.*0\.\0\/0|#AllowedIPs" 2>/dev/null /opt/warp-go/warp.conf && INTERFACE4='--interface WARP'
  grep -qE "^AllowedIPs[ ]+=.*\:\:\/0|#AllowedIPs" 2>/dev/null /opt/warp-go/warp.conf && INTERFACE6='--interface WARP'
  hint " $(text_eval 20)\n $(text_eval 59) "
  [ "$KEEP_FREE" != 1 ] && ${SYSTEMCTL_RESTART[int]}
  grep -q "#AllowedIPs" /opt/warp-go/warp.conf && sleep 8 || sleep 1
  ip4_info; ip6_info
  until [[ "$TRACE4$TRACE6" =~ on|plus ]]; do
    (( i++ )) || true
    hint " $(text_eval 59) "
    ${SYSTEMCTL_RESTART[int]}
    grep -q "#AllowedIPs" /opt/warp-go/warp.conf && sleep 8 || sleep 1
    ip4_info; ip6_info
      if [[ "$i" = "$j" ]]; then
        if [ -s /opt/warp-go/warp.conf.tmp1 ]; then
          i=0 && info " $(text 22) " &&
          mv -f /opt/warp-go/warp.conf.tmp1 /opt/warp-go/warp.conf
      else
          ${SYSTEMCTL_STOP[int]} >/dev/null 2>&1
          error " $(text_eval 23) "
        be
      be
  done

  ACCOUNT_TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  [ "$ACCOUNT_TYPE" = 'plus' ] && check_quota
  grep -q '#AllowedIPs' /opt/warp-go/warp.conf && GLOBAL_TYPE="$(text 24)"

  info " $(text_eval 25) "
  [ "$L" = C ] && [ -n "$COUNTRY4" ] && COUNTRY4=$(translate "$COUNTRY4")
  [ "$L" = C ] && [ -n "$COUNTRY6" ] && COUNTRY6=$(translate "$COUNTRY6")
  [ "$OPTION" = o ] && info " IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4 $ASNORG4\n IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6 $ASNORG6 "
  [ -n "$QUOTA" ] && info " $(text 26): $QUOTA "
}

#api register account, use official api script
register_api() {
  local REGISTER_FILE="$1"
  local i=0; local j=5
  [ -n "$2" ] && hint " $(text_eval $2) "
  until [ -s /opt/warp-go/$REGISTER_FILE ]; do
    ((i++)) || true
    [ "$i" -gt "$j" ] && rm -f /opt/warp-go/warp.conf.tmp* && error " $(text_eval 50) "
    [ -n "$3" ] && hint " $(text_eval $3) "
    if ! grep -sq 'PrivateKey' /opt/warp-go/$REGISTER_FILE; then
      unset CF_API_REGISTER API_DEVICE_ID API_ACCESS_TOKEN API_PRIVATEKEY API_TYPE
      rm -f /opt/warp-go/$REGISTER_FILE
      CF_API_REGISTER="$(bash <(curl -m8 -sSL https://gitlab.com/fscarmen/warp/-/raw/main/api.sh | sed 's# > $register_path##g; /cat $register_path/d') --register --token $TOKEN 2>/dev/null)"
      [[ -n "$NF" && -n "$EXPECT" && -s /opt/warp-go/License ]] && LICENSE=$(cat /opt/warp-go/License) && NAME=$(cat /opt/warp-go/Device_Name)
      [[ -z "$LICENSE" && -s /opt/warp-go/License ]] && rm -f /opt/warp-go/License /opt/warp-go/Device_Name
      if grep -q 'private_key' <<< "$CF_API_REGISTER"; then
        local API_DEVICE_ID=$(expr "$CF_API_REGISTER " | grep -m1 'id' | cut -d\" -f4)
        local API_ACCESS_TOKEN=$(expr "$CF_API_REGISTER " | grep '"token' | cut -d\" -f4)
        local API_PRIVATEKEY=$(expr "$CF_API_REGISTER " | grep 'private_key' | cut -d\" -f4)
        local API_TYPE=$(expr "$CF_API_REGISTER " | grep 'account_type' | cut -d\" -f4)
        [[ -z "$NF" && -z "$EXPECT" && -n "$TOKEN" ]] && ( [ "$API_TYPE" = 'team' ] && info "\n teams $(text_eval 105) \n" || warning "\n teams $(text_eval 106) \n" )
        cat > /opt/warp-go/$REGISTER_FILE << EOF
[Account]
Device = $API_DEVICE_ID
PrivateKey = $API_PRIVATEKEY
Token = $API_ACCESS_TOKEN
Type = $API_TYPE

[Device]
Name = WARP
PERSON = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.193.10:1701
KeepAlive = 30
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0

EOF
      be
    be

    if grep -sq 'Account' /opt/warp-go/$REGISTER_FILE; then
      echo -e "\n[Script]\nPostUp =\nPostDown =" >> /opt/warp-go/$REGISTER_FILE && sed -i 's/\r//' /opt/warp-go/$REGISTER_FILE
      if [ -n "$LICENSE" ]; then
        local RESULT=$(bash <(curl -m8 -sSL https://gitlab.com/fscarmen/warp/-/raw/main/api.sh) --file /opt/warp-go/$REGISTER_FILE --license $LICENSE)
        if [[ "$RESULT" =~ '"warp_plus": true' ]]; then
          bash <(curl -m8 -sSL https://gitlab.com/fscarmen/warp/-/raw/main/api.sh) --file /opt/warp-go/$REGISTER_FILE --name $NAME >/dev/null 2>&1
          echo "$LICENSE" > /opt/warp-go/License
          echo "$NAME" > /opt/warp-go/Device_Name
          sed -i "s/Type =.*/Type = plus/g" /opt/warp-go/$REGISTER_FILE
          [[ -z "$NF" && -z "$EXPECT" ]] && info "\n License: $LICENSE $(text_eval 105) \n"
        else
          warning "\n License: $LICENSE $(text_eval 106) \n"
        be
      elif [[ -s /opt/warp-go/License && -s /opt/warp-go/Device_Name ]]; then
        if [ -s /opt/warp-go/warp.conf.tmp ]; then
          bash <(curl -m8 -sSL https://gitlab.com/fscarmen/warp/-/raw/main/api.sh) --file /opt/warp-go/$REGISTER_FILE --license $(cat /opt/warp-go/License 2>/dev/null) >/dev/null 2>&1
          bash <(curl -m8 -sSL https://gitlab.com/fscarmen/warp/-/raw/main/api.sh) --file /opt/warp-go/$REGISTER_FILE --name $(cat /opt/warp-go/Device_Name 2>/dev/null) >/dev/null 2>&1
        be
      be
    else
      rm -f /opt/warp-go/$REGISTER_FILE
    be
 done
}

# WARP switch, first check if it is installed, then switch to the opposite state according to the current state
onoff() {
  case "$STATUS" in
    0 )
      need_install
      ;;
    1 )
      net
      ;;
    2 )
      ${SYSTEMCTL_STOP[int]}; info " $(text 27) "
  esac
}

# Check the system WARP single and double stack. For speed, first check the warp-go configuration file, then judge the trace
check_stack() {
  if [ -s /opt/warp-go/warp.conf ]; then
    if grep -q "^#AllowedIPs" /opt/warp-go/warp.conf; then
      T4=2
    else
      grep -q ".*0\.\0\/0" 2>/dev/null /opt/warp-go/warp.conf && T4=1 || T4=0
      grep -q ".*\:\:\/0" 2>/dev/null /opt/warp-go/warp.conf && T6=1 || T6=0
    be
  else
    case "$TRACE4" in
      off )
        T4='0'
        ;;
      'on'|'more' )
        T4='1'
    esac
    case "$TRACE6" in
      off )
        T6='0'
        ;;
      'on'|'more' )
        T6='1'
    esac
  be
  CASE=("@0" "0@" "0@0" "@1" "0@1" "1@" "1@0" "1@1" "2@" "@")
  for m in ${!CASE[@]}; do
    [ "$T4@$T6" = "${CASE[m]}" ] && break
  done
  WARP_BEFORE=("" "" "" "WARP $(text 99) IPv6 only" "WARP $(text 99) IPv6" "WARP $(text 99) IPv4 only" "WARP $(text 99) IPv4" "WARP $(text 99) $(text 96)" "WARP $(text 98) $(text 96)")
  WARP_AFTER1=("" "" "" "WARP $(text 99) IPv4" "WARP $(text 99) IPv4" "WARP $(text 99) IPv6" "WARP $(text 99) IPv6" "WARP $(text 99) IPv4" "WARP $(text 99) IPv4")
  WARP_AFTER2=("" "" "" "WARP $(text 99) $(text 96)" "WARP $(text 99) $(text 96)" "WARP $(text 99) $(text 96)" "WARP $(text 99) $(text 96)" "WARP $(text 99) IPv6" "WARP $(text 99) $(text 96)")
  TO1=("" "" "" "014" "014" "106" "106" "114" "014")
  TO2=("" "" "" "01D" "01D" "10D" "10D" "116" "01D")
  SHORTCUT1=("" "" "" "(warp-go 4)" "(warp-go 4)" "(warp-go 6)" "(warp-go 6)" "(warp-go 4)" "(warp-go 4)")
  SHORTCUT2=("" "" "" "(warp-go d)" "(warp-go d)" "(warp-go d)" "(warp-go d)" "(warp-go 6)" "(warp-go d)")

  # The judgment is used to detect NAT VSP and select the correct configuration file
  if [ "$m" -le 3 ]; then
    NAT=("0@1@" "1@0@1" "1@1@1" "0@1@1")
    for n in ${!NAT[@]}; do [ "$IPV4@$IPV6@$INET4" = "${NAT[n]}" ] && break; done
    NATIVE=("IPv6 only" "IPv4 only" "$(text 94)" "NAT IPv4")
    CONF1=("014" "104" "114" "11N4")
    CONF2=("016" "106" "116" "11N6")
    CONF3=("01D" "10D" "11D" "11ND")
  elif [ "$m" = 8 ]; then
    error "\n $(text 108) \n"
  be
}

# Check global status
check_global() {
  [ -s /opt/warp-go/warp.conf ] && grep -q '#AllowedIPs' /opt/warp-go/warp.conf && NON_GLOBAL=1
}

# Online swap of single and double stacks. First check if there is a choice in the menu, then check the parameter value, and then no two options are displayed.
stack_switch() {
  need_install
  check_global
  if [ "$NON_GLOBAL" = 1 ]; then
    if [[ "$CHOOSE" != [12] ]]; then
      warning " $(text 28) " && reading " $(text 29) " TO_GLOBAL
      [[ "$TO_GLOBAL" != [Yy] ]] && exit 0 || global_switch
    else
      global_switch
    be
  be

  # WARP single-stack or double-stack switching options
  SWITCH014="s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g"
  SWITCH01D="s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g"
  SWITCH106="s#AllowedIPs.*#AllowedIPs = ::/0#g"
  SWITCH10D="s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g"
  SWITCH114="s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g"
  SWITCH116="s#AllowedIPs.*#AllowedIPs = ::/0#g"

  check_stack

  if [[ "$CHOOSE" = [12] ]]; then
    TO=$(eval echo \${TO$CHOOSE[m]})
  elif [[ "$SWITCHCHOOSE" = [46D] ]]; then
    if [[ "$TO_GLOBAL" = [Yy] ]]; then
      if [[ "$T4@$T6@$SWITCHCHOOSE" =~ '1@0@4'|'0@1@6'|'1@1@D' ]]; then
        grep -q "^AllowedIPs.*0\.\0\/0" 2>/dev/null /opt/warp-go/warp.conf || unset INTERFACE4 INTERFACE6
        OPTION=o && net
        exit 0
      else
        TO="$T4$T6$SWITCHCHOOSE"
      be
    else
      [[ "$T4@$T6@$SWITCHCHOOSE" =~ '1@0@4'|'0@1@6'|'1@1@D' ]] && error " $(text 30) " || TO="$T4$T6$SWITCHCHOOSE"
    be
  else
    STACK_OPTION[1]="$(text_eval 31)"; STACK_OPTION[2]="$(text_eval 32)"
    hint "\n $(text_eval 33) \n" && reading " $(text 4) " SWITCHTO
    case "$SWITCHTO" in
      1 )
        TO=${TO1[m]}
        ;;
      2 )
        TO=${TO2[m]}
        ;;
      0 )
        exit
        ;;
      * )
        warning " $(text 34) [0-2] "; sleep 1; stack_switch
    esac
  be

  [ "${#TO}" != 3 ] && error " $(text 10) " || sed -i "$(eval echo "\$SWITCH$TO")" /opt/warp-go/warp.conf
  case "$TO" in
    014|114 )
      INTERFACE4='--interface WARP'; unset INTERFACE6
      ;;
    106|116 )
      INTERFACE6='--interface WARP'; unset INTERFACE4
      ;;
    01D|10D )
      INTERFACE4='--interface WARP'; INTERFACE6='--interface WARP'
  esac

  OPTION=o && net
}

# Global/non-global online swap
global_switch() {
  # If the status is not installing, check whether warp-go is installed. If it is installed, stop systemd
  if [ "$STATUS" != 3 ]; then
    need_install
    ${SYSTEMCTL_STOP[int]}
  be

  if grep -q "^Allowed" /opt/warp-go/warp.conf; then
    sed -i "s/^#//g; s/^AllowedIPs.*/#&/g" /opt/warp-go/warp.conf
    sleep 2
  else
    sed -i "s/^#//g; s/.*NonGlobal/#&/g" /opt/warp-go/warp.conf
    unset GLOBAL_TYPE
  be

  # If the status is not installing, or it is not a shortcut or menu selection when converting from non-global to global, then start systemd,
  if [[ "$STATUS" != 3 && "$TO_GLOBAL" != [Yy] && "$CHOOSE" != [12] ]]; then
    ${SYSTEMCTL_START[int]}
    OPTION=o && net
  be
}

# Detect system information
check_system_info() {
  info " $(text 35) "

  # Since warp-go has built-in wireguard-go, wireguard-go will first determine the tun device when it runs. If the file does not exist, it will exit immediately.
  [ ! -e /dev/net/tun ] && error "$(text 36)"

  # The TUN module must be loaded. Try to open TUN online first. If the attempt is successful, put it in the startup item. If it fails, prompt and exit the script
  TUN=$(cat /dev/net/tun 2>&1 | tr 'AZ' 'az')
  if [[ ! "$TUN" =~ 'in bad state'|'in bad state' ]]; then
    mkdir -p /opt/warp-go/ >/dev/null 2>&1
    cat >/opt/warp-go/tun.sh << EOF
#!/usr/bin/env bash
mkdir -p /dev/net
mknod /dev/net/tun c 10 200 2>/dev/null
[ ! -e /dev/net/tun ] && exit 1
chmod 0666 /dev/net/tun
EOF
    bash /opt/warp-go/tun.sh
    TUN=$(cat /dev/net/tun 2>&1 | tr 'AZ' 'az')
    if [[ ! "$TUN" =~ 'in bad state'|'in bad state' ]]; then
      rm -f /opt/warp-go/tun.sh && error "$(text 36)"
    else
      chmod +x /opt/warp-go/tun.sh
      echo "$SYSTEM" | grep -qvE "Alpine|OpenWrt" && echo "@reboot root bash /opt/warp-go/tun.sh" >> /etc/crontab
    be
  be

  # Determine the machine's native state type
  IPV4=0; IPV6=0
  LAN4=$(ip route get 192.168.193.10 2>/dev/null | awk '{for (i=0; i<NF; i++) if ($i=="src") {print $(i+1)}}')
  LAN6=$(ip route get 2606:4700:d0::a29f:c001 2>/dev/null | awk '{for (i=0; i<NF; i++) if ($i=="src") {print $(i+1)}}')
  [[ "$LAN4" =~ ^([0-9]{1,3}\.){3} ]] && INET4=1
  [[ "$LAN6" != "::1" && "$LAN6" =~ ^[a-f0-9:]+$ ]] && INET6=1
  [ "$INET6" = 1 ] && $PING6 -c2 -w10 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && IPV6=1 && STACK=-6
  [ "$INET4" = 1 ] && ping -c2 -W3 162.159.193.10 >/dev/null 2>&1 && IPV4=1 && STACK=-4

  if [ "$STATUS" != 0 ]; then
    if grep -qE "^AllowedIPs.*\.0/0,::/0|^#AllowedIPs" 2>/dev/null /opt/warp-go/warp.conf; then
      INTERFACE4='--interface WARP'; INTERFACE6='--interface WARP'
    elif grep -q '^AllowedIPs.*\.0/0$' 2>/dev/null /opt/warp-go/warp.conf; then
      INTERFACE4='--interface WARP'; unset INTERFACE6
    elif grep -q '^AllowedIPs.*::/0$' 2>/dev/null /opt/warp-go/warp.conf; then
      INTERFACE6='--interface WARP'; unset INTERFACE4
    be
  be

  [ "$IPV4" = 1 ] && ip4_info
  [ "$IPV6" = 1 ] && ip6_info

  if [ "$L" = C ]; then
    [ -n "$COUNTRY4" ] && COUNTRY4=$(translate "$COUNTRY4")
    [ -n "$COUNTRY6" ] && COUNTRY6=$(translate "$COUNTRY6")
  be
}

# Enter your WARP+ account number (if any). The limit is to leave it blank or 26 digits to prevent input errors.
input_license() {
  [ -z "$LICENSE" ] && reading " $(text 38) " LICENSE
  i=5
  until [[ -z "$LICENSE" || "$LICENSE" =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
    (( i-- )) || true
    [ "$i" = 0 ] && error "$(text 39)" || reading " $(text_eval 40) " LICENSE
  done
  [[ -n "$LICENSE" && -z "$NAME" ]] && reading " $(text 41) " NAME
  [ -n "$NAME" ] && NAME="${NAME//[[:space:]]/_}" || NAME="${NAME:-warp-go}"
}

# Upgrade WARP+ account (if any), limit the number of digits to be empty or 26 to prevent input errors, WARP interface can customize the device name (no spaces between strings are allowed, if encountered, they will be replaced by _)
update_license() {
  [ -z "$LICENSE" ] && reading " $(text 42) " LICENSE
  i=5
  until [[ "$LICENSE" =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
  (( i-- )) || true
    [ "$i" = 0 ] && error "$(text 39)" || reading " $(text_eval 43) " LICENSE
  done
  [[ -n "$LICENSE" && -z "$NAME" ]] && reading " $(text 41) " NAME
  [ -n "$NAME" ] && NAME="${NAME//[[:space:]]/_}" || NAME="${NAME:-warp-go}"
}

# Enter the Teams account token (if any). If the TOKEN starts with com.cloudflare.warp, the redundant part will be automatically deleted.
input_token() {
  [ -z "$TOKEN" ] && reading " $(text 44) " TOKEN
  i=5
  until [[ -z "$TOKEN" || "${#TOKEN}" -ge "$TOKEN_LENGTH" ]]; do
    (( i-- )) || true
    [ "$i" = 0 ] && error "$(text 39)" || reading " $(text_eval 45) " TOKEN
  done
  [[ -n "$TOKEN" && -z "$NAME" ]] && reading " $(text 41) " NAME
  [ -n "$NAME" ] && NAME="${NAME//[[:space:]]/_}" || NAME="${NAME:-warp-go}"
}

# Free WARP account upgrade to WARP+ or Teams account
update() {
  need_install
  [ ! -s /opt/warp-go/warp.conf ] && error "$(text 21)"

  ACCOUNT_TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  case "$ACCOUNT_TYPE" in
    free )
      CHANGE_TYPE=$(text 47)
      ;;
    team )
      CHANGE_TYPE=$(text 48)
      ;;
    plus )
      CHANGE_TYPE=$(text 49)
      check_quota
      [[ "$QUOTA" =~ '.' ]] && PLUS_QUOTA="\\n $(text 26): $QUOTA"
  esac

  [ -z "$LICENSETYPE" ] && hint "\n $(text_eval 46) \n" && reading " $(text 4) " LICENSETYPE
  case "$LICENSETYPE" in
    1|2 )
      unset QUOTA
      case "$LICENSETYPE" in
        1 )
          k=' free'
          [ "$ACCOUNT_TYPE" = free ] && KEEP_FREE='1'
          [ -s /opt/warp-go/Device_Name ] && rm -f /opt/warp-go/Device_Name
          if [ "$ACCOUNT_TYPE" = free ]; then
            OPTION=o && net
            exit 0
          be
          ;;
        2 )
          k='+'
          update_license
      esac
      cp -f /opt/warp-go/warp.conf{,.tmp1}
      bash <(curl -m8 -sSL https://gitlab.com/fscarmen/warp/-/raw/main/api.sh) --file /opt/warp-go/warp.conf --cancle >/dev/null 2>&1
      [ -s /opt/warp-go/warp.conf ] && rm -f /opt/warp-go/warp.conf
      register_api warp.conf 58 59
      head -n +6 /opt/warp-go/warp.conf > /opt/warp-go/warp.conf.tmp2
      tail -n +7 /opt/warp-go/warp.conf.tmp1 >> /opt/warp-go/warp.conf.tmp2
      rm -f /opt/warp-go/warp.conf.tmp1
      mv -f /opt/warp-go/warp.conf.tmp2 /opt/warp-go/warp.conf
      OPTION=o && net
      ;;
    3 )
      unset QUOTA
      input_token
      if [ -n "$TOKEN" ]; then
        k=' teams'
        register_api warp.conf.tmp 58 59
        for a in {2..5}; do
          sed -i "${a}s#.*#$(sed -ne ${a}p /opt/warp-go/warp.conf.tmp)#" /opt/warp-go/warp.conf
        done
        rm -f /opt/warp-go/warp.conf.tmp
      else
        sed -i "s#^Device.*#Device = FSCARMEN-WARP-SHARE-TEAM#g; s#.*PrivateKey.*#PrivateKey = SHVqHEGI7k2+OQ/oWMmWY2EQObbRQjRBdDPimh0h1WY=#g; s#.*Token.*#Token = PROTECTED_PLACEHOLDER#g; s#.*Type.*#Type = team#g" /opt/warp-go/warp.conf
      be
      grep -qE 'Type[ ]+=[ ]+team' /opt/warp-go/warp.conf && echo "$NAME" > /opt/warp-go/Device_Name
      OPTION=o && net
      ;;
    0 )
      unset LICENSETYPE
      menu
      ;;
    * )
      warning " $(text 34) [0-3] "; sleep 1; unset LICENSETYPE; update
  esac
}

# Output wireguard and sing-box configuration files
export_file() {
  if [ -s /opt/warp-go/warp-go ]; then
    PY=("python3" "python" "python2")
    for g in "${PY[@]}"; do [ $(type -p $g) ] && PYTHON=$g && break; done
    [ -z "$PYTHON" ] && PYTHON=python3 && ${PACKAGE_INSTALL[int]} $PYTHON
    [ ! -s /opt/warp-go/warp.conf ] && register_api warp.conf
    /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-wireguard=/opt/warp-go/wgcf.conf >/dev/null 2>&1
    /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-singbox=/opt/warp-go/singbox.json >/dev/null 2>&1
  else
    error "$(text 51)"
  be

  info "\n $(text 52) "
  cat /opt/warp-go/wgcf.conf
  echo -e "\n\n"

  info " $(text 101) "
  cat /opt/warp-go/singbox.json | $PYTHON -m json.tool
  echo -e "\n\n"
}

# warp-go installation
install() {
  # If the status code is not 0, it has been installed and the script exits
  [ "$STATUS" != 0 ] && error "$(text 53)"

  # If the CONF parameter is not 3 or 4 digits, the script will exit if the correct configuration parameters cannot be detected.
  [[ "${#CONF}" != [34] ]] && error " $(text 10) "

  # First delete the previously installed files that may cause failure
  rm -rf /opt/warp-go/warp-go /opt/warp-go/warp.conf

  # Ask if you have a WARP+ or Teams account
  [ -z "$LICENSETYPE" ] && hint "\n $(text 54) \n" && reading " $(text 4) " LICENSETYPE
  case "$LICENSETYPE" in
    1 )
      input_license
      ;;
    2 )
      input_token
  esac

  # Choose to use IPv4 /IPv6 network first
  [ -z "$PRIORITY" ] && hint "\n $(text 55) \n" && reading " $(text 4) " PRIORITY

  # Script start time
  start=$(date +%s)

  # Find the best MTU and Endpoint values
  {
    # 详细说明:<[WireGuard] Header / MTU sizes for Wireguard>:https://lists.zx2c4.com/pipermail/wireguard/2017-December/002201.html
    PERSON=$((1500-28))
    [ "$IPV4$IPV6" = 01 ] && $PING6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1
    until [[ $? = 0 || $MTU -le $((1280+80-28)) ]]; do
      PERSON=$((PERSON-10))
      [ "$IPV4$IPV6" = 01 ] && $PING6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1
    done

    if [ "$MTU" -eq $((1500-28)) ]; then
      PERSON=$PERSON
    elif [ "$MTU" -le $((1280+80-28)) ]; then
      PERSON=$((1280+80-28))
    else
      for i in {0..8}; do
        (( PERSON++ ))
        ( [ "$IPV4$IPV6" = 01 ] && $PING6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1 ) || break
      done
      (( PERSON-- ))
    be

    PERSON=$((PERSON+28-80))

    echo "$MTU" > /tmp/warp-go-mtu

    # Find the best endpoint and download the endpoint library according to v4/v6
    wget $STACK -qO /tmp/endpoint https://gitlab.com/fscarmen/warp/-/raw/main/endpoint/warp-linux-${ARCHITECTURE//amd64*/amd64} && chmod +x /tmp/endpoint
    [ "$IPV4$IPV6" = 01 ] && wget $STACK -qO /tmp/ip https://gitlab.com/fscarmen/warp/-/raw/main/endpoint/ipv6 || wget $STACK -qO /tmp/ip https://gitlab.com/fscarmen/warp/-/raw/main/endpoint/ipv4

    if [[ -s /tmp/endpoint && -s /tmp/ip ]]; then
      /tmp/endpoint -file /tmp/ip -output /tmp/endpoint_result >/dev/null 2>&1
      # If all packets are lost, LOSS = 100%, it means UDP is disabled and the flag /tmp/noudp is generated
      [ "$(grep -sE '[0-9]+[ ]+ms$' /tmp/endpoint_result | awk -F, 'NR==1 {print $2}')" = '100.00%' ] && touch /tmp/noudp || ENDPOINT=$(grep -sE '[0-9]+[ ]+ms$' /tmp/endpoint_result | awk -F, 'NR==1 {print $1}')
      rm -f /tmp/{endpoint,ip,endpoint_result}
    be

    # If it fails, there will be a default value of 162.159.193.10:2408 or [2606:4700:d0::a29f:c001]:2408
    [ "$IPV4$IPV6" = 01 ] && ENDPOINT=${ENDPOINT:-'[2606:4700:d0::a29f:c001]:2408'} || ENDPOINT=${ENDPOINT:-'162.159.193.10:2408'}

    echo "$ENDPOINT" > /tmp/warp-go-endpoint

    info "\n $(text 9) \n"
  }&

  # Register a Teams account (will generate a warp file to save account information)
  {
    mkdir -p /opt/warp-go/ >/dev/null 2>&1
    wait
    [ ! -s /tmp/warp-go ] && error "$(text 56)" || mv -f /tmp/warp-go /opt/warp-go/
    [ ! -s /opt/warp-go/warp-go ] && error "$(text 57)"

    # Register a Teams account with a user-defined token
    if [ "$LICENSETYPE" = 2 ]; then
      if [ -n "$TOKEN" ]; then
        k=' teams'
        register_api warp.conf 58

    # Register a Teams account with a public token
      else
        cat > /opt/warp-go/warp.conf << EOF
[Account]
Device = FSCARMEN-WARP-SHARE-TEAM
PrivateKey = SHVqHEGI7k2+OQ/oWMmWY2EQObbRQjRBdDPimh0h1WY=
Token = PROTECTED_PLACEHOLDER
Type = team

[Device]
Name = WARP
PERSON = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.193.10:1701
KeepAlive = 30
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0

[Script]
#PostUp =
#PostDown =
EOF
      be

    # Register for Free and Plus accounts
    else
      [ -n "$LICENSE" ] && k='+' || k=' free'
      register_api warp.conf 58 59
    be

    # If it is a Plus or Team account, record the device name in the file /opt/warp-go/Device_Name; if it is a Plus account, save the License to /opt/warp-go/License;
    grep -qE 'Type[ ]+=[ ]+plus' /opt/warp-go/warp.conf && echo "$NAME" > /opt/warp-go/Device_Name && echo "$LICENSE" > /opt/warp-go/License
    grep -qE 'Type[ ]+=[ ]+team' /opt/warp-go/warp.conf && echo "$NAME" > /opt/warp-go/Device_Name

    # Generate a non-global executable file and grant permissions
    cat > /opt/warp-go/NonGlobalUp.sh << EOF
sleep 5
ip -4 rule add oif WARP lookup 60000
ip -4 rule add table main suppress_prefixlength 0
ip -4 route add default dev WARP table 60000
ip -6 rule add oif WARP lookup 60000
ip -6 rule add table main suppress_prefixlength 0
ip -6 route add default dev WARP table 60000
EOF

    cat > /opt/warp-go/NonGlobalDown.sh << EOF
ip -4 rule delete oif WARP lookup 60000
ip -4 rule delete table main suppress_prefixlength 0
ip -6 rule delete oif WARP lookup 60000
ip -6 rule delete table main suppress_prefixlength 0
EOF

    chmod +x /opt/warp-go/NonGlobalUp.sh /opt/warp-go/NonGlobalDown.sh

    info "\n $(text 61) \n"
  }

  # Enable IPv6 support for IPv4 only VPS
  {
    [ "$IPV4$IPV6" = 10 ] && [[ $(sysctl -a 2>/dev/null | grep 'disable_ipv6.*=.*1') || $(grep -s "disable_ipv6.*=.*1" /etc/sysctl.{conf,d/*} ) ]] &&
    (sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
    echo 'net.ipv6.conf.all.disable_ipv6 = 0' >/etc/sysctl.d/ipv6.conf
    sysctl -w net.ipv6.conf.all.disable_ipv6=0)
  }&

  # Give priority to IPv4 /IPv6 network
  { stack_priority; }&

  # Select the dependencies that need to be installed according to the system, and install some necessary network tool packages
  info "\n $(text 60) \n"

  case "$SYSTEM" in
    Alpine )
      ${PACKAGE_INSTALL[int]} openrc
      ;;
    Arch )
      ${PACKAGE_INSTALL[int]} openresolv
  esac

  wait

  # If all endpoints cannot be connected, the script terminates
  if [ -e /tmp/noudp ]; then
    rm -rf /tmp/noudp /opt/warp-go /lib/systemd/system/warp-go.service /usr/bin/warp-go /tmp/warp-go*
    error "\n $(text 107) \n"
  be

  # If registration is not successful, the script exits
  [ ! -s /opt/warp-go/warp.conf ] && error " $(text 104) "

  # warp-go configuration modification, the 162.159.193.10 and 2606:4700:d0::a29f:c001 used are the IP addresses of engage.cloudflareclient.com
  MTU=$(cat /tmp/warp-go-mtu) && rm -f /tmp/warp-go-mtu
  ENDPOINT=$(cat /tmp/warp-go-endpoint) && rm -f /tmp/warp-go-endpoint
  MODIFY014="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g; s#.*PostUp.*#PostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY016="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = ::/0#g; s#.*PostUp.*#PostUp   = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY01D="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g; s#.*PostUp.*#PostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY104="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY106="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = ::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY10D="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY114="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY116="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = ::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY11D="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY11N4="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY11N6="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = ::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY11ND="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"

  sed -i "$(eval echo "\$MODIFY$CONF")" /opt/warp-go/warp.conf

  # If WARP IPv4 is non-global, modify the configuration file and insert rules in the routing table
  [ "$OPTION" = n ] && STATUS=3 && global_switch

  # Create warp-go systemd process daemon (except Alpine system)
  if echo "$SYSTEM" | grep -qvE "Alpine|OpenWrt"; then
    cat > /lib/systemd/system/warp-go.service << EOF
[Unit]
Description=warp-go service
After=network.target
Documentation=https://github.com/fscarmen/warp-sh
Documentation=https://gitlab.com/ProjectWARP/warp-go

[Service]
RestartSec=2s
WorkingDirectory=/opt/warp-go/
ExecStart=/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf
Environment="LOG_LEVEL=verbose"
RemainAfterExit=yes
Restart=always

[Install]
WantedBy=multi-user.target
EOF
  be

  # Run warp-go
  net

  # Set the boot
  ${SYSTEMCTL_ENABLE[int]} >/dev/null 2>&1

  # Create a soft link shortcut. Run it again with the warp-go command to set the default language
  mv $0 /opt/warp-go/warp-go.sh
  chmod +x /opt/warp-go/warp-go.sh
  ln -sf /opt/warp-go/warp-go.sh /usr/bin/warp-go
  echo "$L" > /opt/warp-go/language

  # Result prompt, script running time, number of times, IPv4 / IPv6 priority level
  [ "$(curl -ksm8 -A Mozilla ${IP_API[3]} | grep 'ip=' | cut -d= -f2)" = "$WAN6" ] && PRIO=6 || PRIO=4
  end=$(date +%s)
  ACCOUNT_TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  [ "$ACCOUNT_TYPE" = 'plus' ] && check_quota
  result_priority

  echo -e "\n==============================================================\n"
  info " IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
  info " IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  info " $(text_eval 62) "
  [ "$ACCOUNT_TYPE" = 'plus' ] && info " $(text 83): $(cat /opt/warp-go/Device_Name)\t $(text 26): $QUOTA "
  [ "$ACCOUNT_TYPE" = 'team' ] && info " $(text 83): $(cat /opt/warp-go/Device_Name)\t $(text 26): $(text 103) "
  info " $PRIORITY_NOW "
  echo -e "\n==============================================================\n"
  hint " $(text 95)\n " && help
  [ "$TRACE4$TRACE6" = offoff ] && warning " $(text 63) "
  exit
}

# Check WARP+ balance flow interface
check_quota() {
  if [ -s /opt/warp-go/warp.conf ]; then
    ACCESS_TOKEN=$(grep 'Token' /opt/warp-go/warp.conf | cut -d= -f2 | sed 's# ##g')
    DEVICE_ID=$(grep -m1 'Device' /opt/warp-go/warp.conf | cut -d= -f2 | sed 's# ##g')
    API=$(curl -s "https://api.cloudflareclient.com/v0a884/reg/$DEVICE_ID" -H "User-Agent: okhttp/3.12.1" -H "Authorization: Bearer $ACCESS_TOKEN")
    QUOTA=$(sed 's/.*quota":\([^,]\+\).*/\1/g' <<< $API)
  be

  # Some systems do not rely on bc, so two decimals cannot use $(echo "scale=2; $QUOTA/1000000000000000" | bc). Instead, count the number of characters from right to left.
  if [[ "$QUOTA" != 0 && "$QUOTA" =~ ^[0-9]+$ && "$QUOTA" -ge 1000000000 ]]; then
    CONVERSION=("1000000000000000000" "1000000000000000" "1000000000000" "1000000000")
    UNIT=("EB" "PB" "TB" "GB")
    for o in ${!CONVERSION[*]}; do
      [[ "$QUOTA" -ge "${CONVERSION[o]}" ]] && break
    done

    QUOTA_INTEGER=$(( $QUOTA / ${CONVERSION[o]} ))
    QUOTA_DECIMALS=${QUOTA:0-$(( ${#CONVERSION[o]} - 1 )):2}
    QUOTA="$QUOTA_INTEGER.$QUOTA_DECIMALS ${UNIT[o]}"
  be
}

# Determine the current running status of the WARP network interface and Client, and assign corresponding values ​​to the menu and action
menu_setting() {
  if [ "$STATUS" = 0 ]; then
    MENU_OPTION[1]="$(text_eval 64)"
    MENU_OPTION[2]="$(text_eval 65)"
    MENU_OPTION[3]="$(text_eval 66)"
    MENU_OPTION[4]="$(text_eval 67)"
    MENU_OPTION[5]="$(text_eval 68)"
    MENU_OPTION[6]="$(text_eval 69)"
    MENU_OPTION[7]="$(text_eval 70)"
    MENU_OPTION[8]="$(text_eval 71)"
    ACTION[1]() { CONF=${CONF1[n]}; PRIORITY=1; install; }
    ACTION[2]() { CONF=${CONF1[n]}; PRIORITY=2; install; }
    ACTION[3]() { CONF=${CONF2[n]}; PRIORITY=1; install; }
    ACTION[4]() { CONF=${CONF2[n]}; PRIORITY=2; install; }
    ACTION[5]() { CONF=${CONF3[n]}; PRIORITY=1; install; }
    ACTION[6]() { CONF=${CONF3[n]}; PRIORITY=2; install; }
    ACTION[7]() { CONF=${CONF3[n]}; PRIORITY=1; OPTION=n; install; }
    ACTION[8]() { CONF=${CONF3[n]}; PRIORITY=2; OPTION=n; install; }
  else
    [ "$NON_GLOBAL" = 1 ] || GLOBAL_AFTER="$(text 24)"
    [ "$STATUS" = 2 ] && ON_OFF="$(text 72)" || ON_OFF="$(text 73)"
    MENU_OPTION[1]="$(text_eval 74)"
    MENU_OPTION[2]="$(text_eval 75)"
    MENU_OPTION[3]="$(text_eval 76)"
    MENU_OPTION[4]="$ON_OFF"
    MENU_OPTION[5]="$(text_eval 77)"

    MENU_OPTION[6]="$(text 78)"
    MENU_OPTION[7]="$(text 79)"
    MENU_OPTION[8]="$(text 80)"
    ACTION[1]() { stack_switch; }
    ACTION[2]() { stack_switch; }
    ACTION[3]() { global_switch; }
    ACTION[4]() { OPTION=o; onoff; }
    ACTION[5]() { update; }
    ACTION[6]() { change_ip; }
    ACTION[7]() { export_file; }
    ACTION[8]() { uninstall; }
  be

  MENU_OPTION[0]="$(text 81)"
  MENU_OPTION[9]="$(text 82) (warp-go v)"
  ACTION[0]() { rm -f /tmp/warp-go*; exit; }
  ACTION[9]() { ver; }

  [ -s /opt/warp-go/warp.conf ] && TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  [ "$TYPE" = 'plus' ] && check_quota && PLUSINFO="$(text 83): $(cat /opt/warp-go/Device_Name)\t $(text 26): $QUOTA"
  [ "$TYPE" = 'team' ] && PLUSINFO="$(text 83): $(cat /opt/warp-go/Device_Name)\t $(text 26): $(text 103)"
}

# Display menu
menu() {
	clear
	hint " $(text 3) "
	echo -e "======================================================================================================================\n"
	info " $(text 84): $VERSION\n $(text 85): $(text 1)\n $(text 86):\n\t $(text 87): $SYS\n\t $(text 88): $(uname -r)\n\t $(text 89): $ARCHITECTURE\n\t $(text 90): $VIRT "
	info "\t IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
	info "\t IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  if [ "$STATUS" = 2 ]; then
    info "\t $(text_eval 91) "
    grep -q '#AllowedIPs' /opt/warp-go/warp.conf && GLOBAL_TYPE="$(text 24)"
    info "\t $(text_eval 92) "
  else
    info "\t $(text 93) "
  be
  [ -n "$PLUSINFO" ] && info "\t $PLUSINFO "
 	echo -e "\n======================================================================================================================\n"
	for ((d=1; d<=${#MENU_OPTION[*]}; d++)); do [ "$d" = "${#MENU_OPTION[*]}" ] && d=0 && hint " $d. ${MENU_OPTION[d]} " && break || hint " $d. ${MENU_OPTION[d]} "; done
  reading "\n $(text 4) " CHOOSE

  # Input must be a number and less than or equal to the maximum possible value
  if [[ "$CHOOSE" =~ ^[0-9]+$ ]] && (( $CHOOSE >= 0 && $CHOOSE < ${#MENU_OPTION[*]} )); then
    ACTION[$CHOOSE]
  else
    warning " $(text 34) [0-$((${#MENU_OPTION[*]}-1))] " && sleep 1 && menu
  be
}

# OPTIONS: 1 = Complete another stack WARP for IPv4 or IPv6; 2 = Install dual stack WARP; u = Uninstall WARP
[ "$1" != '[option]' ] && OPTION=$(tr 'A-Z' 'a-z' <<< "$1")

# Parameter option URL or License or conversion WARP single or double stack
if [ "$2" != '[lisence]' ]; then
  if [[ "$2" =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; then
    LICENSETYPE='2' && LICENSE="$2"
  elif [[ "${#2}" -ge "$TOKEN_LENGTH" ]]; then LICENSETYPE='3' && TOKEN="$2"
  elif [[ "$2" =~ ^[A-Za-z]{2}$ ]]; then EXPECT="$2"
  elif [[ "$1" = s && "$2" = [46Dd] ]]; then PRIORITY_SWITCH=$(tr 'A-Z' 'a-z' <<< "$2")
  be
be

# Customize WARP+ device name
NAME="$3"

# Main program runs 1/3
statistics_of_run-times
select_language
check_operating_system
check_arch
check_dependencies
check_install

# Set partial suffix 1/3
case "$OPTION" in
  h )
    help; exit 0
    ;;
  i )
    change_ip; exit 0
    ;;
  e )
    export_file; exit 0
    ;;
  s )
    stack_priority; result_priority; exit 0
esac

# Main program runs 2/3
check_root_virt $SYSTEM

# Set partial suffix 2/3
case "$OPTION" in
  in )
    uninstall; exit 0
    ;;
  in )
    ver; exit 0
    ;;
  o )
    onoff; exit 0
    ;;
  g )
    global_switch; exit 0
esac

# Main program runs 3/3
check_system_info
check_global
check_stack
menu_setting

# Set partial suffix 3/3
case "$OPTION" in
  [46dn] )
    if [[ $STATUS != 0 ]]; then
      SWITCHCHOOSE="$(tr 'a-z' 'A-Z' <<< "$OPTION")"
      stack_switch
    else
      case "$OPTION" in
        4 ) CONF=${CONF1[n]} ;;
        6 ) CONF=${CONF2[n]} ;;
        d|n ) CONF=${CONF3[n]} ;;
      esac
      install
    be
    ;;
  a )
    update
    ;;
  * ) menu
esac
