// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);
}

contract MyToken is IERC20 {
    uint private _totalSupply;
    // 這個地址擁有的 token 數量
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public _allowance;

    // token 名稱
    string public name = "Yee Token";
    // token 代號
    string public symbol = "Yee";
    // token 數量級
    uint8 public immutable decimals = 1;
    // token 總量
    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }
    // owner 地址授權給 spender 地址使用的 token 數量
    function allowance(
        address owner,
        address spender
    ) external view returns (uint) {
        return _allowance[owner][spender];
    }

    // 從自己帳戶傳 amount 數量的 token 到 to 地址
    function transfer(address to, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 授權給 spender 地址使用的 token 數量
    function approve(address spender, uint amount) external returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    // 從 sender 地址傳 amount 數量的 token 到 recipient 地址
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        _allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // mint amount 數量的 token 至帳戶
    function mint(uint amount) public {
        balanceOf[msg.sender] += amount;    
        _totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // 燒毀 amount 數量的 token 從帳戶
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}