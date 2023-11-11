#!/bin/sh

host_key=/etc/dropbear/dropbear_rsa_host_key
host_key_bk=/data/auto_ssh/dropbear_rsa_host_key

# Restore the host key.
[ -f $host_key_bk ] && ln -sf $host_key_bk $host_key

# Enable telnet, ssh, uart and boot_wait.
[ "$(nvram get telnet_en)" = 0 ] && nvram set telnet_en=1 && nvram commit
[ "$(nvram get ssh_en)" = 0 ] && nvram set ssh_en=1 && nvram commit
[ "$(nvram get uart_en)" = 0 ] && nvram set uart_en=1 && nvram commit
[ "$(nvram get boot_wait)" = "off" ] && nvram set boot_wait=on && nvram commit

[ "$(uci -c /usr/share/xiaoqiang get xiaoqiang_version.version.CHANNEL)" != 'stable' ] && {
	uci -c /usr/share/xiaoqiang set xiaoqiang_version.version.CHANNEL='stable'
	uci -c /usr/share/xiaoqiang commit xiaoqiang_version.version 2>/dev/null
}

channel=$(/sbin/uci get /usr/share/xiaoqiang/xiaoqiang_version.version.CHANNEL)
if [ "$channel" = "release" ]; then
   sed -i 's/channel=.*/channel="debug"/g' /etc/init.d/dropbear
fi

if [ -z "$(pidof dropbear)" -o -z "$(netstat -ntul | grep :22)" ]; then
  /etc/init.d/dropbear restart 2>/dev/null
  /etc/init.d/dropbear enable
# Wifi txpower for me
  (sleep 60;iwconfig wl0 txpower 21;iwconfig wl1 txpower 17)&
# Miwifi off
 cat << 'EOF' >> /etc/hosts

  ::1     localhost ip6-localhost ip6-loopback
  ff02::1 ip6-allnodes
  ff02::2 ip6-allrouters

  0.0.0.0 baidu.com taobao.com xiaomi.cn xiaomi.com
  0.0.0.0 www.baidu.com www.taobao.com www.xiaomi.cn www.xiaomi.com
  ::1     baidu.com taobao.com xiaomi.cn xiaomi.com
  ::1     www.baidu.com www.taobao.com www.xiaomi.cn www.xiaomi.com
  0.0.0.0 www.miwifi.com miwifi.com log.miwifi.com s.miwifi.com app.miwifi.com stun.miwifi.com broker.miwifi.com
  ::1     www.miwifi.com miwifi.com log.miwifi.com s.miwifi.com app.miwifi.com stun.miwifi.com broker.miwifi.com
  0.0.0.0 bbs.xiaomi.cn bbs.xiaomi.com
  ::1     bbs.xiaomi.cn bbs.xiaomi.com
  EOF
  
  /etc/init.d/network reload
fi

# Backup the host key.
if [ ! -s $host_key_bk ]; then
    i=0
    while [ $i -le 30 ]
    do
        if [ -s $host_key ]; then
            cp -f $host_key $host_key_bk 2>/dev/null
            break
        fi
        let i++
        sleep 1s
    done
fi
