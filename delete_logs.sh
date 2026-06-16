#!/bin/bash
# ==============================================================================
# Author: sunyan
# Email: sunyan2002@foxmail.com
# LastUpdate: 2026-06-16
# Description: 定期删除指定目录中 N 天前的日志文件（.log, .log.*, .out, *out* 等文件）
# ==============================================================================

# 显示脚本使用方法
echo "=================================================="
echo "日志文件删除工具"
echo "用法：$0 <绝对目录路径> <天数>"
echo "功能：删除指定目录中 <天数> 天前的日志文件"
echo "=================================================="

# 检查参数数量是否正确
if [[ $# -ne 2 ]]; then
    echo "错误：参数数量不正确"
    echo "用法：$0 <绝对目录路径> <天数>"
    exit 1
fi

# 获取参数
DIR_PATH="$1"
DAYS="$2"

# 检查目录是否存在
if [[ ! -d $DIR_PATH ]]; then
    echo "错误：目录 '$DIR_PATH' 不存在"
    exit 1
fi

# 检查天数是否为正整数
if ! [[ $DAYS =~ ^[0-9]+$ ]]; then
    echo "错误：天数必须是正整数"
    exit 1
fi

# 删除指定天数前的文件
echo "开始删除 '$DIR_PATH' 中 $DAYS 天前的日志文件..."

# 使用 find 匹配指定后缀的日志文件（.log, .log.*, .out, *out* 等）并删除
find "$DIR_PATH" -type f \( -name "*.log" -o -name "*.log.*" -o -name "*.out" -o -name "*out*" \) -mtime +"$DAYS" -delete
echo "删除操作完成"

exit 0
