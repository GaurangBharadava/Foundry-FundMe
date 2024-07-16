// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); //fake user made for calling test function.

    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BALANCE = 10 ether;

    // uint constant GAS_PRICE = 1;

    function setUp() external {
        // we -> FundMeTest -> fundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); //give user fake mony for testing purpose.
    }

    function testMinimumDollerIsFive() public view {
        assertEq(fundMe.minimumUSD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        // assertEq(fundMe.i_owner(), address(this));

        assertEq(fundMe.getOwner(), msg.sender);
    }

    /* 
    what we can do to work with address outside of our system
    1. Unit
    -testing a specific part of our code

    2. Integration
    -testing how our code works with other part of our code

    3.Forked
    -testing our code on a simulated real environment

    4.Staging:
    -testing our code in a real environment that is not prod 

    */

    function testPriceFeedVersionIsAccurate() public view {
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailesWithoutEnoughEth() public {
        vm.expectRevert(); // the next line should be revert.
        //assert(this Tx fails)
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        // fundMe.fund{value: 10e18}();
        // uint ammountFunded = fundMe.getAddressToAmmountFunded(address(this));
        // assertEq(ammountFunded, 10e18);

        //we will make fake user who will call the nexy Tx
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint ammountFunded = fundMe.getAddressToAmmountFunded(USER);
        assertEq(ammountFunded, SEND_VALUE);
    }

    function testAddsFundersToArrayOfFunder() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        // uint startGas = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint endGas = gasleft();

        // uint gasUsed = (startGas-endGas) * tx.gasprice;
        // console.log(gasUsed);

        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint160 numberOfFunders = 10; //if we want to work with address or generate address from numbers then we will type cast uint160
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            //vm.prank(new address or user)
            //vm.deal(new address or user, starting value)
            //address()

            //hoax is combine of these.
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint160 numberOfFunders = 10; //if we want to work with address or generate address from numbers then we will type cast uint160
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            //vm.prank(new address or user)
            //vm.deal(new address or user, starting value)
            //address()

            //hoax is combine of these.
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }
}
