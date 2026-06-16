#!/bin/bash

BACKUP_DIR="/tmp/docker_images_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"

echo "开始备份Docker镜像到目录: $BACKUP_DIR"

docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | while read image; do
    if [ -n "$image" ]; then
        filename=$(echo "$image" | tr '/:' '_').tar
        echo "备份: $image -> $filename"
        docker save "$image" -o "$filename"
    fi
done

echo "备份完成！共备份 $(ls -1 *.tar 2>/dev/null | wc -l) 个镜像"