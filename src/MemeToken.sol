// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MemeToken {
    // 基础信息
    string public constant name = "MemeToken";
    string public symbol;
    uint8 public constant decimals = 18;
    
    // 铸造参数
    uint256 public totalSupply;      // 总发行量
    uint256 public currentSupply;    // 当前已铸造量
    uint256 public perMint;          // 每次铸造数量
    uint256 public price;            // 每个代币价格(wei)
    
    // 地址
    address public creator;          // Meme 发行者
    address public factory;          // 工厂合约地址
    
    // 余额映射
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    // 初始化标志
    bool private initialized;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    /// @notice 初始化 Meme 代币（替代 constructor）
    function initialize(
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _perMint,
        uint256 _price,
        address _creator,
        address _factory
    ) external {
        require(!initialized, "Already initialized");
        initialized = true;
        
        symbol = _symbol;
        totalSupply = _totalSupply;
        perMint = _perMint;
        price = _price;
        creator = _creator;
        factory = _factory;
    }
    
    /// @notice 铸造代币（只能工厂调用）
    function mint(address to) external {
        require(msg.sender == factory, "Only factory can mint");
        require(currentSupply + perMint <= totalSupply, "Exceeds total supply");
        
        balanceOf[to] += perMint;
        currentSupply += perMint;
        
        emit Transfer(address(0), to, perMint);
    }
    
    /// @notice ERC20 标准函数：转账
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    /// @notice ERC20 标准函数：授权转账
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    /// @notice ERC20 标准函数：授权
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}

