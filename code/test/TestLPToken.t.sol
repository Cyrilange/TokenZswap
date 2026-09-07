// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {LPToken} from "../src/LPToken.sol";

contract TestLPToken is Test {
    LPToken lpToken;

    address amm;
    address alice;

    function setUp() public {
        amm = makeAddr("amm");
        alice = makeAddr("alice");

        lpToken = new LPToken(amm);
    }

    // Verify the right AMM is registered
    function testAMMAddress() public view {
        assertEq(lpToken.AMM(), amm);
    }

    // Verify only the AMM can create LP tokens
    function testMintOnlyAMM() public {
        vm.prank(amm);

        lpToken.mint(alice, 100 ether);

        assertEq(lpToken.balanceOf(alice), 100 ether);
        assertEq(lpToken.totalSupply(), 100 ether);
    }

    // Verify a normal user cannot create LP tokens
    function testMintRevertsIfNotAMM() public {
        vm.prank(alice);

        vm.expectRevert("Only AMM");
        lpToken.mint(alice, 100 ether);
    }

    // Verify the AMM can destroy LP tokens
    function testBurnOnlyAMM() public {
        vm.prank(amm);
        lpToken.mint(alice, 100 ether);

        vm.prank(amm);
        lpToken.burn(alice, 40 ether);

        assertEq(lpToken.balanceOf(alice), 60 ether);
        assertEq(lpToken.totalSupply(), 60 ether);
    }
}