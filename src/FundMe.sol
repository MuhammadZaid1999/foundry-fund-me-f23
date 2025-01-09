// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {

    using PriceConverter for uint256;

    error NotOwner();
    // error NotOwner1(address, uint);

    // before constant: execution cost	2451 gas (Cost only applies when called by a contract)
    // after constant: execution cost	351 gas (Cost only applies when called by a contract)
    uint256 constant public MINIMUM_USD = 5e18;
    address[] private s_funders;

    // before immutable: execution cost	2558 gas (Cost only applies when called by a contract) 
    // after immutable: execution cost	444 gas (Cost only applies when called by a contract)
    address immutable public i_owner;

    AggregatorV3Interface private s_priceFeed;

    mapping(address => uint256) private s_addressToAmountFunded;

    modifier onlyOwner {
      // If the underscore `_` were placed before the `require` statement, 
      // the function’s logic would execute first, followed by the `require` check, 
      // which is not the intended use case.
      if(msg.sender != i_owner){
        revert NotOwner();
        // revert NotOwner1(msg.sender, 12345);
      }
      _;
    }

    receive() external payable {
      fund();
    }

    fallback() external payable {
      fund();
    }


    constructor(address priceFeed){
      i_owner = msg.sender;
      s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getVersion() public view returns (uint256) {
      // ----- we can also use this ------
      // AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
      // return priceFeed.version();

      return AggregatorV3Interface(s_priceFeed).version();
    }

    function fund() public payable {
      // Here, `msg.value`, which is a `uint256` type, is extended to include the `getConversionRate()` function. 
      // The `msg.value` gets passed as the first argument to the function. 
      // If additional arguments are needed, they are passed in parentheses:
      // uint256 result = msg.value.getConversionRate(123);
      // In this case, `123` is passed as the second `uint256` argument to the function.
      require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
   
      // a function revert will undo any actions that have been done.
      // It will send the remaining gas back
      s_funders.push(msg.sender);
      s_addressToAmountFunded[msg.sender] += msg.value;

    }

    function withdraw() public onlyOwner{
      uint256 funderIndex;
      for (funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
        address funder = s_funders[funderIndex];
        s_addressToAmountFunded[funder] = 0; 

        // resetting array of funder method1
        // funders[funderIndex] = address(0);
      }

      // resetting array of funder method1
      s_funders = new address[](0);

      
      // Methods of Sending ETH through Contract 

      // `transfer` has a significant limitation. 
      // It can only use up to 2300 gas and it reverts any transaction that exceeds this gas limit
      // payable(msg.sender).transfer(address(this).balance); 

      // `send` also has a gas limit of 2300. If the gas limit is reached, it will not revert the transaction 
      // but return a boolean value (`true` or `false`) to indicate the success or failure of the transaction. 
      // trigger a "revert" condition if the `send` returns `false`.
      // bool success = payable(msg.sender).send(address(this).balance);
      // require(success, "Send failed");

      // The `call` function is flexible and powerful. It can be used to call any function without requiring its ABI. 
      // It does not have a gas limit, and like `send`, it returns a boolean value instead of reverting like `transfer`.
      // `call` is the recommended way of sending and receiving Ethereum or other blockchain native tokens.
      (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
      require(success, "Call failed");
    }

    
        /** Getter Functions */
    
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
      return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
      return s_funders[index];
    }


}

