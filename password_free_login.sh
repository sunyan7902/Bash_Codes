#!/bin/bash

# 创建密钥对
ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa -q

# 声明你服务器密码，建议所有节点的密码均一致，否则该脚本需要再次进行优化
export mypasswd=wsgwz7902

# 定义主机列表
k8s_host_list=(sunyan-pve centos7-01 centos7-02 centos7-03 ubuntu22-sunyan)

# 配置免密登录，利用expect工具免交互输入
for i in ${k8s_host_list[@]};do
expect -c "
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$i
  expect {
    \"*yes/no*\" {send \"yes\r\"; exp_continue}
    \"*password*\" {send \"$mypasswd\r\"; exp_continue}
  }"
done
