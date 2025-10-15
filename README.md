# Meme Token Factory

基于 ERC1167 最小代理的 Meme 代币发射平台。

## 核心功能

- **deployMeme()**: 创建新的 Meme 代币（使用最小代理）
- **mintMeme()**: 铸造 Meme 代币（费用分配：1% 平台，99% 创建者）

## 核心技术点

### 1️⃣ 最小代理模式（ERC1167）
```
样板房 (MemeToken 实现)  ← 部署1次
    ↓ Clones.clone()
代理1, 代理2, 代理3...    ← 每个只需 45 字节
```
**类比**：建一个样板房，后续只需"复印"，每个新房只需 ~50k gas（vs 常规 ~2M gas）

### 2️⃣ delegatecall 机制
```
代理合约: 借用样板房的代码
         在自己的存储空间执行
```
**类比**：租用公共图书馆的书（代码），记笔记在自己的本子上（数据）

### 3️⃣ 工厂模式
```
平台方: 提供样板房（MemeToken）
发行方: 调用 deployMeme() → 获得自己的 Meme
用户:   调用 mintMeme() → 支付费用获得代币
```

### 4️⃣ initialize 替代 constructor
**原因**：代理合约不能用 constructor  
**方案**：部署后调用 `initialize()` 填入参数（symbol、totalSupply等）

### 5️⃣ Gas 优化对比

| 操作 | 常规部署 | 最小代理 | 节省 |
|------|----------|----------|------|
| 首个 Meme | ~2M gas | ~2M + 50k | - |
| 第2个 Meme | ~2M gas | ~50k | **97%** |
| 100个 Meme | 200M | ~7M | **96%** |

### 6️⃣ 自动费用分配
```solidity
用户支付 1 ETH
├─ 0.01 ETH (1%)  → Platform (自动)
└─ 0.99 ETH (99%) → Meme 创作者 (自动)
```
无需手动转账，合约自动分配

## 测试

```bash
forge test -vv
```

## 部署到 Sepolia

```bash
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```

## 合约结构

- `MemeToken.sol`: ERC20 模板合约（被克隆）
- `MemeFactory.sol`: 工厂合约（创建代理）
