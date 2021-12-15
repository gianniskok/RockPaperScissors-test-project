//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 totalSupply;
    address payable owner;

    constructor(uint256 _totalSupply)ERC20("RPStoken", "RPS"){
        totalSupply = _totalSupply;
        owner = payable(msg.sender);
        _mint(msg.sender, _totalSupply);
    }

    function setAproveInitialize(address _conAdd) external {
        require(msg.sender == owner);
        _approve(owner, _conAdd, totalSupply);
    }
}