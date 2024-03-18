// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../ERC404Market.sol";
import "../Fee.sol";

library LibMarket {

    // function checkSale(ERC404Market.TokenMeta storage meta) external view {
    //     require(meta.status, "1");
    //     require(msg.sender != address(0) && msg.sender != meta.currentOwner, "2");
    //     require(!meta.bidSale, "3");
    //     if (meta.currency == address(0)) {
    //         require(msg.value == meta.price);
    //     } else {
    //         require(
    //             IERC20(meta.currency).balanceOf(msg.sender) >=
    //                 meta.price
    //         );
    //     }
    // }

    // function executeSale(
    //     ERC404Market.TokenMeta storage meta,
    //     address FeeAddress
    // ) external {
    //     // meta.status = false;
    //     // uint16 piMarketFee = Fee(FeeAddress).MarketFee();
    //     // address AconomyOwner = Fee(FeeAddress)
    //     //     .getOwnerAddress();

    //     // if (meta.currency == address(0)) {
    //     //     uint256 sum = msg.value;
            
    //     //     uint256 fee = (msg.value*piMarketFee)/10000;

    //     //     (bool isSuccess, ) = payable(meta.currentOwner).call{
    //     //         value: (sum - fee)
    //     //     }("");

    //     //     require(isSuccess, "Transfer failed");
    //     //     if(piMarketFee != 0) {
    //     //         (bool feeSuccess, ) = payable(AconomyOwner).call{value: fee}("");
    //     //         require(feeSuccess, "Fee Transfer failed");
    //     //     }
            
    //     // } else {
    //     //     uint256 sum = meta.price;
    //     //     uint256 fee = (meta.price * piMarketFee) / 10000;


    //     //     bool isSuccess = IERC20(meta.currency).transferFrom(
    //     //         msg.sender,
    //     //         meta.currentOwner,
    //     //         sum - fee
    //     //     );
    //     //     require(isSuccess, "Transfer failed");
    //     //     if(piMarketFee != 0) {
    //     //         (bool feeSuccess) = IERC20(meta.currency).transferFrom(
    //     //             msg.sender,
    //     //             AconomyOwner,
    //     //             fee
    //     //         );
    //     //         require(feeSuccess, "Fee Transfer failed");
    //     //     }
            
    //     // }
    // }

    function checkBid(
        ERC404Market.TokenMeta storage meta,
        uint256 amount
    ) external view {
        require(meta.currentOwner != msg.sender);
        require(meta.status);
        require(meta.bidSale);
        require(meta.price + ((5 * meta.price) / 100) <= amount);
        if (meta.currency != address(0)) {
            require(
                IERC20(meta.currency).balanceOf(msg.sender) >= amount
            );
        }
    }


    function executeBid(
        ERC404Market.TokenMeta storage meta,
        ERC404Market.BidOrder storage bids,
        address FeeAddress
    ) external {
        require(msg.sender == meta.currentOwner);
        require(!bids.withdrawn);
        require(meta.status);
        require(meta.bidSale);
        meta.status = false;
        meta.price = bids.price;
        bids.withdrawn = true;

        uint16 MarketFee = Fee(FeeAddress).MarketFee();
        address _Owner = Fee(FeeAddress)
            .getOwnerAddress();

        if (meta.currency == address(0)) {
            uint256 sum = bids.price;
            uint256 fee = (bids.price * MarketFee)/10000;

            (bool isSuccess, ) = payable(msg.sender).call{value: (sum - fee)}("");
            require(isSuccess, "Transfer failed");
            if(MarketFee != 0) {
                (bool feeSuccess, ) = payable(_Owner).call{value: fee}("");
                require(feeSuccess, "Fee Transfer failed");
            }
            
        } else {
            uint256 sum = bids.price;
            uint256 fee = (bids.price * MarketFee)/10000;

            bool isSuccess = IERC20(meta.currency).transfer(
                meta.currentOwner,
                sum - fee
            );
            require(isSuccess, "Transfer failed");
            if(MarketFee != 0) {
                (bool feeSuccess) = IERC20(meta.currency).transfer(
                    _Owner,
                    fee
                );
                require(feeSuccess, "Fee Transfer failed");
            }
            
        }
    }

    function withdrawBid(
        ERC404Market.TokenMeta storage meta,
        ERC404Market.BidOrder storage bids
    ) external {
        if(block.timestamp > meta.bidEndTime || !meta.status) {
            require(!bids.withdrawn);
            require(bids.buyerAddress == msg.sender);
        } else {
            require(meta.price != bids.price);
            require(bids.buyerAddress == msg.sender);
            require(!bids.withdrawn);
        }

        if (meta.currency == address(0)) {
            (bool success, ) = payable(msg.sender).call{value: bids.price}("");
            if (success) {
                bids.withdrawn = true;
            } else {
                revert("No Money left!");
            }
        } else {
            bool success = IERC20(meta.currency).transfer(
                msg.sender,
                bids.price
            );
            if (success) {
                bids.withdrawn = true;
            } else {
                revert("no Money left!");
            }
        }
    }

}