// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

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

    uint256 constant GAS_PRICE = 1;

    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;

    address alice = makeAddr("alice");

    FundMe fundMe;
    DeployFundMe deployFundMe;

    modifier funded {
        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function setUp() external {
        // ------ deploy directly throught hardcode address
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        vm.deal(alice, STARTING_BALANCE);
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

    // ----- previous contract function testing -----
    // function testOwnerIsMsgSender() public view {
    //     console.log(fundMe.i_owner());
    //     console.log(msg.sender);
    //     assertEq(fundMe.i_owner(), msg.sender);
    // }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
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

    function testFundFailsWIthoutEnoughETH() public {
        vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
        fundMe.fund();     // <- We send 0 value
    }

    function testFundUpdatesFundDataStructure() public { 
        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();
        
        uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testFundUpdatesFundDataStructure1() public funded { 
        uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public { 
        vm.startPrank(alice);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, alice);
    }

    function testAddsFunderToArrayOfFunders1() public funded { 
        address funder = fundMe.getFunder(0);
        assertEq(funder, alice);
    }

    function testOnlyOwnerCanWithdraw() public { 
        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
    
        vm.prank(alice);
        fundMe.withdraw();
    }

    function testOnlyOwnerCanWithdraw1() public { 
        vm.startPrank(alice);
        fundMe.fund{value: SEND_VALUE}();
    
        vm.expectRevert();
    
        fundMe.withdraw();
        vm.stopPrank();
    }

    function testOnlyOwnerCanWithdraw2() public funded { 
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
    
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // assert    
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }

    function testWithdrawFromASingleFunder1() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.txGasPrice(GAS_PRICE);
        uint256 gasStart = gasleft();
        console.log("Gas Start: %d", gasStart);

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        console.log("Gas End: %d", gasEnd);
        console.log("Tx gas price: %d", tx.gasprice);
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsed);

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }


    function testPrintStorageData() public view {
        for (uint256 i = 0; i < 3; i++) {
            bytes32 value = vm.load(address(fundMe), bytes32(i));
            console.log("Value at location", i, ":");
            console.logBytes32(value);
        }
        console.log("PriceFeed address:", address(fundMe.getPriceFeed()));
    }


    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);

    }

}
