// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {TestTokenA} from "../src/TestTokenA.sol";

contract TestTokenATest is Test {

    TestTokenA token;

    address alice;
    address bob;

	//this function set up all the test by  giving addresses and making the supply for the token

    function setUp() public {
		alice = makeAddr("alice");
    	bob = makeAddr("bob");
        token = new TestTokenA(1_000_000 ether);
    }


	//this function test the initial supply ( view because we dont alter the database)

	function testInitialSupply() public view{
		uint256 initialSupply = 1_000_000 ether;
		assertEq(token.totalSupply(), initialSupply);
    	assertEq(token.balanceOf(address(this)), initialSupply);
}

	//this function test if we can transfer the token

	function testTransfer() public {
		uint256 amount = 100 ether;

		assertTrue(token.transfer(alice, amount));

		assertEq(token.balanceOf(alice), amount);
		assertEq(
			token.balanceOf(address(this)),
			1_000_000 ether - amount
		);
	}

	//this function test that alice can transfer tokens to bob

	function aliceTesttransfertToBob() public  {
		uint256 amount = 250 ether;
		assertTrue(token.transfer(alice, amount));
		vm.prank(alice);
		assertTrue(token.transfer(bob, amount));
		assertEq(token.balanceOf(alice), 0);
    	assertEq(token.balanceOf(bob), amount);
	}

	//this function test if alice can approve an amount to transfer at bob

	function testApprove() public {
		uint256 amount = 125 ether;
		vm.prank(alice);
		assertTrue(token.approve(bob, amount));
		assertEq(token.allowance(alice, bob), amount);
	}

	//this function test if bob can spend the alice's token

	function testTransferFrom() public {
		uint256 amount = 125 ether;
		assertTrue(token.transfer(alice, amount));
		vm.prank(alice);
		token.approve(bob, amount);
		vm.prank(bob);
		assertTrue(token.transferFrom(alice, bob, amount));
		assertEq(token.balanceOf(alice), 0);
		assertEq(token.balanceOf(bob), amount);
	}

	//this function test if bob can spend the alice's token but willf ail because bob try to take bigger amount

	function testTransferFromExceedsAllowance() public {
		uint256 amount = 125 ether;

		assertTrue(token.transfer(alice, amount));

		vm.prank(alice);
		assertTrue(token.approve(bob, amount));

		vm.prank(bob);

		try token.transferFrom(alice, bob, 280 ether) returns (bool success) {
			assertFalse(success);
		} catch {
			// Expected: Bob is not allowed to spend 280 TKA
		}
	}
}