// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Exchange} from "../src/Exchange.sol";
import {Token} from "../src/Token.sol";
import "forge-std/Vm.sol";

contract ExchangeTest is Test {
    Exchange public exchange;
    Token token;

    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");

    function setUp() public {
        vm.startPrank(owner);
        token = new Token("zuniswap token", "zuni", 400 ether);
        exchange = new Exchange(address(token));
        token.transfer(user1, 200 ether);
        vm.deal(user1, 500 ether);
        vm.stopPrank();
    }

    function test_verify_tokenAddress() external {
        assert(address(token) == exchange.tokenAddress());
    }

    function test_addLiquidity() external {
        vm.startPrank(user1);
        uint total_balance = 200 ether;
        token.approve(address(exchange), total_balance);
        exchange.addLiquidity{value: 100 ether}(total_balance);
        assert(exchange.getReserve() == total_balance);
        vm.stopPrank();
    }

    function _addLiquidity() internal {
        uint total_balance = 200 ether;
        token.approve(address(exchange), total_balance);
        exchange.addLiquidity{value: 100 ether}(total_balance);
    }

    function test_getAmounts() external {
        vm.startPrank(user1);
        _addLiquidity();
        //  We get 0.99 ether for 2 tokens
        assert(exchange.getEthAmount(2 ether) == 990099009900990099);
        assert(exchange.getTokenAmount(1 ether) == 1980198019801980198);
        vm.stopPrank();
    }

    function test_ethToTokenSwap() external {
        vm.startPrank(user1);
        _addLiquidity();
        uint swap_amount_eth = 2 ether;
        uint token_balance_before = token.balanceOf(user1);
        uint expected_token_amount = exchange.getTokenAmount(swap_amount_eth);
        exchange.ethToTokenSwap{value: 2 ether}(expected_token_amount);
        uint current_token_balance = token.balanceOf(user1);
        assert(
            current_token_balance >=
                token_balance_before + expected_token_amount
        );
        vm.stopPrank();
    }
    //  Swap tokens
    function test_tokenToETHSwap() external {
        vm.startPrank(user1);
        _addLiquidity();
        uint swap_amount_token = 4 ether;
        uint eth_balance_before = address(user1).balance;
        uint expected_eth_amount = exchange.getEthAmount(swap_amount_token);
        exchange.tokenToETHSwap(swap_amount_token,expected_eth_amount);
        uint current_eth_balance = address(user1).balance;
        assert(
            current_eth_balance >= eth_balance_before + expected_eth_amount
        );
        vm.stopPrank();
    }
}
