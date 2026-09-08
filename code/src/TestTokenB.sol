// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestTokenB is ERC20 {
    uint256 public constant FAUCET_AMOUNT = 1000 ether;
    uint256 public constant FAUCET_COOLDOWN = 3 minutes;

    mapping(address => uint256) public lastFaucet;

    constructor(uint256 initialSupply) ERC20("Test Token B", "TKB") {
        _mint(msg.sender, initialSupply);
    }

    function faucet() external {
        require(
            block.timestamp >= lastFaucet[msg.sender] + FAUCET_COOLDOWN,
            "Faucet cooldown"
        );

        lastFaucet[msg.sender] = block.timestamp;
        _mint(msg.sender, FAUCET_AMOUNT);
    }
}