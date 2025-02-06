#!/bin/bash

# 检查sui命令是否存在
if ! command -v sui &> /dev/null; then
    echo "错误: sui命令未找到，请先安装Sui CLI"
    echo "安装命令: cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui"
    exit 1
fi

# 创建测试账号
echo "正在创建测试账号..."
for i in {1..3}; do
    echo "创建测试账号 $i"
    sui client new-address ed25519
done

# 显示所有账号
echo -e "\n当前所有账号:"
sui client addresses

# 为测试账号请求测试代币
echo -e "\n正在为账号请求测试代币..."
addresses=$(sui client addresses | grep -v 'alias' | grep -v '─' | awk '{print $2,$4}' | grep -v '^$')
for addr in $addresses; do
    alias=$(echo $addr | awk '{print $1}')
    address=$(echo $addr | awk '{print $2}')
    echo "为账号 $alias ($address) 请求测试代币"
    curl --location --request POST 'https://faucet.devnet.sui.io/gas' \
         --header 'Content-Type: application/json' \
         --data "{\"FixedAmountRequest\":{\"recipient\":\"$address\"}}"
    sleep 2  # 添加延迟避免请求过快
    echo -e "\n"
done
