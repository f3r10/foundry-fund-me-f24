// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
	DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public {
        // console.log(number);
        // console.log("hi!!!");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
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
}
