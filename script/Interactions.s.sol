/****************************************
 * what are scripts actually??
 * *************************************
 * In Foundry, a script refers to a special kind of Solidity or JavaScript file used to interact with smart contracts, perform complex testing, or deploy contracts. The script folder in a Foundry project is typically where these scripts are stored.

    Purpose of the script folder:

	1.	Deployment: Scripts can be written to automate the deployment of contracts to different networks (e.g., local, testnet, or mainnet). This helps avoid manual deployment using tools like Remix or command-line interfaces.
	2.	Interactions: Once a contract is deployed, you can use scripts to interact with the contract, such as calling its functions, transferring tokens, or checking balances.
	3.	Testing and Simulation: You can create more advanced tests or simulate real-world interactions within these scripts to see how contracts behave in various scenarios.
	4.	Utility Functions: Scripts can include helper functions or setup code that prepare the environment for running tests or deployments, for example:
	•	Setting up required addresses, mock tokens, or configurations.

 * ************************************** */

//SPDX-License-Identifier: MIT

// 1. write Fund Script
// 2. wtite Withdraw script
/* ??????????????????????????????????????????????????????????????????
  jaise pehle unit tests me hame bar bar deployfundme ka use krna tha to uski ek script likh di thi.
 ab integration test me hame bar bar deployfundme k sath fundfundme and withdrawfundme ka use krna padega to unke liye do script or likh di. and also while writing these two scripts we needed a deployed fundme(jisko fund denge ya withdraw karenge), jiske liye hmne devops ka use kia
????????????????????????????????????????????????????????????????????*/
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentDeployedFundMe) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedFundMe)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("de diye %s fund", SEND_VALUE);
    }

    function run() external {
        address mostRecentDeployedFundMe = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid); //use of devops to get the most recent deployed contract

        fundFundMe(mostRecentDeployedFundMe);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdrawFundMe(address mostRecentDeployedFundMe) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedFundMe)).withdraw();
        vm.stopBroadcast();
        console.log("nikal liye hai funds");
    }

    function run() external {
        address mostRecentDeployedFundMe = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid); //use of devops to get the most recent deployed contract

        withdrawFundMe(mostRecentDeployedFundMe);
    }
}
