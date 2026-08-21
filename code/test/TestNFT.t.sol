// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {TestNFT} from "../src/TestNFT.sol";

contract TestNFTTest is Test {
    TestNFT nft;

    address owner = address(this);
    address alice = address(0x1);

    function setUp() public {
        nft = new TestNFT();
    }

    function testMint() public {
        nft.safeMint(alice, "ipfs://example");

        assertEq(nft.ownerOf(0), alice);
        assertEq(nft.tokenURI(0), "ipfs://example");
    }
}