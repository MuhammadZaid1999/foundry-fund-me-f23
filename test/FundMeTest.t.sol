// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    // -------------------------- For Basic Testing ---------------------------

    // uint256 favNumber = 0;
    // bool greatCourse = false;

    // function setUp() external {
    //     favNumber = 1337;
    //     greatCourse = true;
    //     console.log("This will get printed first!");
    // }
    
    // function testDemo() public view { 
    //     assertEq(favNumber, 1337);
    //     assertEq(greatCourse, true);
    //     console.log("This will get printed second!");
    //     console.log("Updraft is changing lives!");
    //     console.log("You can print multiple things, for example this is a uint256, followed by a bool:", favNumber, greatCourse);
    // }

    // ---------------------------------------------------------------

    FundMe fundMe;
    DeployFundMe deployFundMe;

    function setUp() external {
        // ------ deploy directly throught hardcode address
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // ----- previous contract function testing -----
    // function testOwnerIsMsgSender() public view {
    //     console.log(fundMe.i_owner());
    //     console.log(msg.sender);
    //     assertEq(fundMe.i_owner(), address(this));
    // }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // ----- previous contract function testing -----
    // function testPriceFeedVersionIsAccurate() public view {
    //     uint256 version = fundMe.getVersion();
    //     assertEq(version, 4);
    // }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        if(block.chainid == 11155111){
            assertEq(version, 4);
        }else if(block.chainid == 1){
            assertEq(version, 6);
        }else{
            assertEq(version, 4);
        }
    }
}
