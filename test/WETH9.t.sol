// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/WETH9.sol";

contract TESTWETH9 is Test {
    uint a = 1;
    uint b = 1;
    function test_WETH9() public {
        assertEq(a, b);
    }
}
