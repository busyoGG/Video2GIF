#!/bin/bash

# 默认参数
HEIGHT=600
FPS=30
COLOR=""

# 用于记录位置参数
POSITIONAL=()

# 定义显示帮助信息的函数
function show_help {
  echo "用法: $0 [选项] 输入文件 [输出文件](不填则使用输入文件同名)"
  echo "选项:"
  echo "  -f 帧率（默认：30）"
  echo "  -H 高度（默认：600，宽度自动等比例缩放）"
  echo "  -c 颜色数（默认：256）"
  echo "  -h 显示此帮助信息"
}

# 参数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f) FPS="$2"; shift 2 ;;
    -H) HEIGHT="$2"; shift 2 ;;
    -c) COLOR="$2"; shift 2 ;;
    -h) show_help ; exit 1 ;;
    -*) echo "未知参数: $1"; exit 1 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

# 检查输入输出数量
if [[ ${#POSITIONAL[@]} -lt 1 ]]; then
  echo "用法: $0 [选项] 输入文件 [输出文件](不填则使用输入文件同名)"
  echo "  -h 查看使用说明"
  exit 1
fi

INPUT="${POSITIONAL[0]}"
# 如果 POSITIONAL 数组只有一个元素，则将 OUTPUT 设置为 INPUT 改后缀为 gif
if [ ${#POSITIONAL[@]} -eq 1 ]; then
  OUTPUT="${INPUT%.*}.gif"
else
  OUTPUT="${POSITIONAL[1]}"
fi

# 获取原始分辨率
read ORIGINAL_WIDTH ORIGINAL_HEIGHT < <(ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height -of csv=p=0:s=x "$INPUT" | awk -Fx '{print $1, $2}')

WIDTH=$((ORIGINAL_WIDTH * HEIGHT / ORIGINAL_HEIGHT))

# 生成 GIF
PALETTE="/tmp/palette.png"

echo "🎨 提取调色板..."

ffmpeg -loglevel error -y -i "$INPUT" -vf "fps=$FPS,scale=$WIDTH:$HEIGHT:flags=lanczos,palettegen=max_colors=$COLOR" "$PALETTE"

echo "🛠️ 调色板生成完毕，正在转换 GIF..."

ffmpeg -loglevel error -stats -y -i "$INPUT" -i "$PALETTE" -filter_complex "fps=$FPS,scale=$WIDTH:$HEIGHT:flags=lanczos[x];[x][1:v]paletteuse" "$OUTPUT"

# 清理调色板文件
rm -f "$PALETTE"

BIT_DEPTH=$(echo "l($COLOR)/l(2)" | bc -l | awk '{printf "%.0f", $1}')

echo
echo "🎉 完成 ✅"
echo "📥 输入: $INPUT"
echo "📤 输出: $OUTPUT"
echo "📐 分辨率: ${WIDTH}x${HEIGHT} @$FPS | 🌈$COLOR(${BIT_DEPTH}-bit)"
