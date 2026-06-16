#!/bin/bash
# ==============================================================================
# Author: sunyan
# Email: sunyan2002@foxmail.com
# LastUpdate: 2026-06-16
# Description: 自动化配置 SSH 免密登录，自动生成密钥对并分发至指定主机列表
# ==============================================================================

# 创建密钥对（如果已存在，这里默认会静默覆盖或跳过）
ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa -q

# 声明服务器密码（建议所有节点密码一致，否则脚本需要进一步重构）
export mypasswd=xxxxxxxx

# 定义目标主机列表
k8s_host_list=(centos7-01 centos7-02 centos7-03)

# 配置免密登录，利用 expect 工具进行免交互密码输入
for host in "${k8s_host_list[@]}"; do
    expect -c "
    spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$host
      expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*password*\" {send \"$mypasswd\r\"; exp_continue}
      }"
done
