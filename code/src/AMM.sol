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

    uint256 public constant FEE_PERCENT = 3;  //fee will be 3%
    uint256 public constant FEE_DENOMINATOR = 100;

    constructor(address _tokenA, address _tokenB) {
        //A and B must be different , both must be different from the address 0
		require(_tokenA != address(0), "Invalid token A");
    	require(_tokenB != address(0), "Invalid token B");
    	require(_tokenA != _tokenB, "Tokens must be different");

        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        lpToken = new LPToken(address(this));
    }

    function _sqrt(uint256 y) internal pure returns (uint256 z) { //pure because does not modify yhe state of the blockchain and does not read avariable
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
            "Token A transfer failed"       );

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

    function removeLiquidity(uint256 liquidity) external {
        // A and B must be greater than 0 
        require(liquidity > 0, "Liquidity A must be greater than zero");

        uint256 totalLiquidity = lpToken.totalSupply();
        require(totalLiquidity > 0, "Liquidity A must be greater than zero in the pool");

        // Calculate the user's share of the pool.
        uint256 amountA = (liquidity * reserveA) / totalLiquidity;
        uint256 amountB = (liquidity * reserveB) / totalLiquidity;

        require(amountA > 0, "Insufficient Token A amount");
        require(amountB > 0, "Insufficient Token B amount");

        // Burn the user's LP tokens.
        lpToken.burn(msg.sender, liquidity);

        // Update the pool reserves.
        reserveA -= amountA;
        reserveB -= amountB;

        // Send Token A back to the liquidity provider.
        require(
            tokenA.transfer(msg.sender, amountA),
            "Token A transfer failed"
        );

        // Send Token B back to the liquidity provider.
        require(
            tokenB.transfer(msg.sender, amountB),
            "Token B transfer failed"
        );

    }

    function swapAForB(uint256 amountAIn) external returns (uint256 amountBOut) {
    require(amountAIn > 0, "Amount A must be greater than zero");
    require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

    // Calculate the amount of Token A used after the 3% fee.
    uint256 amountAInWithFee = amountAIn * (FEE_DENOMINATOR - FEE_PERCENT)/ FEE_DENOMINATOR;

    // Constant-product formula:
    // amountBOut = (amountAInWithFee * reserveB)
    //              / (reserveA + amountAInWithFee)
    amountBOut =
        (amountAInWithFee * reserveB)
        / (reserveA + amountAInWithFee);

    require(amountBOut > 0, "Insufficient output amount");
    require(amountBOut < reserveB, "Insufficient Token B liquidity");

    // Transfer Token A from the user to the AMM.
    require(
        tokenA.transferFrom(msg.sender, address(this), amountAIn),
        "Token A transfer failed"
    );

    // Update reserves.
    reserveA += amountAIn;
    reserveB -= amountBOut;

    // Send Token B to the user.
    require(
        tokenB.transfer(msg.sender, amountBOut),
        "Token B transfer failed"
    );
}

    function swapBForA(uint256 amountBIn) external returns (uint256 amountAOut){
        require(amountBIn > 0, "Amount B must be greater than zero");
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Calculate the amount of Token B used after the 3% fee.
        uint256 amountBInWithFee = amountBIn * (FEE_DENOMINATOR - FEE_PERCENT) / FEE_DENOMINATOR;

        // Constant-product formula:
        // amountAOut = (amountBInWithFee * reserveA)
        //              / (reserveB + amountBInWithFee)
        amountAOut = (amountBInWithFee * reserveA) / (reserveB + amountBInWithFee);

        require(amountAOut > 0, "Insufficient output amount");
        require(amountAOut < reserveA, "Insufficient Token A liquidity");

        // Transfer Token B from the user to the AMM.
        require(
            tokenB.transferFrom(msg.sender, address(this), amountBIn),
            "Token B transfer failed"
        );

        // Update reserves.
        reserveB += amountBIn;
        reserveA -= amountAOut;

        // Send Token A to the user.
        require(
            tokenA.transfer(msg.sender, amountAOut),
            "Token A transfer failed"
        );
    }

}
