//SPDX-License-Identifier: MIT

//1. Deploy mocks when we are on a local anvil chain
//2. keep track of contract addresses across different networks:
// (A) sepolia eth/usd
// (B) mainnet eth/usd
// we will build such that price feed address is automatically choosen (through chain id) according to chain we are deploying to

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // since we need to write configuration repeatedly for all networks we can use a struct
    struct NetworkConfig {
        address priceFeed;
    }
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address of sepolia testnet from docs.chain.link
        NetworkConfig memory sepoliaConfig = NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address of eth mainnet from docs.chain.link
        NetworkConfig memory ethConfig = NetworkConfig(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        return ethConfig;
    }

    //since we using vm ,this fn cant be pure
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // a condition telling that before running this fn, if a address is alsready assigned to price feed then dont run this fn. ye fn tabhi run krna hai jab current price feed address zero hai
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //price feed address using mocks
        //1. deploy mocks (real contracts but we own and control them)
        //2. return address of mocks

        // 1.lets deploy our own price feed contract
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8); //8 because generally 8 decimals in eth and inital guess of 2000$
        vm.stopBroadcast();

        // 2.
        NetworkConfig memory anvilConfig = NetworkConfig(
            address(mockPriceFeed)
        );
        return anvilConfig;
    }
}
