// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 10000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
	DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
	vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        // console.log(number);
        // console.log("hi!!!");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // this method make use of an address that is not present in the anvil
    // the address is present in sepolia, so it is necessary to fork that 
    // enviroment with --fork-url
    // the downside of this approach is that alchemy is not free that this kind of test
    // real money.
    function testPriceFeedVersionIsAccurate() public {
	    uint256 version = fundMe.getVersion();
	    assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
	    vm.expectRevert(); // next line should revert
	    fundMe.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
	    // at first the USER has not funds, so the test fail
	    // the solution is to use vm.deal
	    vm.prank(USER); // the next TX will be sent by USER
	    fundMe.fund{value: SEND_VALUE}();
	    // not msg.sender
	    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
	    assertEq(amountFunded, SEND_VALUE);
    	
    }

    function testAddFunderToArrayOfFunders() public {
	    // at first the USER has not funds, so the test fail
	    // the solution is to use vm.deal
	    vm.prank(USER); // the next TX will be sent by USER
	    fundMe.fund{value: SEND_VALUE}();

	    address funder = fundMe.getFunder(0);
	    assertEq(funder, USER);
    	
    }

    modifier funded(){
	    vm.prank(USER); // the next TX will be sent by USER
	    fundMe.fund{value: SEND_VALUE}();
	    _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
	    vm.prank(USER); // the next TX will be sent by USER
	    vm.expectRevert();
	    fundMe.withdraw();
    }

    function testWithDrawWithSingleFunder() public funded {
	    //Arrange
	    uint256 startingOwnerBalance = fundMe.getOwner().balance;
	    uint256 startingFundMeBalance = address(fundMe).balance;

	    // Act
	    vm.prank(fundMe.getOwner());
	    fundMe.withdraw();

	    // Assert
	    uint256 endingOwnerBalance = fundMe.getOwner().balance;
	    uint256 endingFundMeBalance = address(fundMe).balance;
	    assertEq(endingFundMeBalance, 0);
	    assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
	    //Arrange
	    uint160 numberOfFunders = 10;
	    uint160 startingFunderIndex = 1;
	    for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
		    //hoax the same as prank + deal
		    hoax(address(i), SEND_VALUE);
		    fundMe.fund{value: SEND_VALUE}();
	    }
	    uint256 startingOwnerBalance = fundMe.getOwner().balance;
	    uint256 startingFundMeBalance = address(fundMe).balance;

	    // Act
	    vm.startPrank(fundMe.getOwner());
	    fundMe.withdraw();
	    vm.stopPrank();

	    // Assert
	    assert(address(fundMe).balance == 0);
	    assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    	
    }
}
