// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MemeFactory.sol";
import "../src/MemeToken.sol";

contract MintBoScript is Script {
    function run() external {
        address factoryAddress = 0x27916B7538d95bD3bF313B48fB90E269E30558Ec;
        address boTokenAddress = 0xaE60E4AF2b4cD3D2d3156f47c5038D05af4B1e91;
        
        MemeFactory factory = MemeFactory(factoryAddress);
        MemeToken boToken = MemeToken(boTokenAddress);
        
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY2");
        
        vm.startBroadcast(userPrivateKey);
        
        console.log("=== Mint Bo - Round 1 ===");
        console.log("User address:", msg.sender);
        console.log("Balance before:", boToken.balanceOf(msg.sender) / 1e18, "Bo");
        
        // 第1次 mint
        factory.mintMeme{value: 0.001 ether}(boTokenAddress);
        console.log("Balance after mint 1:", boToken.balanceOf(msg.sender) / 1e18, "Bo");
        
        console.log("");
        console.log("=== Mint Bo - Round 2 ===");
        
        // 第2次 mint
        factory.mintMeme{value: 0.001 ether}(boTokenAddress);
        console.log("Balance after mint 2:", boToken.balanceOf(msg.sender) / 1e18, "Bo");
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("=== Final Summary ===");
        console.log("Total Bo tokens:", boToken.balanceOf(msg.sender) / 1e18);
        console.log("Current supply:", boToken.currentSupply() / 1e18);
    }
}

