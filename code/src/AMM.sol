// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LPToken} from "./LPToken.sol";

contract AMM {
    IERC20 public tokenA;
    IERC20 public tokenB;
    LPToken public lpToken;

	uint256 public reserveA;
	 uint256 public reserveB;

    constructor(address _tokenA, address _tokenB) {
        //A and B must be different , both must be different from the address 0
		require(_tokenA != address(0), "Invalid token A");
    	require(_tokenB != address(0), "Invalid token B");
    	require(_tokenA != _tokenB, "Tokens must be different");

        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        lpToken = new LPToken(address(this));
    }

    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;

            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
      
    function addLiquidity( uint256 amountA, uint256 amountB ) external {
        // A and B must be greater than 0 
        require(amountA > 0, "Amount A must be greater than zero");
        require(amountB > 0, "Amount B must be greater than zero");

        uint256 liquidity;

        // First liquidity provider.
        if (reserveA == 0 && reserveB == 0) {
            liquidity = _sqrt(amountA * amountB);
        } else {
            // The deposit must respect the current pool ratio.
            require(
                amountA * reserveB == amountB * reserveA,
                "Invalid token ratio"
            );

            // Calculate LP tokens according to the provider's share.
            liquidity =
                (amountA * lpToken.totalSupply()) /
                reserveA;
        }

        require(liquidity > 0, "Insufficient liquidity");

        // Transfer Token A from the liquidity provider to the AMM.
        require(
            tokenA.transferFrom(msg.sender, address(this), amountA),
            "Token A transfer failed"
        );

        // Transfer Token B from the liquidity provider to the AMM.
        require(
            tokenB.transferFrom(msg.sender, address(this), amountB),
            "Token B transfer failed"
        );

        // Update the pool reserves.
        reserveA += amountA;
        reserveB += amountB;

        // Mint LP tokens for the liquidity provider.
        lpToken.mint(msg.sender, liquidity);
    }

}