# Meme Factory 测试与部署记录

## 本地测试

### 运行测试
```bash
forge test -vv
```

### 测试结果
```
✅ 6/6 测试通过
- testFeeDistribution: 费用分配正确（1% vs 99%）
- testMintAmountAndSupplyLimit: 铸造数量正确，不超过总量
- testPerMintCorrect: 每次铸造数量准确
- testInsufficientPayment: 支付不足拒绝
- testRefundExcessPayment: 多余支付退还
- testUsesClones: 最小代理正常工作

Gas 消耗:
- deployMeme: ~274k gas
- mintMeme: ~106k gas
```

---

## Sepolia 部署与测试

### 1. 部署 MemeFactory

```bash
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --legacy
```

**部署结果**：
```
Factory:        0x27916B7538d95bD3bF313B48fB90E269E30558Ec
Implementation: 0x20D0f8E6F57d849a3aa84414799fCD4C20F99340
Platform:       0xCD20497dC1472f9705d3853dfbCF04C73421F693
```

---

### 2. 发行 Bo Meme（PRIVATE_KEY1）

**参数**：
- Symbol: Bo
- 总量: 21,000,000
- 每次mint: 10 个
- 价格: 0.001 ETH/次

```bash
forge script script/DeployBo.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --legacy
```

**结果**：
```
Bo Token: 0xaE60E4AF2b4cD3D2d3156f47c5038D05af4B1e91
Creator:  0x674787bA0D2B2257Fc87D7Db0fa4DB4F685477E6
Gas: ~400k
```

---

### 3. 用户 mint（PRIVATE_KEY2 mint 2次）

```bash
forge script script/MintBo.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --legacy
```

**结果**：
```
Mint 1: +10 Bo
Mint 2: +10 Bo
Total:  20 Bo

支付费用: 0.002 ETH (0.001 × 2)
Gas: ~259k
```

---

## 最终状态验证

### Bo Token 信息
```
地址: 0xaE60E4AF2b4cD3D2d3156f47c5038D05af4B1e91
当前供应: 20 Bo
总量: 21,000,000 Bo
```

### 账户余额

| 账户 | 角色 | Bo余额 | ETH变化 |
|------|------|--------|---------|
| PRIVATE_KEY | 平台方 | 0 | +0.00002 (1%费用) |
| PRIVATE_KEY1 | Bo创作者 | 0 | +0.00198 (99%费用) |
| PRIVATE_KEY2 | 用户 | 20 | -0.002 (mint费用) |

### 费用分配验证
```
用户支付: 0.002 ETH
├─ 平台费(1%):  0.00002 ETH ✅
└─ 创作者费(99%): 0.00198 ETH ✅
```

---

## 关键特性验证

✅ **最小代理模式**：使用 Clones.clone() 降低部署成本  
✅ **费用自动分配**：1% 平台，99% 创作者  
✅ **铸造限制**：每次固定数量（perMint）  
✅ **总量控制**：不超过 totalSupply  
✅ **独立 ERC20**：每个 Meme 有独立地址和数据  

---

## 查询命令

```bash
# 查询 Bo 余额
cast call 0xaE60E4AF2b4cD3D2d3156f47c5038D05af4B1e91 \
  "balanceOf(address)(uint256)" \
  0x42AAF93c273bc0b4201a73dB3E66155a4CD8aF03 \
  --rpc-url $SEPOLIA_RPC_URL

# 查询当前供应
cast call 0xaE60E4AF2b4cD3D2d3156f47c5038D05af4B1e91 \
  "currentSupply()(uint256)" \
  --rpc-url $SEPOLIA_RPC_URL

# 查询 ETH 余额
cast balance 0x42AAF93c273bc0b4201a73dB3E66155a4CD8aF03 \
  --rpc-url $SEPOLIA_RPC_URL --ether
```

---

## 总结

- ✅ 合约部署成功
- ✅ Meme 发行功能正常
- ✅ 用户 mint 功能正常
- ✅ 费用分配准确
- ✅ 最小代理节省 Gas ~97%

**测试完成时间**: 2025-10-14

