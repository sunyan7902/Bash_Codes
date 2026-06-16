#!/bin/bash
# ==============================================================================
# Author: sunyan
# Email: sunyan2002@foxmail.com
# LastUpdate: 2026-06-16
# Description: 修改 Linux 服务器的主机名与 IP 地址的最后一项，并重启网络服务
# ==============================================================================

# 检查参数数量是否为 2
if [[ $# -ne 2 ]]; then
    echo "脚本使用姿势不对"
    echo "正确姿势: $0 主机名 ip地址"
    exit 1
fi

# 获取当前主机 IP 地址的最后一段
ip=$(hostname -I | awk '{print $1}' | sed 's#.*\.##g')

# 提取传入的新 IP 地址的最后一段
ip_new=$(echo "$2" | sed 's#^.*\.##g')

# 新的主机名
hostname=$1

# 修改 /etc/sysconfig/network-scripts/ifcfg-eth0 文件中的 IP 地址
sed -i "s#192.168.0.$ip#192.168.0.$ip_new#g" /etc/sysconfig/network-scripts/ifcfg-eth0
# 如果有其他网卡，可以取消注释并修改下面这行
# sed -i "s#172.16.1.$ip#172.16.1.$ip_new#g" /etc/sysconfig/network-scripts/ifcfg-eth1

# 重启网卡服务以使 IP 生效
systemctl restart network

# 修改主机名
hostnamectl set-hostname "$hostname"
