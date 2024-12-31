// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // Function to convert a value based on the price
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
      uint256 ethPrice = getLatestPrice(priceFeed);
      uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
    
      return ethAmountInUsd;
    }

    // Function to get the price of Ethereum in USD
    function getLatestPrice(AggregatorV3Interface priceFeed) public view returns (uint256) {
      (,int answer,,,) = priceFeed.latestRoundData();
      return uint(answer) * 1e10;
    }
    
}