// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MemeFactory.sol";
import "../src/MemeToken.sol";

contract MemeFactoryTest is Test {
    MemeFactory public factory;
    address public platform;
    address public creator;
    address public user1;
    address public user2;
    
    receive() external payable {}
    
    function setUp() public {
        platform = address(this);
        creator = makeAddr("creator");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        factory = new MemeFactory();
    }
    
    /// 测试1: 费用分配正确性（1% vs 99%）
    function testFeeDistribution() public {
        // 创建者部署 Meme (price 是每次铸造的总费用)
        vm.prank(creator);
        address memeAddr = factory.deployMeme("PEPE", 1000e18, 100e18, 1 ether);
        
        // 记录初始余额
        uint256 platformBefore = platform.balance;
        uint256 creatorBefore = creator.balance;
        
        // user1 铸造（支付 1 ETH）
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        factory.mintMeme{value: 1 ether}(memeAddr);
        
        // 验证费用分配
        uint256 platformFee = platform.balance - platformBefore;
        uint256 creatorFee = creator.balance - creatorBefore;
        
        assertEq(platformFee, 0.01 ether, "Platform should receive 1%");
        assertEq(creatorFee, 0.99 ether, "Creator should receive 99%");
        assertEq(platformFee + creatorFee, 1 ether, "Total fees should be 1 ETH");
    }
    
    /// 测试2: 铸造数量正确，不超过 totalSupply
    function testMintAmountAndSupplyLimit() public {
        // 部署 Meme: 总量 200, 每次 100
        vm.prank(creator);
        address memeAddr = factory.deployMeme("DOGE", 200e18, 100e18, 0.01 ether);
        
        MemeToken token = MemeToken(memeAddr);
        
        // 第1次铸造：成功
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        factory.mintMeme{value: 1 ether}(memeAddr);
        assertEq(token.balanceOf(user1), 100e18, "User1 should have 100 tokens");
        assertEq(token.currentSupply(), 100e18, "Current supply should be 100");
        
        // 第2次铸造：成功（达到上限）
        vm.prank(user2);
        vm.deal(user2, 10 ether);
        factory.mintMeme{value: 1 ether}(memeAddr);
        assertEq(token.balanceOf(user2), 100e18, "User2 should have 100 tokens");
        assertEq(token.currentSupply(), 200e18, "Current supply should be 200");
        
        // 第3次铸造：失败（超过总量）
        vm.prank(user1);
        vm.expectRevert("Exceeds total supply");
        factory.mintMeme{value: 1 ether}(memeAddr);
    }
    
    /// 测试3: 每次铸造数量正确（perMint）
    function testPerMintCorrect() public {
        // 部署 Meme: 每次铸造 50
        vm.prank(creator);
        address memeAddr = factory.deployMeme("SHIB", 1000e18, 50e18, 0.001 ether);
        
        MemeToken token = MemeToken(memeAddr);
        
        // 铸造一次
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        factory.mintMeme{value: 0.05 ether}(memeAddr);
        
        // 验证余额和供应量
        assertEq(token.balanceOf(user1), 50e18, "Should mint exactly perMint amount");
        assertEq(token.currentSupply(), 50e18, "Current supply should increase by perMint");
        
        // 再次铸造
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        factory.mintMeme{value: 0.05 ether}(memeAddr);
        
        assertEq(token.balanceOf(user2), 50e18, "Should mint exactly perMint amount");
        assertEq(token.currentSupply(), 100e18, "Current supply should be 100");
    }
    
    /// 额外测试: 支付金额不足
    function testInsufficientPayment() public {
        vm.prank(creator);
        address memeAddr = factory.deployMeme("TEST", 1000e18, 100e18, 1 ether);
        
        // 应付 1 ETH，只付 0.5 ETH
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        vm.expectRevert("Insufficient payment");
        factory.mintMeme{value: 0.5 ether}(memeAddr);
    }
    
    /// 额外测试: 多余支付应退还
    function testRefundExcessPayment() public {
        vm.prank(creator);
        address memeAddr = factory.deployMeme("REFUND", 1000e18, 100e18, 1 ether);
        
        vm.deal(user1, 10 ether);
        uint256 balanceBefore = user1.balance;
        
        // 应付 1 ETH，付 2 ETH
        vm.prank(user1);
        factory.mintMeme{value: 2 ether}(memeAddr);
        
        // 应退还 1 ETH
        assertEq(user1.balance, balanceBefore - 1 ether, "Should refund excess payment");
    }
    
    /// 额外测试: 使用 Clones（Gas 优化验证）
    function testUsesClones() public {
        vm.prank(creator);
        address meme1 = factory.deployMeme("MEME1", 1000e18, 100e18, 0.01 ether);
        
        vm.prank(creator);
        address meme2 = factory.deployMeme("MEME2", 2000e18, 200e18, 0.02 ether);
        
        // 验证是不同地址
        assertTrue(meme1 != meme2, "Should create different addresses");
        
        // 验证参数独立
        MemeToken token1 = MemeToken(meme1);
        MemeToken token2 = MemeToken(meme2);
        
        assertEq(token1.symbol(), "MEME1");
        assertEq(token2.symbol(), "MEME2");
        assertEq(token1.totalSupply(), 1000e18);
        assertEq(token2.totalSupply(), 2000e18);
    }
}

