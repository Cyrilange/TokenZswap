// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {AMM} from "../src/AMM.sol";
import {TestTokenA} from "../src/TestTokenA.sol";
import {TestTokenB} from "../src/TestTokenB.sol";

contract TestAMM is Test {
    AMM amm;
    TestTokenA tokenA;
    TestTokenB tokenB;

	function setUp() public {
		uint256 initialSupply = 1_000_000 ether;

		tokenA = new TestTokenA(initialSupply);
		tokenB = new TestTokenB(initialSupply);

		amm = new AMM(address(tokenA), address(tokenB));
	}

    function testTokens() public view{
        assertEq(address(amm.tokenA()), address(tokenA));
        assertEq(address(amm.tokenB()), address(tokenB));
    }
}