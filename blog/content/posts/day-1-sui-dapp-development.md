---
title: "Day 1: 构建你的第一个 Sui DApp"
date: 2025-02-07T00:56:14+08:00
draft: false
tags: ["blockchain", "sui", "move", "web3"]
categories: ["区块链开发"]
author: "stong"
---

## 引言

在这篇文章中，我将分享如何使用 Move 语言和 Sui 区块链构建一个简单但功能完整的 DApp。我们将从零开始，一步步构建一个可以创建和更新链上对象的应用程序。

## 技术栈

- 后端：Move 语言（Sui 版本）
- 前端：原生 HTML/JavaScript
- SDK：@mysten/sui v1.21.1
- 开发工具：Sui CLI, Python HTTP Server

## 项目结构

```
sui_dapp_tutorial/
├── contracts/           # Move 智能合约
│   └── my_object/      # 对象管理合约
├── frontend/           # 前端应用
│   └── index.html      # 单页面应用
└── README.md
```

## 智能合约开发

### 1. 对象模型设计

我们设计了一个简单的对象模型来演示 Sui 的核心特性：

```move
struct MyObject has key, store {
    id: UID,
    value: u64,
    owner: address
}
```

这个对象包含：
- `id`: Sui 对象唯一标识符
- `value`: 可修改的数值
- `owner`: 对象所有者地址

### 2. 核心功能实现

主要实现了两个核心功能：

```move
// 创建新对象
public entry fun create_object(value: u64, ctx: &mut TxContext)

// 更新对象值
public entry fun update_value(object: &mut MyObject, new_value: u64, ctx: &TxContext)
```

### 3. 权限控制

通过所有权检查实现权限控制：

```move
assert!(tx_context::sender(ctx) == object.owner, ERROR_NOT_OWNER);
```

## 前端开发

### 1. Sui SDK 集成

使用 CDN 方式集成 Sui SDK：

```html
<script src="https://unpkg.com/@mysten/sui@1.21.1/dist/index.min.js"></script>
```

### 2. 钱包连接

实现了钱包连接和状态管理：

```javascript
async function connectWallet() {
    if (!window.suiWallet) {
        showStatus('请安装 Sui 钱包!', true);
        return;
    }
    await window.suiWallet.requestPermissions();
    const accounts = await window.suiWallet.getAccounts();
    // ... 处理连接逻辑
}
```

### 3. 交易处理

实现了对象创建和更新的交易处理：

```javascript
async function createObject(signer, value) {
    const tx = new window.sui.TransactionBlock();
    tx.moveCall({
        target: `${CONFIG.PACKAGE_ID}::${CONFIG.MODULE_NAME}::create_object`,
        arguments: [tx.pure(value)],
    });
    return await signer.signAndExecuteTransactionBlock({
        transactionBlock: tx,
    });
}
```

## 开发工具配置

### 1. Git Hooks

配置了 pre-commit hook 进行自动代码检查：

```bash
#!/bin/bash
echo "运行 Move 代码检查..."
if ! "$ROOT_DIR/scripts/move_check.sh"; then
    echo "Move 代码检查失败"
    exit 1
fi
```

### 2. Move 检查脚本

创建了完整的 Move 代码检查脚本：

```bash
#!/bin/bash
# 运行 Move 构建
sui move build || exit 1
# 运行 Move 测试
sui move test || exit 1
```

## 测试

实现了两个主要测试场景：

1. 对象创建测试
2. 未授权更新测试

```move
#[test]
fun test_create_object() {
    // ... 测试对象创建
}

#[test]
#[expected_failure(abort_code = sui_dapp_tutorial::my_object::ERROR_NOT_OWNER)]
fun test_unauthorized_update() {
    // ... 测试未授权更新
}
```

## 遇到的问题和解决方案

1. **Sui SDK 导入问题**
   - 问题：ESM 模块导入失败
   - 解决：使用 CDN 方式加载 SDK

2. **所有权检查逻辑**
   - 问题：初始使用了错误的所有权检查方式
   - 解决：实现了显式的所有权字段和检查

3. **测试地址常量**
   - 问题：测试中的地址常量未指定具体值
   - 解决：使用了具体的地址值（0xAAAA 和 0xBBBB）

## 项目当前状态

> ⚠️ **重要提示**：目前项目处于开发阶段，由于 Sui SDK 的集成问题，前端部分还不能完全正常运行。这个问题将在后续更新中解决。

### 已知问题

1. **Sui SDK 集成问题**
   - 当前使用 CDN 方式引入 SDK 导致部分功能不可用
   - `window.sui` 对象可能未正确初始化
   - 模块导入方式需要重构

2. **临时解决方案**
   - 确保使用最新版本的浏览器
   - 多次刷新页面可能会解决部分问题
   - 使用浏览器控制台检查具体错误信息

### 开发工具体验

这是我第一次使用 Windsurf 进行开发，有一些重要的心得分享：

1. **优点**
   - 提供了完整的项目脚手架
   - Git hooks 和自动化测试集成非常方便
   - 智能合约的开发体验流畅

2. **遇到的挑战**
   - 前端框架集成还需要优化
   - 对于 Web3 项目的特殊需求（如 SDK 集成）需要更好的支持
   - 一些现代前端开发工具（如 Vite）的集成还不够完善

3. **改进建议**
   - 添加专门的 Web3 项目模板
   - 提供更多 SDK 集成的最佳实践
   - 增加对现代前端工具链的支持

## 下一步计划

1. **前端重构**
   - 迁移到 npm 包管理
   - 引入 Vite 构建工具
   - 重新设计 SDK 集成方式

2. **开发流程优化**
   - 完善错误处理机制
   - 添加更多单元测试
   - 改进用户体验

## 结论

通过这个项目，我们学习了：
- Move 智能合约的基本开发流程
- Sui 对象模型的使用
- 前端与区块链的交互方式
- 区块链应用的测试方法

完整代码可以在 [GitHub](https://github.com/yourusername/sui_dapp_tutorial) 找到。

## 参考资料

1. [Sui 开发者文档](https://docs.sui.io/)
2. [Move 语言文档](https://move-language.github.io/move/)
3. [Sui SDK 文档](https://sdk.mystenlabs.com/)
