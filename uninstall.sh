#!/bin/bash

# 删除脚本文件
sudo rm -f /usr/local/bin/video2gif
echo "🗑️ 已删除 /usr/local/bin/video2gif"

# 提示用户是否卸载依赖
read -p "是否要卸载依赖 (ffmpeg)? [y/N]: " UNINSTALL_DEPS

# 如果用户选择卸载
if [[ "$UNINSTALL_DEPS" =~ ^[Yy]$ ]]; then
    if command -v pacman &>/dev/null; then
        sudo pacman -Rns --noconfirm ffmpeg
    elif command -v apt &>/dev/null; then
        sudo apt remove --purge -y ffmpeg
    elif command -v dnf &>/dev/null; then
        sudo dnf remove -y ffmpeg
    elif command -v zypper &>/dev/null; then
        sudo zypper remove -y ffmpeg
    else
        echo "❌ 未识别的包管理器，无法卸载 ffmpeg"
    fi
else
    echo "✅ 已保留依赖。"
fi

echo "✅ 卸载完成！"
