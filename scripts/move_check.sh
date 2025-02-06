#!/bin/bash

echo "运行 Move 代码检查..."

# 进入合约目录
cd "$(git rev-parse --show-toplevel)/contracts" || exit 1

# 运行 sui move build
if ! sui move build; then
    echo "Move 构建失败"
    exit 1
fi

# 运行 sui move test
if ! sui move test; then
    echo "Move 测试失败"
    exit 1
fi

echo "Move 代码检查完成"
exit 0
