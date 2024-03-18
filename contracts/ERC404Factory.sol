//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "./Pandora.sol";

contract ERC404Factory {
    function deployERC404(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 maxTotalSupplyERC721_
    ) public returns (address) {
        //Deploy collection Address
        Pandora ERC404Address = new Pandora(
            _name,
            _symbol,
            _decimals,
            maxTotalSupplyERC721_,
            msg.sender
        );
        address _ERC404Address = address(ERC404Address);
        // emit deployedAddress(address(ERC404Address), msg.sender);
        return address(_ERC404Address);
    }
}
