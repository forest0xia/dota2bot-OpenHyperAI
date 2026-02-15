#!/bin/bash

set -euo pipefail

function error_exit {
    echo "============"
    echo "$1"
    echo "常见故障排除："
    echo "1. 请确保在此文件夹中执行此脚本：'SteamLibrary/steamapps/workshop/content/570/3246316298/Install-to-vscript'（或您 Steam 库中的等效路径）。"
    echo "2. 如果您不知道 Steam 库文件夹的位置，请在 Steam 库中右键点击 Dota 2，选择属性 > 已安装文件 > 浏览。它将打开文件夹：'steamapps/common/dota 2 beta'。从那里，向后导航到 'steamapps'，然后到 'workshop/content/570/3246316298/Install-to-vscript'。"
    echo "3. 如果遇到权限问题，请确保 Steam 库文件夹由您的用户拥有（例如，如果需要，运行 'chown -R $USER:$USER /path/to/SteamLibrary'，替换 /path/to/SteamLibrary 为您的实际路径）。chown 命令递归地将文件和目录的所有权更改为指定的用户和组（这里是您的当前用户和组）。"
    echo "============"
    echo "安装失败!!!"
    echo "============"
    exit 1
}

# 获取当前时间戳（格式: YYYYMMDD_HHMMSS）
TIMESTAMP=$(date +%Y%m%d_%H%M%S) || error_exit "无法生成时间戳。"

# 获取脚本目录
SCRIPT_DIR=$(pwd) || error_exit "无法确定当前目录。"

# 工坊项目目录（此脚本目录的父目录）
WORKSHOP_ITEM_DIR="$SCRIPT_DIR/.."
if [ ! -d "$WORKSHOP_ITEM_DIR" ]; then
    error_exit "未找到工坊项目目录：$WORKSHOP_ITEM_DIR。请确保从正确位置运行脚本。"
fi

# 检查源 Customize 文件夹
if [ ! -d "$WORKSHOP_ITEM_DIR/Customize" ]; then
    error_exit "在 $WORKSHOP_ITEM_DIR 中未找到源 Customize 文件夹。"
fi

# Dota 2 目录（假设标准 Steam 库结构）
DOTA_DIR="$SCRIPT_DIR/../../../../../common/dota 2 beta"
if [ ! -d "$DOTA_DIR" ]; then
    error_exit "未找到 Dota 2 安装目录：$DOTA_DIR。请验证您的 Steam 库路径和脚本位置。"
fi

# vscripts 目录
VSCRIPTS_DIR="$DOTA_DIR/game/dota/scripts/vscripts"
if [ ! -d "$VSCRIPTS_DIR" ]; then
    error_exit "未找到 Dota 2 vscripts 目录：$VSCRIPTS_DIR。请确保 Dota 2 已正确安装。"
fi

# 目标目录
BOTS_DIR="$VSCRIPTS_DIR/bots"
CUSTOMIZE_TARGET="$VSCRIPTS_DIR/game/Customize"
CUSTOMIZE_PARENT="$VSCRIPTS_DIR/game"
if [ ! -d "$CUSTOMIZE_PARENT" ]; then
    mkdir -p "$CUSTOMIZE_PARENT" || error_exit "无法为 Customize 创建父目录：$CUSTOMIZE_PARENT。"
fi

# 检查 bots 文件夹是否已存在
if [ -d "$BOTS_DIR" ] || [ -L "$BOTS_DIR" ]; then
    echo "bots 文件夹或符号链接已存在，正在重命名为 bots_old_$TIMESTAMP..."
    mv "$BOTS_DIR" "$VSCRIPTS_DIR/bots_old_$TIMESTAMP" || error_exit "无法重命名现有的 bots 目录。"
fi

echo "正在创建机器人脚本链接..."
ln -s "$WORKSHOP_ITEM_DIR" "$BOTS_DIR" || error_exit "无法为 bots 创建符号链接。"

# 检查 Customize 文件夹是否已存在
if [ -d "$CUSTOMIZE_TARGET" ] || [ -L "$CUSTOMIZE_TARGET" ]; then
    echo "Customize 文件夹已存在，正在重命名为 Customize_old_$TIMESTAMP..."
    mv "$CUSTOMIZE_TARGET" "$VSCRIPTS_DIR/game/Customize_old_$TIMESTAMP" || error_exit "无法重命名现有的 Customize 目录。"
fi

echo "正在创建自定义脚本..."
cp -r "$WORKSHOP_ITEM_DIR/Customize/" "$CUSTOMIZE_TARGET" || error_exit "无法复制 Customize 文件夹。"

echo "============"
echo "安装成功!!!"
echo "============"
