// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AMM {
    IERC20 public tokenA;
    IERC20 public tokenB;

	uint256 public reserveA;
	 uint256 public reserveB;

    constructor(address _tokenA, address _tokenB) {
		require(_tokenA != address(0), "Invalid token A");
    	require(_tokenB != address(0), "Invalid token B");
    	require(_tokenA != _tokenB, "Tokens must be different");

        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
}