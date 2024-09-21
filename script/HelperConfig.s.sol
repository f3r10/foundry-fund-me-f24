// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^ 0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
	// if in local anvil, deploy mocks
	// otherwise, use existing address from the live network
	NetworkConfig public activeNetworkConfig;

	uint8 DECIMALS = 8;
	int256 INITIAL_PRICE = 2000e8;

	struct NetworkConfig {
		address priceFeed; // ETH/USD price feed address
	}

	constructor () {
		if (block.chainid == 11155111){
			activeNetworkConfig = getSepoliaEthConfig();
		} else {
			activeNetworkConfig = getOrCreateAnvilEthConfig();
		}
		
	}

	function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
		// price feed address
		NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
		return sepoliaConfig;
	}

	function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
		// check if the mocks was already deployed
		if (activeNetworkConfig.priceFeed != address(0)) {
			return activeNetworkConfig;
		}
		// price feed address

		// 1. deploy the mocks
		// 2. return the mock address
		vm.startBroadcast();// everything after here is a real TX so consume gas
		MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
		vm.stopBroadcast();
		NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
		return anvilConfig;
		
	}
	
}
