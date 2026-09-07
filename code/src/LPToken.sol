// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    address public immutable AMM;

    constructor(address _amm)
        ERC20("TokenZswap LP Token", "TZLP")
    {
        require(_amm != address(0), "Invalid AMM address");
        AMM = _amm;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == AMM, "Only AMM");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(msg.sender == AMM, "Only AMM");
        _burn(from, amount);
    }
}