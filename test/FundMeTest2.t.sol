// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundme; //declared

    function setUp() external {
        fundme = new Fundme(); //initialised
    }

    function TestTheMinimumUSD() public {
        assertEq(fundme.MINIMUM_USD, 5e18); //tested
    }
}
