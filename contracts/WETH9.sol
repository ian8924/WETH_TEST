// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./erc20.sol";

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
}


contract WETH9 is MyToken , IWETH9 {
    function deposit() external payable  {
       balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        this.transfer(msg.sender, _amount);
        this.burn(_amount);
    }

    receive() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}