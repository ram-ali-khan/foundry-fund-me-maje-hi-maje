// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; //imported the basic Test named contract and then imported console to use the function console.log to print in the terminal

contract FundMeTest is Test {
    uint256 number = 1;

    function setUp() external {
        number = 2;
    }

    function testDemo() public {
        assertEq(number, 2);
        console.log(number);
        console.log("hlllo ji");
    }
}
