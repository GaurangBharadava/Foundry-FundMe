// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//get fund from user.
//withdraw funds.
//set minimum funding value in USD.

// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   function getRoundData(
//     uint80 _roundId
//   ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

//   function latestRoundData()
//     external
//     view
//     returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
// }
// import interface instead of writing it.
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConvertor} from "./PriceConvertor.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConvertor for uint;

    uint public constant minimumUSD = 5 * 1e18; // 5 * 1e18 because the getconvirsion rate will return in 1e18 form.

    address[] private s_funders; // list of funders.
    mapping(address funder => uint amountFunded) private s_addressToAmount; //how much amount the funder funded.
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    modifier Owner() {
        require(msg.sender == i_owner, "Must Be owner");
        _;
    }

    function fund() public payable {
        //Allow all user to send money.
        //have minimum $ sent
        //1. how do we send ETH to this contract?
        // require(
        //     getConversionRate(msg.value) >= minimumUSD,
        //     "didn't sent enough ETH"
        // ); //1e18 = 1ETH = 1 * 10 ** 18;

        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUSD,
            "didn't sent enough ETH"
        );

        //what is revert?
        //undo any action that we have been done and send remaining gas back to account.
        s_funders.push(msg.sender);
        s_addressToAmount[msg.sender] =
            s_addressToAmount[msg.sender] +
            msg.value;
    }

    //for making easy we are going to create a library called priceConvertor in ehich these function will be implemented again.

    // function getPrice() public view returns (uint) {
    //     //returns price of ethereum in terms of USD.
    //     //we needs two things
    //     //address 0x694AA1769357215DE4FAC081bf1f309aDC325306 for ETH/USD
    //     //ABI

    //     (, int256 price, , , ) = s_priceFeed.latestRoundData();
    //     //price of etherium in terms of usd

    //     return uint(price * 1e10);
    // }

    // function getConversionRate(uint ethAmount) public view returns (uint) {
    //     uint ethPrice = getPrice();
    //     uint ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
    //     return ethAmountInUSD;
    // }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public Owner {
        for (
            uint funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmount[funder] = 0;
        }

        //reset funder list
        s_funders = new address[](0);

        //withdraw the fund.
        //transfer
        //send
        //call

        // payable(msg.sender).transfer(address(this).balance);

        // bool ok = payable(msg.sender).send(address(this).balance);
        // require(ok,"transaction failed");

        (bool Ok, ) = payable(msg.sender).call{value: address(this).balance}(
            "Cannot withdraw"
        );
        require(Ok, "call failed");
    }

    function cheaperWithdraw() public Owner {
        uint fundersLength = s_funders.length;
        for (
            uint funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmount[funder] = 0;
        }
        (bool Ok, ) = payable(msg.sender).call{value: address(this).balance}(
            "Cannot withdraw"
        );
        require(Ok, "call failed");
    }

    function getAddressToAmmountFunded(
        address fundingAddress
    ) external view returns (uint) {
        return s_addressToAmount[fundingAddress];
    }

    function getFunder(uint index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
