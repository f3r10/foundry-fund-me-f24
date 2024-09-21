// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

//Forking on a simulated real env
contract DeployFundMe is Script {
    function run() external returns (FundMe) {
	HelperConfig helperConfig = new HelperConfig();
	address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // vm only works in foundry
        vm.startBroadcast();// everything after here is a real TX so consume gas
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
