//SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {

    // ----- previous contract deployment -----
    // function run() external {
    //     vm.startBroadcast();
    //     FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    //     vm.stopBroadcast();
    // }  

    function run() external returns(FundMe){
        // ----- previous contract deployment -----
        // vm.startBroadcast();
        // FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // vm.stopBroadcast();

        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }  
}