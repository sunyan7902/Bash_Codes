#!/bin/bash
# ==============================================================================
# Author: sunyan
# Email: sunyan2002@foxmail.com
# LastUpdate: 2026-06-16
# Description: 批量备份本地 Docker 镜像到指定目录，并将镜像打包为 .tar 文件
# ==============================================================================

# 定义备份目录，格式为 /opt/docker_images_backup_年月日_时分秒
BACKUP_DIR="/opt/docker_images_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR" || exit 1

echo "开始备份Docker镜像到目录: $BACKUP_DIR"

# 获取所有非空的本地 Docker 镜像，并过滤掉 <none> 镜像
docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | while read -r image; do
    if [[ -n "$image" ]]; then
        # 将镜像名称中的 / 和 : 转换为下划线，作为备份文件名
        filename=$(echo "$image" | tr '/:' '_').tar
        echo "备份: $image -> $filename"
        docker save "$image" -o "$filename"
    fi
done

echo "备份完成！共备份 $(ls -1 *.tar 2>/dev/null | wc -l) 个镜像"