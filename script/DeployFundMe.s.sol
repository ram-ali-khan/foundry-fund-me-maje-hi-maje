// SPDX-License_Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperconfig = new HelperConfig();
        // address priceFeed = helperConfig.activeNetworkConfig.priceFeed; // error because struct ke andar ki cheeje dot lagake excess nhi hoti but (a,,) = networkconfig  aise hoti hai. but here we have only single thing inside the bracket, no need of commas
        address priceFeed = helperconfig.activeNetworkConfig();

        //after startbroadcast -> real transaction happens
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}



/*

chatgpt explains the full above code:



Contract Inheritance:
    o The script inherits from Script (part of forge-std), which is used for scripting in Foundry.
    o Scripts in Foundry are executed to deploy contracts or interact with them in a blockchain simulation or live environment.
HelperConfig Usage:
    o A new instance of HelperConfig is created: HelperConfig helperconfig = new HelperConfig();
    o HelperConfig likely provides configuration details like the priceFeed address for the active network (e.g., Ethereum mainnet, Goerli testnet).
Active Network Configuration:
    o activeNetworkConfig function of HelperConfig returns the priceFeed address. This is used to specify the required data feed contract address when deploying FundMe.
Deploying FundMe:
    o The vm.startBroadcast() method indicates the start of a real blockchain transaction.
    o The FundMe contract is instantiated with the priceFeed address as its constructor parameter: FundMe fundMe = new FundMe(priceFeed);.
    o The deployment transaction stops with vm.stopBroadcast().
Return Value:
    o The deployed instance of the FundMe contract is returned for further use.



*/