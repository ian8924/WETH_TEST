// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./erc20.sol";

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
    event Deposit(address indexed to, uint amount);
    event Withdrawal(address indexed from, uint amount);
}


contract WETH9 is MyToken , IWETH9 {
    function deposit() external payable  {
       balanceOf[msg.sender] += msg.value;
       emit Deposit(msg.sender, msg.value);
    }

   function withdraw(uint amount) public {
        require(balanceOf[msg.sender] >= amount, "not enough");
        balanceOf[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "withdraw failed");
        emit Withdrawal(msg.sender, amount);
    }

    receive() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}