// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^ 0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";

contract HelperConfig {
	// if in local anvil, deploy mocks
	// otherwise, use existing address from the live network
	NetworkConfig public activeNetworkConfig;

	struct NetworkConfig {
		address priceFeed; // ETH/USD price feed address
	}

	constructor () {
		if (block.chainid == 11155111){
			activeNetworkConfig = getSepoliaEthConfig();
		} else {
			activeNetworkConfig = getAnvilEthConfig();
		}
		
	}

	function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
		// price feed address
		NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
		return sepoliaConfig;
	}

	function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
		// price feed address
		
	}
	
}
