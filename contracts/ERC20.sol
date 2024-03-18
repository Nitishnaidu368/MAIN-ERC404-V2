// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract Tether is ERC20 {
  constructor() ERC20("Shrish", "SRS") {}
  function mint(address to, uint256 amount) public {
    _mint(to, amount);
  }
}