// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MockUniswapRouter
 * @dev 模拟 Uniswap Router 用于测试流动性添加功能
 */
contract MockUniswapRouter {
    // 记录添加流动性的调用
    event LiquidityAdded(
        address indexed token,
        uint256 amountToken,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    );
    
    // 模拟 addLiquidityETH 函数
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        // 记录调用参数
        emit LiquidityAdded(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);
        
        // 模拟返回值
        return (amountTokenDesired, msg.value, 1000); // 返回模拟的流动性数量
    }
    
    // 模拟 swapExactETHForTokens 函数
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts) {
        // 模拟返回交换数量
        uint256[] memory result = new uint256[](2);
        result[0] = msg.value; // ETH 数量
        result[1] = msg.value * 100; // 模拟的 Token 数量
        return result;
    }
}
