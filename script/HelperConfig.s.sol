// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//1. Deploy mokes when we are on local chain (anvil)
//2. keep track of contract address across diffrent chains
//3. Sepoilia ETH/USD
//4 Mainnet ETH/USD

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mokes/MokeV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainNetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //Price feed address.
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainNetEthConfig() public pure returns (NetworkConfig memory) {
        //Price feed address.
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //we dont want to deploye another new anvil config so we will add condition
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // when we are broadcasting contract, we cant make pure function.
        //Price feed address.
        vm.startBroadcast();
        MockV3Aggregator mokePriceFeed = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mokePriceFeed)
        });
        return anvilConfig;
    }
}
