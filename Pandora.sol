//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404} from "./ERC404.sol";
contract Pandora is Ownable, ERC404 {
    // string public dataURI;
    string private baseTokenURI;
    string private GateWay;
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 maxTotalSupplyERC721_,
        address initialOwner_
    )
        // address initialMintRecipient_
        ERC404(name_, symbol_, decimals_)
        Ownable(initialOwner_)
    {
        // Do not mint the ERC721s to the initial owner, as it's a waste of gas.
        _setERC721TransferExempt(initialOwner_, true);
        _mintERC20(initialOwner_, maxTotalSupplyERC721_ * units);
    }
   
    function setGateway(
        string memory _gateway,
        string memory _tokenURI
    ) public {
        GateWay = _gateway;
        baseTokenURI = _tokenURI;
    }
    function tokenURI(uint256 id) public view override returns (string memory) {
        uint256 tokenId = id - (1 << 255);
        return
            bytes(baseTokenURI).length > 0
                ? string.concat(
                    baseTokenURI,
                    string.concat(
                        Strings.toString(tokenId),
                        string.concat(".json/", GateWay)
                    )
                )
                : "";
    }
}
