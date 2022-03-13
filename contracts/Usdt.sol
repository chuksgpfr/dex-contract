// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
  constructor() ERC20("USD Tether", "USDT") {}

  function faucet(address to, uint amount) external {
    _mint(to, amount);
  }
}