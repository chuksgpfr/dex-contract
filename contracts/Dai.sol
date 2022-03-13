// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract DAI is ERC20 {
  constructor() ERC20("Dai Stable Coin", "DAI") {}
  
  function faucet(address to, uint256 amount) external {
    _mint(to, amount);
  }
}