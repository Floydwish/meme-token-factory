# Meme LaunchPad Platform

基于 ERC1167 最小代理的去中心化 LaunchPad 平台，支持一键发射 Meme 代币并自动添加流动性。

## 🚀 核心功能

### LaunchPad 平台功能
- **deployMeme()**: 一键创建新的 Meme 代币（使用最小代理）
- **mintMeme()**: 按固定价格铸造代币
- **buyMeme()**: 当 Uniswap 价格更好时购买代币
- **自动流动性**: 5% 平台费用自动添加 Uniswap V2 流动性

### 费用分配机制
```solidity
用户支付 1 ETH
├─ 0.05 ETH (5%)  → 自动添加流动性
└─ 0.95 ETH (95%) → Meme 创作者
```

## ⚡ 技术优势

### 1️⃣ 最小代理模式（ERC1167）
```
样板房 (MemeToken 实现)  ← 部署1次
    ↓ Clones.clone()
代理1, 代理2, 代理3...    ← 每个只需 45 字节
```
**Gas 优化**: 首个代币 ~2M gas，后续每个仅需 ~50k gas（节省 97%）

### 2️⃣ 自动化流动性管理
- 5% 平台费用自动用于添加 Uniswap V2 流动性
- 按 mint 价格设置初始流动性价格
- 内置 5% 滑点保护机制

### 3️⃣ 双重购买机制
- **固定价格**: `mintMeme()` - 按设定价格铸造
- **市场价格**: `buyMeme()` - 当 Uniswap 价格更好时购买

### 4️⃣ Gas 优化对比

| 操作 | 常规部署 | 最小代理 | 节省 |
|------|----------|----------|------|
| 首个 Meme | ~2M gas | ~2M + 50k | - |
| 第2个 Meme | ~2M gas | ~50k | **97%** |
| 100个 Meme | 200M | ~7M | **96%** |

## 🧪 测试

```bash
# 运行所有测试
forge test -vv

# 查看测试报告
cat result.txt
```

**测试覆盖**:
- ✅ 14 个测试用例全部通过
- ✅ 费用分配验证
- ✅ 流动性添加功能
- ✅ 滑点保护机制
- ✅ ERC20 标准功能

## 🚀 部署

```bash
# 设置环境变量
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY
export RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY

# 部署到主网
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

## 📁 项目结构

```
src/
├── MemeFactory.sol          # LaunchPad 核心合约
├── MemeToken.sol            # ERC20 模板合约
├── UniswapInterfaces.sol    # Uniswap V2 接口
└── MockUniswapRouter.sol    # 测试用模拟 Router

test/
├── MemeFactory.t.sol        # 基础功能测试
└── LiquidityTest.t.sol      # 流动性功能测试

script/
└── Deploy.s.sol            # 部署脚本
```

## 🎯 LaunchPad 平台特色

### 降低门槛
- 无需审核，任何人都可以发射代币
- 极低的 Gas 成本
- 一键部署，自动配置

### 自动化管理
- 自动添加流动性
- 自动费用分配
- 智能价格发现

### 市场驱动
- 支持市场定价
- 流动性自动管理
- 去中心化交易

## 📊 测试报告

```
=== 测试总结 ===
✅ 总测试用例: 14 个
✅ 通过测试: 14 个
✅ 失败测试: 0 个

=== 功能验证 ===
✅ 费用分配: 5% 平台费用用于流动性
✅ 流动性添加: 使用模拟 Uniswap Router 验证
✅ 滑点保护: 5% 滑点容忍度
✅ 最小代理: Gas 优化验证
✅ ERC20 标准: 完整代币功能
```

---
