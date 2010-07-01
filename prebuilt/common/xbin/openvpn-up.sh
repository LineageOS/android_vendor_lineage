#!/system/xbin/bash
#
# /system/xbin/openvpn-up.sh v0.2
#
# Philip Freeman <philip.freeman@gmail.com>
#
# TODO: add support for grabbing search domains ?
#
# Changes:
#-- v0.2
# - Added system logging
# - Fixed fome path issues
#

LOG="/system/bin/log -t openvpn-up"
SETPROP=/system/bin/setprop
EXPR=/system/xbin/expr
stop=0
dns_num=1
i=0

${LOG} "Starting..."

eval opt=\$foreign_option_$i

while [ ${stop} -eq 0 ]; do
  if [ "`${EXPR} substr "$opt" 1 11`" = "dhcp-option" ]; then
    if [ "`${EXPR} substr "$opt" 13 3`" = "DNS" ]; then
      DNS="`${EXPR} substr "$opt" 17 1024`"
      ${LOG} "Got DNS${dns_num}: ${DNS}"
      if [ ${dns_num} -le 2 ]; then
	#Set it
	${LOG} ${SETPROP} vpn.dns${dns_num} ${DNS}
	${SETPROP} vpn.dns${dns_num} ${DNS}
      fi
      dns_num=$(( ${dns_num}+1 ))
    fi
  fi
  i=$(( $i+1 ))
  eval opt=\$foreign_option_$i
  if [ "$opt" = "" ]; then
    stop=1
  fi
done
