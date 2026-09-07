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
    
    function testAddLiquidityFirstDeposit() public {
    uint256 amountA = 1_000 ether;
    uint256 amountB = 1_000 ether;

    // Give the AMM permission to take the tokens.
    tokenA.approve(address(amm), amountA);
    tokenB.approve(address(amm), amountB);

    // Add liquidity.
    amm.addLiquidity(amountA, amountB);

    // Check the pool reserves.
    assertEq(amm.reserveA(), amountA);
    assertEq(amm.reserveB(), amountB);

    // 1000 * 1000 = 1,000,000
    // sqrt(1,000,000) = 1000 LP tokens.
    assertEq(amm.lpToken().balanceOf(address(this)), 1_000 ether);

    // Check that the AMM actually received the tokens.
    assertEq(tokenA.balanceOf(address(amm)), amountA);
    assertEq(tokenB.balanceOf(address(amm)), amountB);
}
}