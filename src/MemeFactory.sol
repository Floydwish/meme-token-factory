// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 实现 ERC1167 最小代理模式，用于低成本克隆合约。
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./MemeToken.sol";
import "./UniswapInterfaces.sol";

contract MemeFactory {
    address public immutable implementation;  // MemeToken 实现合约
    address public immutable platform;        // 平台方地址（收5%费用用于流动性）
    address public immutable uniswapRouter;    // Uniswap V2 Router 地址
    
    address[] public allMemes;                // 所有创建的 Meme 地址
    
    event MemeCreated(address indexed memeToken, address indexed creator, string symbol);
    event MemeMinted(address indexed memeToken, address indexed buyer, uint256 amount, uint256 paid);
    event LiquidityAdded(address indexed token, uint256 ethAmount, uint256 tokenAmount, uint256 liquidity);
    event MemeBought(address indexed token, address indexed buyer, uint256 amount, uint256 paid);
    
    constructor(address _uniswapRouter) {
        platform = msg.sender;
        uniswapRouter = _uniswapRouter;
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
        
        // 费用分配：5% 给平台（用于流动性），95% 给创建者
        uint256 platformFee = cost * 5 / 100;
        uint256 creatorFee = cost - platformFee;
        
        // 铸造代币
        token.mint(msg.sender);
        
        // 添加流动性（如果 Uniswap Router 可用）
        if (platformFee > 0 && address(uniswapRouter) != address(0)) {
            addLiquidityToUniswap(tokenAddr, platformFee);
        } else {
            payable(platform).transfer(platformFee);
        }
        
        // 转账给创建者
        payable(token.creator()).transfer(creatorFee);
        
        // 退还多余支付
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        
        emit MemeMinted(tokenAddr, msg.sender, token.perMint(), cost);
    }
    
    /// @notice 添加流动性到 Uniswap V2
    /// @param tokenAddr 代币地址
    /// @param platformFee 平台费用
    function addLiquidityToUniswap(address tokenAddr, uint256 platformFee) internal {
        MemeToken token = MemeToken(tokenAddr);
        
        uint256 ethForLiquidity = platformFee;
        require(ethForLiquidity > 0, "No ETH for liquidity");
        
        uint256 tokenAmount = ethForLiquidity / token.price();
        
        require(token.balanceOf(address(this)) >= tokenAmount, "Insufficient token balance");
        
        token.approve(address(uniswapRouter), tokenAmount);
        
        IUniswapV2Router02(uniswapRouter).addLiquidityETH{value: ethForLiquidity}(
            tokenAddr,
            tokenAmount,
            tokenAmount * 95 / 100,  // 5% 滑点保护
            ethForLiquidity * 95 / 100,  // 5% 滑点保护
            address(this),
            block.timestamp + 300
        );
        
        emit LiquidityAdded(tokenAddr, ethForLiquidity, tokenAmount, 0);
    }
    
    /// @notice 从 Uniswap 购买 Meme 代币（当价格更好时）
    /// @param tokenAddr Meme 代币地址
    /// @param minTokenAmount 最小代币数量
    function buyMeme(address tokenAddr, uint256 minTokenAmount) external payable {
        require(msg.value > 0, "Must send ETH");
        require(address(uniswapRouter) != address(0), "Uniswap Router not set");
        
        address[] memory path = new address[](2);
        path[0] = IUniswapV2Router02(uniswapRouter).WETH();
        path[1] = tokenAddr;
        
        uint256[] memory amounts = IUniswapV2Router02(uniswapRouter).swapExactETHForTokens{value: msg.value}(
            minTokenAmount,
            path,
            msg.sender,
            block.timestamp + 300
        );
        
        emit MemeBought(tokenAddr, msg.sender, amounts[1], msg.value);
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

