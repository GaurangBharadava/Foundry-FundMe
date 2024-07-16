// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConvertor {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint) {
        //returns price of ethereum in terms of USD.
        //we needs two things
        //address 0x694AA1769357215DE4FAC081bf1f309aDC325306 for ETH/USD
        //ABI

        (, int256 price, , , ) = priceFeed.latestRoundData();
        //price of etherium in terms of usd

        return uint(price * 1e10);
    }

    function getConversionRate(
        uint ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint) {
        uint ethPrice = getPrice(priceFeed);
        uint ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }

    function getVersion(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        return priceFeed.version();
    }
}
