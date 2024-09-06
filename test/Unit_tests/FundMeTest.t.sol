//all test file names end with .t.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/*
bssics h ye thode:

import {Test, console} from "forge-std/Test.sol"; //imported the basic Test named contract and then imported console to use the function console.log to print in the terminal

contract FundMeTest is Test {
    uint256 number = 1;

    function setUp() external {                    // this function will be called before each test to deploy the contract
        number = 2;
    }

    function testDemo() public view {
        assertEq(number, 2);                    // one method of debugging (the Test contract we imported gives us access to this assert equal function)
        console.log(number);                    // another method of debugging
        console.log("hlllo ji");
    }
}


*/

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; //declared

    //cheatcode that will assign a fake address to the name "user"
    address USER = makeAddr("user");

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); //initialised       // this was hardcoded to a sepolia testnet and we have provided the address of sep eth/usd pricefeed  // to make it flexible, we used helper config
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 100 ether); // cheatcode : gives fake money to the USER
    }

    function testTheMinimumUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); //tested
    }

    //another testing function:
    function testOwnerIsMsgSender() public view {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender); // test will pass now the owner path has changed due to new refactoring
    }

    // function testOwnerIsMsgSender2() public view {
    //     assertEq(fundMe.i_owner(), address(this)); // test fail.
    // }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    //test failed because we didn't specify the chain address on which the tests will be running. so it creates a anvil chain and delete it after the test are done.
    // This mismatch likely occurred because the test was run in a local simulated environment (anvil) rather than against
    // a specific live blockchain where the Chainlink aggregator contract with version 4 is deployed .
    // this test passes when it we run on the forked environment.

    /**********************************************
     *         tests using cheatcodes:
     * *********************************************/
    function testEnoughEth() public {
        vm.expectRevert(); //(cheatcode)this means next line should revert. if reverts then the test will pass
        fundMe.fund(); // NOT SENDING FUNDS
    }

    function testIfFundUpdatesFundersStorage() public {
        // 1.send the funds
        vm.prank(USER); // cheatcode to deal with msg.sender during tests: next tx will be sent by the USER
        fundMe.fund{value: 10e18}();

        // 2. test it
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10e18); //this will fail if we dont give money to the USER using cheatcode in the setup fn
    }

    // **** ALL TEST ARE INDEPENDENT OF EACH OTHER. ****
    // **** tests are executed in this order: Setup -> TEst 1 -> Setup -> TEst 2 -> Setup -> TEst 3 ****

    // one more similar test
    function testIfFundAddsFunderToFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        address funder = fundMe.getFunder(0); // index 0 only because all tests are independent and the fund given in last test is not added to the funders array
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        vm.expectRevert(); //vm means the next transaction while not the next vm line. so both this and next line are talking about the fundMe.withdraw() tx.
        vm.prank(USER);
        fundMe.withdraw();
    }

    // *** This test can also be written using MODIFIER like this:
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function testOnlyOwnerCanWithdraw2() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 staringFundMeBalance = address(fundMe).balance; // address(fundMe) means the adddress of the contract

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + staringFundMeBalance
        );
    }

    /* example of txGasPrice: replace the //Act part of above test with this and then the test will start using gas:

        uint256 gasStart = gasleft(); //built in fn to tell the gas left in our current fn call
        vm.txGasPrice(1 ether);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("gas used: ", gasUsed);

    */

    function testWithdrawFromMultipleFunder() public funded {
        //Arrange
        uint160 numberOfFunders = 10; // generate address from uint160 bcoz it has same number of bytes as an address
        uint160 startingIndex = 1; //avoid 0 index because there is often sanity checks and and it will revert.  In Solidity, the address 0x0000000000000000000000000000000000000000 (which is just called the “0 address”) is often used as a special value to represent something that hasn’t been set or isn’t valid. Many smart contracts have checks to make sure they aren’t accidentally using this 0 address because it’s not a real, usable address.

        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            //vm.prank
            //vm.deal new addres       //***** hoax (prank + deal) = cheatcode that sets up a prank from an address that has some balance
            hoax(address(i), 10e18);
            fundMe.fund{value: 10e18}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 staringFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner()); //tx between start and stop by the address
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.getOwner().balance,
            startingOwnerBalance + staringFundMeBalance
        );
    }
}
