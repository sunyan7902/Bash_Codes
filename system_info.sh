#!/bin/bash
# ==============================================================================
# Author: sunyan
# Email: sunyan2002@foxmail.com
# LastUpdate: 2026-06-16
# Description: Linux 服务器状态巡检报告脚本，收集系统、网络、资源、存储和进程信息
# ==============================================================================

# 强制使用英文环境，确保命令解析一致性
export LC_ALL=C

# ================= 颜色与格式定义 =================
C_RESET='\e[0m'
C_TITLE='\e[1;36m'   # 青色加粗 (标题)
C_LABEL='\e[1;33m'   # 黄色加粗 (标签)
C_VALUE='\e[1;32m'   # 绿色加粗 (正常值)
C_LINE='\e[1;30m'    # 灰色加粗 (分隔线)

# 取消 printf 动态对齐，直接原样输出（传参时已做好严格中英文宽度对齐）
print_item() {
    echo -e "${C_LABEL}$1${C_RESET} : ${C_VALUE}$2${C_RESET}"
}
print_title() {
    echo -e "\n${C_TITLE}>>> $1${C_RESET}"
    echo -e "${C_LINE}--------------------------------------------------${C_RESET}"
}

# ================= 数据采集与输出 =================

echo -e "${C_TITLE}==================================================${C_RESET}"
echo -e "${C_TITLE}              Linux 服务器状态巡检报告            ${C_RESET}"
echo -e "${C_TITLE}==================================================${C_RESET}"

# --- [1] 系统与网络信息 ---
print_title "1. 系统与网络信息"
hostname=$(hostname)
main_ip=$(hostname -I | awk '{print $1}')
os_version=$(grep -E "^PRETTY_NAME=" /etc/os-release | cut -d'"' -f2)
kernel_version=$(uname -r)
uptime_info=$(uptime -p | sed 's/up //')
load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

# 严格 16 列宽度对齐 (中文算2列，英文/数字/空格算1列)
print_item "主机名称        " "${hostname}"
print_item "核心 IP         " "${main_ip}"
print_item "系统版本        " "${os_version}"
print_item "内核版本        " "${kernel_version}"
print_item "运行时间        " "${uptime_info}"
print_item "系统平均负载    " "${load_avg}"

# --- [2] 计算资源状态 ---
print_title "2. 计算资源状态"
cpu_model=$(grep -m 1 'model name' /proc/cpuinfo | awk -F': ' '{print $2}' | xargs)
cpu_cores=$(nproc)
cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
cpu_usage=$(awk "BEGIN {printf \"%.2f%%\", 100 - $cpu_idle}")
mem_total=$(free -h | awk '/^Mem:/ {print $2}')
mem_usage=$(free -m | awk '/^Mem:/ {printf "%.2f%%", $3/$2 * 100}')

print_item "CPU 型号        " "${cpu_model}"
print_item "CPU 逻辑核数    " "${cpu_cores} Cores"
print_item "CPU 使用率      " "${cpu_usage}"
print_item "物理内存容量    " "${mem_total}"
print_item "内存使用率      " "${mem_usage}"

# --- [3] 存储状态 ---
print_title "3. 存储与文件系统"
disk_count=$(lsblk -d -o TYPE | grep -w "disk" | wc -l)
disk_cap_total=$(lsblk -d -b -o TYPE,SIZE | awk '/disk/ {sum+=$2} END {
    if (sum >= 1099511627776) printf "%.2fT", sum/1099511627776;
    else printf "%.2fG", sum/1073741824;
}')
disk_usage_total=$(df -k | awk '!/tmpfs|devtmpfs|udev|loop|cdrom|efivarfs|fuse/ && NR>1 {total+=$2; used+=$3} END {if(total>0) printf "%.2f%%", used/total * 100; else print "0.00%"}')
root_usage=$(df -h / | awk 'NR==2 {print $5}')
root_inode_usage=$(df -i / | awk 'NR==2 {print $5}')

print_item "物理硬盘数量    " "${disk_count} 块"
print_item "物理硬盘总容量  " "${disk_cap_total}"
print_item "总体空间使用率  " "${disk_usage_total}"
print_item "根分区使用率    " "${root_usage}"
print_item "根分区 Inode    " "${root_inode_usage}"

# --- [4] 进程与网络连接 ---
print_title "4. 进程与连接状态"
total_procs=$(ps aux | wc -l)
zombie_procs=$(ps aux | awk '{print $8}' | grep -c "Z")
# TCP 只统计已建立的连接 (ESTABLISHED)
tcp_estab=$(ss -H -t state established | wc -l 2>/dev/null)
# UDP 统计所有活跃的 Socket 数量 (包含 UNCONN, ESTAB 等)
udp_active=$(ss -H -u -a | wc -l 2>/dev/null)

print_item "系统总进程数    " "${total_procs}"
print_item "僵尸进程数      " "${zombie_procs}"
print_item "TCP 连接数      " "${tcp_estab} (ESTABLISHED)"
print_item "UDP 活跃数      " "${udp_active} (ALL STATES)"

echo -e "\n${C_TITLE}==================================================${C_RESET}"
echo -e "${C_LABEL}巡检时间: $(date "+%Y-%m-%d %H:%M:%S")${C_RESET}"
echo -e "${C_TITLE}==================================================${C_RESET}\n"
