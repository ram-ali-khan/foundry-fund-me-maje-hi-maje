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
