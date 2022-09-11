// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/Drop.sol";
import "./lib/AlbumMetadata.sol";
import "./lib/FundsReceiver.sol";
import "./lib/TheMerge.sol";

contract MERGE is AlbumMetadata, Drop, FundsReceiver, TheMerge {
    /// @notice TTD of the Merge
    uint256 immutable MERGE_TTD = 58750000000000000000000;
    uint256 immutable START_TTD = 58650000000000000000000;

    constructor(
        uint64 _publicSaleStart,
        string[] memory _musicMetadata,
        address payable _liquidSplit
    )
        Drop("The Merge", "SAD", _publicSaleStart)
        FundsReceiver(_liquidSplit)
        AlbumMetadata(_musicMetadata)
    {
        singlePrice = MERGE_TTD / 1000000;
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function purchase(uint256 _quantity)
        external
        payable
        onlyPublicSaleActive
        onlyValidPrice(singlePrice, _quantity)
        returns (uint256)
    {
        _checkIfMerged();
        uint256 firstMintedTokenId = _purchase(_quantity);
        return firstMintedTokenId;
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function _purchase(uint256 quantity) internal returns (uint256) {
        uint256 start = _nextTokenId();
        _mint(msg.sender, quantity);

        emit Sale({
            to: msg.sender,
            quantity: quantity,
            pricePerToken: singlePrice,
            firstPurchasedTokenId: start
        });
        return start;
    }

    /// @notice Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        uint8 songId = currentSong();
        return songURI(songId);
    }

    /// @notice Runs update on price / end time for first purchase post-merge.
    function _checkIfMerged() internal {
        if (merged()) {
            uint256 preMergePrice = MERGE_TTD / 1000000;
            if (singlePrice == preMergePrice) {
                _activatePostMerge();
            }
        }
    }
}
