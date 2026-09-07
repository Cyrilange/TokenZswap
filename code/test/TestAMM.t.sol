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

    function testAddLiquiditySecondDeposit() public {
        uint256 firstAmountA = 1_000 ether;
        uint256 firstAmountB = 1_000 ether;

        uint256 secondAmountA = 100 ether;
        uint256 secondAmountB = 100 ether;

        address bob = makeAddr("bob");

        // Alice = this test contract.
        tokenA.approve(address(amm), firstAmountA);
        tokenB.approve(address(amm), firstAmountB);

        amm.addLiquidity(firstAmountA, firstAmountB);

        // Give Bob enough tokens for his deposit.
        tokenA.transfer(bob, secondAmountA);
        tokenB.transfer(bob, secondAmountB);

        // Bob approves the AMM.
        vm.startPrank(bob);

        tokenA.approve(address(amm), secondAmountA);
        tokenB.approve(address(amm), secondAmountB);

        // Bob adds liquidity.
        amm.addLiquidity(secondAmountA, secondAmountB);

        vm.stopPrank();

        // Pool should now contain 1100 of each token.
        assertEq(amm.reserveA(), 1_100 ether);
        assertEq(amm.reserveB(), 1_100 ether);

        // Alice owns 1000 LP.
        assertEq(
            amm.lpToken().balanceOf(address(this)),
            1_000 ether
        );

        // Bob owns 100 LP.
        assertEq(
            amm.lpToken().balanceOf(bob),
            100 ether
        );

        // Total LP supply should be 1100.
        assertEq(
            amm.lpToken().totalSupply(),
            1_100 ether
        );
    }

    function testAddLiquidityRevertsWithInvalidRatio() public {
        uint256 firstAmountA = 1_000 ether;
        uint256 firstAmountB = 1_000 ether;

        uint256 secondAmountA = 100 ether;
        uint256 secondAmountB = 50 ether;

        // Initialize the pool.
        tokenA.approve(address(amm), firstAmountA);
        tokenB.approve(address(amm), firstAmountB);

        amm.addLiquidity(firstAmountA, firstAmountB);

        // Give the user enough tokens.
        address bob = makeAddr("bob");

        tokenA.transfer(bob, secondAmountA);
        tokenB.transfer(bob, secondAmountB);

        vm.startPrank(bob);

        tokenA.approve(address(amm), secondAmountA);
        tokenB.approve(address(amm), secondAmountB);

        // 100 TKA / 50 TKB does not match the pool ratio 1:1.
        vm.expectRevert("Invalid token ratio");
        amm.addLiquidity(secondAmountA, secondAmountB);

        vm.stopPrank();
    }

    function testRemoveLiquidity() public {
        uint256 amountA = 1_000 ether;
        uint256 amountB = 1_000 ether;

        // Add the initial liquidity.
        tokenA.approve(address(amm), amountA);
        tokenB.approve(address(amm), amountB);

        amm.addLiquidity(amountA, amountB);

        // Alice owns 1000 LP tokens.
        assertEq(
            amm.lpToken().balanceOf(address(this)),
            1_000 ether
        );

        // Remove half of the liquidity.
        uint256 liquidityToRemove = 500 ether;

        uint256 balanceABefore = tokenA.balanceOf(address(this));
        uint256 balanceBBefore = tokenB.balanceOf(address(this));

        amm.removeLiquidity(liquidityToRemove);

        // Alice should receive half of each reserve.
        assertEq(
            tokenA.balanceOf(address(this)),
            balanceABefore + 500 ether
        );

        assertEq(
            tokenB.balanceOf(address(this)),
            balanceBBefore + 500 ether
        );

        // Alice should now have 500 LP tokens remaining.
        assertEq(
            amm.lpToken().balanceOf(address(this)),
            500 ether
        );

        // The pool should contain the remaining liquidity.
        assertEq(amm.reserveA(), 500 ether);
        assertEq(amm.reserveB(), 500 ether);

        // Total LP supply should also be 500.
        assertEq(
            amm.lpToken().totalSupply(),
            500 ether
        );
    }

    /*

    to check the swap :

    create a pool 1000 TKA / 1000 TKB
    give  TKA to Bob
    Bob approuve AMM
    Bob exchange 100 TKA
    check how many  TKB he received
    check reserves
    check  LP tokens are not modify
    */

    function testSwapAForB() public {

        // create a pool 1000 TKA / 1000 TKB
        
        //   give  TKA to Bob
        //   Bob approuve AMM
        //   Bob exchange 100 TKA
        //   check how many  TKB he received
        //  check reserves
        //   check  LP tokens are not modify
        
    }
}