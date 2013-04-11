#!/bin/bash

# Set iDRAC privilege level via ipmitool
# 04/2012 Marcus Furlong <furlongm@gmail.com> - Initial version

ipmitool=`which ipmitool`

function usage () {

  echo "usage: $0 [userid] [privilege level]"
  echo " userid is an integer 2-9 (usually 2 is builtin as ADMIN user)"
  echo " privilege level is an integer 0-3:"
  echo " 0:none 1:readonly 2:operator 3:admin"
  echo " builtin ADMIN user cannot be set to level 0"

}

function is_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1); }

if [ "${ipmitool}" = "" ] ; then
  echo "ipmitool not found"
  exit 1
fi

if $(is_int "$1") || $(is_int "$2") ; then
  :
else
  usage
  exit 0
fi

user_id=$1

case $2 in
  0)
    priv="0x00 0x00 0x00 0x00"
    ;;
  1)
    priv="0x01 0x00 0x00 0x00"
    ;;
  2)
    priv="0xf3 0x01 0x00 0x00"
    ;;
  3)
    priv="0xff 0x01 0x00 0x00"
    ;;
  *)
    usage
    exit 1
esac

reservation_id=`${ipmitool} raw 0x2e 0x01 0xa2 0x02 0x00 | cut -d " " -f 5`
output=`${ipmitool} raw 0x2e 0x03 0xa2 0x02 0x00 0x${reservation_id} 0x04 0x${user_id} 0x00 0x00 0x01 0x09 0x00 0x01 0x01 0x00 ${priv}`

if [ "${output}" != " a2 02 00 09" ] ; then
  echo "Strange response: ${output}"
fi
