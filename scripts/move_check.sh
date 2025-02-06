#!/bin/bash

# 检查sui命令是否存在
if ! command -v sui &> /dev/null; then
    echo "错误: sui命令未找到，请先安装Sui CLI"
    exit 1
fi

# 进入合约目录
cd "$(dirname "$0")/../contracts" || exit 1

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 运行Move检查
echo "正在检查Move代码..."
if sui move check; then
    echo -e "${GREEN}✓ Move代码检查通过${NC}"
else
    echo -e "${RED}✗ Move代码检查失败${NC}"
    exit 1
fi

# 运行Move测试
echo -e "\n运行Move测试..."
if sui move test; then
    echo -e "${GREEN}✓ 所有测试通过${NC}"
else
    echo -e "${RED}✗ 测试失败${NC}"
    exit 1
fi

# 构建项目
echo -e "\n构建项目..."
if sui move build; then
    echo -e "${GREEN}✓ 构建成功${NC}"
else
    echo -e "${RED}✗ 构建失败${NC}"
    exit 1
fi
