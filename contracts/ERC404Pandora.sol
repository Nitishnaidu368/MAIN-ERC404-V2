//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC404.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Pandora is ERC404 {
    // string public dataURI;
    // string public baseTokenURI;
    // string private GateWay;

    // constructor(
    //     address _owner
    // ) ERC404("Shrish", "SRS", 18, 10000, _owner) {
    //     setWhitelist(_owner, true);
    //     balanceOf[_owner] = 10000 * 10 ** 18;
    // }

    // function setDataURI(string memory _dataURI) public onlyOwner {
    //     dataURI = _dataURI;
    // }

    // function setTokenURI(string memory _tokenURI) public onlyOwner {
    //     baseTokenURI = _tokenURI;
    // }

    // function setGateway(string memory _gateway) public onlyOwner {
    //     GateWay = _gateway;
    // }

    // function tokenURI(uint256 id) public view override returns (string memory) {
    //     return bytes(baseTokenURI).length > 0 ? 
    //         string.concat(baseTokenURI,
    //             string.concat(
    //                     Strings.toString(id),
    //                     string.concat(".json/", GateWay)
    //                         )
    //                     ) : "";
    // }

    // function setNameSymbol(
    //     string memory _name,
    //     string memory _symbol
    // ) public onlyOwner {
    //     _setNameSymbol(_name, _symbol);
    // }


    string public baseTokenURI;
    uint256 public buyLimit;
    uint256 public sellLimit;
    uint256 public txLimit;
    mapping (address => uint256) public userBuylimit;
    mapping (address => uint256) public userSelllimit;
    using Strings for uint256;
    bool public applyTxLimit;

    constructor(
        address _owner,
        uint256 _initialSupply,
        uint8 _decimal,
        uint256 _buylimit,
        uint256 _selllimit
    ) ERC404("DeFrogs", "DEFROGS", _decimal, _initialSupply, _owner) {
        balanceOf[_owner] = _initialSupply * 10 ** _decimal;
        buyLimit = _buylimit * 10 ** _decimal;
        sellLimit = _selllimit * 10 ** _decimal;
        txLimit = 10 * 10 ** _decimal;
    }

    function setLimit(uint256 _buylimit, uint256 _selllimit) public onlyOwner{
        buyLimit = _buylimit;
        sellLimit = _selllimit;
    }

    function _mint(
        address to
    ) internal override{
        return super._mint(to);
    }

    function startApplyingLimit() external onlyOwner{
        applyTxLimit = true;
    }

    function stopApplyingLimit() external onlyOwner{
        applyTxLimit = false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual returns (bool){
        if(applyTxLimit){
            require(amount < txLimit, "exceed tx limit");
        }
        if(!whitelist[from]){
            userSelllimit[from] += amount;
            require(userSelllimit[from] <= sellLimit, "not allowed anymore to sell");
        }
        if(!whitelist[to]){
            userBuylimit[to] += amount;
            require(userBuylimit[to] <= buyLimit, "not allowed anymore to buy");
        }
        return super._transfer(from, to, amount);
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function setNameSymbol(
        string memory _name,
        string memory _symbol
    ) public onlyOwner {
        _setNameSymbol(_name, _symbol);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return bytes(baseTokenURI).length > 0 ? string.concat(baseTokenURI, id.toString(), ".json") : "";
    }

}