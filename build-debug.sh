#!/bin/bash

# 玲珑容器构建脚本
# 使用方法: ./build-debug.sh [package]

set -e

echo "=== 玲珑容器构建脚本 ==="

# 检查参数
if [ "$1" = "linyaps-box" ]; then
    echo "构建 linyaps-box（默认 Release 模式）..."
    nix build .#linyaps-box
    echo "✅ linyaps-box 构建完成"
elif [ "$1" = "linyaps" ]; then
    echo "构建 linyaps（默认 Release 模式）..."
    nix build .#linyaps
    echo "✅ linyaps 构建完成"
elif [ "$1" = "all" ] || [ -z "$1" ]; then
    echo "构建所有包（默认 Release 模式）..."
    echo "构建 linyaps-box..."
    nix build .#linyaps-box
    echo "构建 linyaps..."
    nix build .#linyaps
    echo "✅ 所有包构建完成"
else
    echo "用法: $0 [package]"
    echo "可用的包:"
    echo "  linyaps-box  - 构建 linyaps-box（默认 Release 模式）"
    echo "  linyaps      - 构建 linyaps（默认 Release 模式）"
    echo "  all          - 构建所有包（默认）"
    exit 1
fi

echo ""
echo "构建结果:"
ls -la result* 