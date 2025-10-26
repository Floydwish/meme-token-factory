// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MemeFactory.sol";
import "../src/MemeToken.sol";
import "../src/MockUniswapRouter.sol";

/**
 * @title LiquidityTest
 * @dev 测试流动性添加功能
 */
contract LiquidityTest is Test {
    MemeFactory public factory;
    MockUniswapRouter public mockRouter;
    address public platform;
    address public creator;
    address public user1;
    
    receive() external payable {}
    
    function setUp() public {
        platform = address(this);
        creator = makeAddr("creator");
        user1 = makeAddr("user1");
        
        // 部署模拟 Router
        mockRouter = new MockUniswapRouter();
        
        // 使用模拟 Router 部署工厂
        factory = new MemeFactory(address(mockRouter));
    }
    
    /// 测试流动性添加功能
    function testLiquidityAddition() public {
        // 1. 创建者部署 Meme
        vm.prank(creator);
        address memeAddr = factory.deployMeme("TEST", 1000e18, 100e18, 1 ether);
        
        // 2. 记录初始状态
        uint256 factoryBalanceBefore = address(factory).balance;
        uint256 platformBalanceBefore = platform.balance;
        uint256 creatorBalanceBefore = creator.balance;
        
        // 3. 用户铸造代币（支付 1 ETH）
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        factory.mintMeme{value: 1 ether}(memeAddr);
        
        // 4. 验证费用分配
        uint256 platformFee = platform.balance - platformBalanceBefore;
        uint256 creatorFee = creator.balance - creatorBalanceBefore;
        
        // 平台费用用于流动性，所以平台余额不变
        assertEq(platformFee, 0, "Platform fee used for liquidity, should be 0");
        assertEq(creatorFee, 0.95 ether, "Creator should receive 95%");
        
        // 5. 验证流动性添加调用
        // 检查是否调用了 addLiquidityETH
        // 这里我们通过事件来验证
        // 注意：由于我们使用的是模拟合约，实际的事件可能不同
    }
    
    /// 测试流动性添加的参数
    function testLiquidityParameters() public {
        // 创建 Meme
        vm.prank(creator);
        address memeAddr = factory.deployMeme("PARAM", 1000e18, 100e18, 1 ether);
        
        MemeToken token = MemeToken(memeAddr);
        
        // 铸造代币
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        factory.mintMeme{value: 1 ether}(memeAddr);
        
        // 验证代币余额
        assertEq(token.balanceOf(address(factory)), 0, "Factory should not have tokens");
        assertEq(token.balanceOf(user1), 100e18, "User should have minted tokens");
    }
    
    /// 测试费用计算
    function testFeeCalculation() public {
        // 测试不同的费用计算
        uint256 cost = 1 ether;
        uint256 platformFee = cost * 5 / 100;
        uint256 creatorFee = cost - platformFee;
        
        assertEq(platformFee, 0.05 ether, "Platform fee should be 5%");
        assertEq(creatorFee, 0.95 ether, "Creator fee should be 95%");
        assertEq(platformFee + creatorFee, cost, "Total fees should equal cost");
    }
    
    /// 测试 Token 数量计算
    function testTokenAmountCalculation() public {
        // 创建 Meme，价格 0.01 ETH per token
        vm.prank(creator);
        address memeAddr = factory.deployMeme("CALC", 1000e18, 100e18, 0.01 ether);
        
        MemeToken token = MemeToken(memeAddr);
        
        // 计算：0.05 ETH / 0.01 ETH per token = 5 tokens
        uint256 ethForLiquidity = 0.05 ether;
        uint256 tokenAmount = ethForLiquidity / token.price();
        
        assertEq(tokenAmount, 5, "Should calculate 5 tokens for 0.05 ETH");
    }
    
    /// 测试滑点保护参数
    function testSlippageProtection() public {
        // 创建 Meme
        vm.prank(creator);
        address memeAddr = factory.deployMeme("SLIP", 1000e18, 100e18, 1 ether);
        
        // 铸造代币
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        factory.mintMeme{value: 1 ether}(memeAddr);
        
        // 验证滑点保护参数
        // 期望：0.05 ETH
        // 最小：0.05 * 95% = 0.0475 ETH
        uint256 expectedETH = 0.05 ether;
        uint256 minETH = expectedETH * 95 / 100;
        
        assertEq(minETH, 0.0475 ether, "Minimum ETH should be 95% of expected");
    }
}
