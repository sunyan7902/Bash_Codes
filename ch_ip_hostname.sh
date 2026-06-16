#!/bin/bash
#desc: change ip and hostname

[ $# -ne 2 ] && {
echo "脚本使用姿势不对"
echo "正确姿势:$0 主机名 ip地址"
exit 1
}

#获取当前主机ip地址
ip=`hostname -I |awk '{print $1}'|sed 's#.*\.##g'`

#新的ip
ip_new=`echo $2 |sed 's#^.*\.##g'`

#新的主机名
hostname=$1

#修改ip
sed -i "s#192.168.0.$ip#192.168.0.$ip_new#g" /etc/sysconfig/network-scripts/ifcfg-eth0
#sed -i "s#172.16.1.$ip#172.16.1.$ip_new#g" /etc/sysconfig/network-scripts/ifcfg-eth1

#重启网卡
systemctl restart network
#修改主机名
hostnamectl set-hostname $hostname
