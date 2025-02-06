#!/bin/bash

echo "检查所有账号余额..."
echo "----------------------------------------"

addresses=$(sui client addresses | grep -v 'alias' | grep -v '─' | awk '{print $2,$4}' | grep -v '^$')
for addr in $addresses; do
    alias=$(echo $addr | awk '{print $1}')
    address=$(echo $addr | awk '{print $2}')
    echo "账号 $alias ($address) 的余额:"
    sui client gas $address
    echo "----------------------------------------"
done
