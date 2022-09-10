// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IDrop.sol";

contract Drop is ERC721A, IDrop, Ownable {
    /// @notice Price for Single
    uint256 singlePrice;
    /// @notice Public Sale Start Time
    uint64 public publicSaleStart = 0;
    /// @notice Public Sale End Time
    uint64 public publicSaleEnd = 1692974064;
    /// @notice Initial length of sale.
    uint64 HALF_LENGTH_OF_SALE = 60 * 60 * 24 * 2;
    uint64 LENGTH_OF_SALE = HALF_LENGTH_OF_SALE * 2;

    /// @notice Sale is inactive
    error Sale_Inactive();
    /// @notice Wrong price for purchase
    error Purchase_WrongPrice(uint256 correctPrice);

    constructor(
        string memory _name,
        string memory _symbol,
        uint64 _publicSaleStart
    ) ERC721A(_name, _symbol) Ownable() {
        publicSaleStart = _publicSaleStart;
        publicSaleEnd = _publicSaleStart + LENGTH_OF_SALE;
    }

    /// @notice Returns the starting token ID.
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    /// @notice Public sale active
    modifier onlyPublicSaleActive() {
        if (!_publicSaleActive()) {
            revert Sale_Inactive();
        }

        _;
    }

    /// @notice Public sale active
    modifier onlyValidPrice(uint256 _price, uint256 _quantity) {
        if (msg.value != _price * _quantity) {
            revert Purchase_WrongPrice(_price * _quantity);
        }

        _;
    }

    /// @notice Public sale active
    function _publicSaleActive() internal view returns (bool) {
        return
            publicSaleStart <= block.timestamp &&
            publicSaleEnd > block.timestamp;
    }

    /// @notice Sale details
    /// @return IERC721Drop.SaleDetails sale information details
    function saleDetails() external view returns (SaleDetails memory) {
        return
            SaleDetails({
                publicSaleActive: _publicSaleActive(),
                presaleActive: false,
                publicSalePrice: singlePrice,
                publicSaleStart: publicSaleStart,
                publicSaleEnd: publicSaleEnd,
                presaleStart: 0,
                presaleEnd: 0,
                presaleMerkleRoot: 0x0000000000000000000000000000000000000000000000000000000000000000,
                totalMinted: _totalMinted(),
                maxSupply: 1000000,
                maxSalePurchasePerAddress: 0
            });
    }

    /// @notice updates price / end time post-merge
    function _activatePostMerge() internal {
        _setPrice(block.number);
        _setPublicSaleEnd(uint64(block.timestamp) + HALF_LENGTH_OF_SALE);
    }

    /// @notice Used in case of special "MERGE" block number we want to set the price to.
    function setPrice(uint256 _newWeiPrice) external onlyOwner {
        _setPrice(_newWeiPrice);
    }

    /// @notice Updates Price.
    function _setPrice(uint256 _newWeiPrice) internal {
        singlePrice = _newWeiPrice;
    }

    /// @notice Used in case of unforseen delays in the merge requiring change to endTime.
    function setPublicSaleEnd(uint64 _publicSaleEnd)
        external
        onlyPublicSaleActive
        onlyOwner
    {
        _setPublicSaleEnd(_publicSaleEnd);
    }

    /// @notice Updates PublicSaleEnd.
    function _setPublicSaleEnd(uint64 _publicSaleEnd) internal {
        publicSaleEnd = _publicSaleEnd;
    }
}
