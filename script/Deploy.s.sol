// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MemeFactory.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 使用主网 Uniswap V2 Router 地址
        address uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        MemeFactory factory = new MemeFactory(uniswapRouter);
        
        console.log("MemeFactory deployed at:", address(factory));
        console.log("Implementation (MemeToken):", factory.implementation());
        console.log("Platform address:", factory.platform());
        
        vm.stopBroadcast();
    }
}

