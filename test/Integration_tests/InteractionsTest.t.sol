//SPDX-License Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeInteractionTests is Test {
    FundMe fundMe; //declared

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 100 ether); // cheatcode : gives fake money to the USER
    }

    //above this was similar to the unit tests. now we will write the actual new interaction tests where we will ineract with the two new scripts we have written namely FundFundMe and WithdrawFundMe
    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe)); // funding krdi setup me deploy kiye gaye contract ko. using our new FundFundMe script

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe)); // withdrawing krdi setup me deploy kiye gaye contract se. using our new WithdrawFundMe script

        assertEq(address(fundMe).balance, 0);
    }
}
