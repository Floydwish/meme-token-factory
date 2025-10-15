// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

contract FundAccountsScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address addr1 = vm.envAddress("ADDRESS1");
        address addr2 = vm.envAddress("ADDRESS2");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 给 PRIVATE_KEY1 和 PRIVATE_KEY2 各转 0.01 ETH
        payable(addr1).transfer(0.01 ether);
        payable(addr2).transfer(0.01 ether);
        
        console.log("Funded ADDRESS1:", addr1, "with 0.01 ETH");
        console.log("Funded ADDRESS2:", addr2, "with 0.01 ETH");
        
        vm.stopBroadcast();
    }
}

