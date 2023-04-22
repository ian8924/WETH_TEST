// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../contracts/WETH9.sol";

contract Weth9Test is Test {
    WETH9 public weth9;
    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);

    event Approval(address indexed owner, address indexed spender, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Deposit(address indexed to, uint amount);
    event Withdrawal(address indexed src, uint wad);

    function setUp() public {
        weth9 = new WETH9();

        vm.deal(user1, 10 ether);
        vm.label(user1, "USER 1");

        vm.deal(user2, 10 ether);
        vm.label(user2, "USER 2");
    }

    // 1.deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function test_deposit(uint256 amount) external {
        vm.assume(amount <= 10 ether);
        
        vm.prank(user1);
        weth9.deposit{ value: amount }();

        assertEq(weth9.balanceOf(user1), amount, "Invalid : user balance not equal to msg.value");
    }

    // 2. deposit 應該將 msg.value 的 ether 轉入合約
    function test_depositShouldToContract(uint256 amount) external {
        vm.assume(amount <= 10 ether);

        // 取得合約餘額 （before）
        vm.prank(user1);
        weth9.deposit{ value: amount }();

        assertEq( weth9.balanceOf(user1), amount , "Invalid : ether balance after deposit");    
    }

    // 測項 3: deposit 應該要 emit Deposit event
    function test_depositShouldEmit(uint256 amount) external {
        vm.assume(amount <= 10 ether);

        vm.expectEmit(true, true, true, true);
        emit Deposit(user1, amount);

        vm.prank(user1);
        weth9.deposit{value: amount}();
    }

    // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
    function test_withdraw_burn(
        uint256 depositAmount,
        uint withdrawAmount
    ) external {
        // 條件
        vm.assume(depositAmount <= 10 ether);
        vm.assume(withdrawAmount <= depositAmount);

        vm.startPrank(user1);
        weth9.deposit{value: depositAmount}();
        assertEq(depositAmount,weth9.balanceOf(user1));

        weth9.withdraw(withdrawAmount);
        assertEq(depositAmount - withdrawAmount ,weth9.balanceOf(user1));

        vm.stopPrank();
    }
 
    // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function test_withdrawBurnEtherToUser(
        uint withdrawAmount
    ) external {
        vm.assume(withdrawAmount <= 10 ether);

        vm.startPrank(user1);
        weth9.deposit{value: 10 ether}();

        uint256 beforeBalance = address(user1).balance;
        weth9.withdraw(withdrawAmount);
        uint256 afterBalance = address(user1).balance;

        assertEq(afterBalance, beforeBalance + withdrawAmount);
        vm.stopPrank();
    }

    // 測項 6: withdraw 應該要 emit Withdraw event
    function test_withdrawShouldEmit(
        uint withdrawAmount
    ) external {
        vm.assume(withdrawAmount <= 10 ether);

        vm.startPrank(user1);
        weth9.deposit{value: 10 ether}();

        vm.expectEmit(true, true, true, true);
        emit Withdrawal(user1, withdrawAmount);

        weth9.withdraw(withdrawAmount);

        vm.stopPrank();
    }


    // 測項 7: transfer 應該要將 erc20 token 轉給別人
    function test_transferShouldToken(
        uint transferAmount
    ) external {
        vm.assume(transferAmount <= 10 ether);

        vm.startPrank(user1);
        weth9.deposit{value: 10 ether}();

        weth9.transfer(user2, transferAmount);
        assertEq(weth9.balanceOf(user2),transferAmount);

        vm.stopPrank();
    }


    // 測項 8: approve 應該要給他人 allowance
    function test_approveShouldGiveAllowance(
        uint approveAmount
    ) external {
        vm.assume(approveAmount <= 10 ether);

        vm.startPrank(user1);
        weth9.deposit{value: 10 ether}();
        weth9.approve(user2, approveAmount);
        vm.stopPrank();

        assertEq(weth9.allowance(user1, user2),approveAmount);
    }

    //  測項 9: transferFrom 應該要可以使用他人的 allowance
     function test_transferFromShouldUseAllowance(
        uint allowanceAmount,
        uint sendAmount
    ) external {
        vm.assume(allowanceAmount <= 10 ether);
        vm.assume(allowanceAmount >= sendAmount);

        // user1 approve  user2
        vm.startPrank(user1);
        weth9.deposit{value: 10 ether}();
        weth9.approve(user2, allowanceAmount);        
        vm.stopPrank();
        // user2 傳 user1 token 給 user3
        vm.startPrank(user2);
        weth9.transferFrom(user1, user3, sendAmount);
        vm.stopPrank();
        // 確認傳完
        assertEq(weth9.balanceOf(user3),sendAmount);
    }

    //  測項 10: transferFrom 後應該要減除用完的 allowance
     function test_transferFromShouldUpdateAllowance(
        uint allowanceAmount,
        uint sendAmount
    ) external {
        vm.assume(allowanceAmount <= 10 ether);
        vm.assume(allowanceAmount >= sendAmount);

        // user1 approve  user2
        vm.startPrank(user1);
        weth9.deposit{value: 10 ether}();
        weth9.approve(user2, allowanceAmount);        
        vm.stopPrank();
        // user2 傳 user1 token 給 user3
        vm.startPrank(user2);
        weth9.transferFrom(user1, user3, sendAmount);
        vm.stopPrank();
        // 確認傳完
        vm.startPrank(user2);
        assertEq(weth9.allowance(user1, user2), allowanceAmount - sendAmount);
    }
}