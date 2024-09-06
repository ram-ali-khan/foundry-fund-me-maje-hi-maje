// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// import {PriceConverter} from "./PriceConverter.sol";      //neeche pura code hi copy kr rakha h

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address private /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;                  //refactored

    constructor(address priceFeed) {            //refactored
        i_owner = msg.sender;  
        s_priceFeed = AggregatorV3Interface(priceFeed);                 //rafactored            
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");        //refactored
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();           //refactored
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }


    /*************
     ***   getter funcitons : to excess the stored data in mappings, arrays etc.
     ***                view / pure functions
    *************/
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint funderIndex) external view returns (address) {
        return funders[funderIndex];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly





//now copying the price converter code here because wha se yha import hone me koi problem ho rhi thi 
// also isse import krne wali line bhi commnent kr di hai

library PriceConverter {
    // We could make this public, but then we'd have to deploy it
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //refactored
        // Sepolia ETH / USD Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit
        return uint256(answer * 10000000000);
    }

    // 1000000000
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }
}


