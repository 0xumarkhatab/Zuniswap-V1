// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;

    function setUp() public {
        token = new Token("zuniswap token",'zuni',10e18*(10**18));
    }
    function test_getBalance()external{
        token.balanceOf(address(this));
    }
}


