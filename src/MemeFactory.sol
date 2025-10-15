// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 实现 ERC1167 最小代理模式，用于低成本克隆合约。
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./MemeToken.sol";

contract MemeFactory {
    address public immutable implementation;  // MemeToken 实现合约
    address public immutable platform;        // 平台方地址（收1%费用）
    
    address[] public allMemes;                // 所有创建的 Meme 地址
    
    event MemeCreated(address indexed memeToken, address indexed creator, string symbol);
    event MemeMinted(address indexed memeToken, address indexed buyer, uint256 amount, uint256 paid);
    
    constructor() {
        platform = msg.sender;
        implementation = address(new MemeToken());  // 部署实现合约
    }
    
    /// @notice 创建新的 Meme 代币（使用最小代理）
    /// @param symbol 代币符号
    /// @param totalSupply 总发行量
    /// @param perMint 每次铸造数量
    /// @param price 每个代币价格(wei)
    /// @return 新创建的 Meme 代币地址
    function deployMeme(
        string memory symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price
    ) external returns (address) {
        // 使用最小代理克隆实现合约
        address clone = Clones.clone(implementation);
        
        // 初始化克隆的合约
        MemeToken(clone).initialize(
            symbol,
            totalSupply,
            perMint,
            price,
            msg.sender,     // creator
            address(this)   // factory
        );
        
        allMemes.push(clone);
        emit MemeCreated(clone, msg.sender, symbol);
        
        return clone;
    }
    
    /// @notice 铸造 Meme 代币
    /// @param tokenAddr Meme 代币地址
    function mintMeme(address tokenAddr) external payable {
        MemeToken token = MemeToken(tokenAddr);
        
        // 获取铸造费用（price 是铸造一次的总费用）
        uint256 cost = token.price();
        require(msg.value >= cost, "Insufficient payment");
        
        // 费用分配：1% 给平台，99% 给创建者
        uint256 platformFee = cost / 100;
        uint256 creatorFee = cost - platformFee;
        
        // 铸造代币
        token.mint(msg.sender);
        
        // 转账费用
        payable(platform).transfer(platformFee);
        payable(token.creator()).transfer(creatorFee);
        
        // 退还多余支付
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        
        emit MemeMinted(tokenAddr, msg.sender, token.perMint(), cost);
    }
    
    /// @notice 获取所有 Meme 代币地址
    function getAllMemes() external view returns (address[] memory) {
        return allMemes;
    }
    
    /// @notice 获取 Meme 代币数量
    function memesCount() external view returns (uint256) {
        return allMemes.length;
    }
}

