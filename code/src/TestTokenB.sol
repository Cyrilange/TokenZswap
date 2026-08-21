// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestTokenB is ERC20 {
    constructor(uint256 initialSupply) ERC20("Test Token B", "TKB") {
        _mint(msg.sender, initialSupply);
    }
}