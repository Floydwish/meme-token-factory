// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MemeFactory.sol";

contract DeployBoScript is Script {
    function run() external {
        address factoryAddress = 0x27916B7538d95bD3bF313B48fB90E269E30558Ec;
        MemeFactory factory = MemeFactory(factoryAddress);
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY1");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 发行 Bo: 总量2100万, 每次mint 10个, 价格0.001 ether
        address boToken = factory.deployMeme(
            "Bo",
            21000000 * 1e18,  // 2100万
            10 * 1e18,         // 每次10个
            0.001 ether        // 每次mint价格
        );
        
        console.log("Bo Meme deployed at:", boToken);
        console.log("Creator (PRIVATE_KEY1):", msg.sender);
        
        vm.stopBroadcast();
    }
}

