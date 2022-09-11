// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/Drop.sol";
import "./lib/AlbumMetadata.sol";
import "./lib/LiquidSplits/LiquidSplit.sol";
import "./lib/TheMerge.sol";

contract MERGE is AlbumMetadata, Drop, LiquidSplit, TheMerge {
    /// @notice total difficulty when ethereum transitions to proof-of-stake
    uint256 immutable MERGE_TTD = 58750000000000000000000;

    constructor(
        uint64 _publicSaleStart,
        string[] memory _musicMetadata,
        address _coreDevs,
        address _songaDAO,
        address _nftContractAddress,
        uint32[] memory _tokenIds
    )
        Drop("The Merge", "SAD", _publicSaleStart)
        LiquidSplit(_coreDevs, _songaDAO, _nftContractAddress, _tokenIds)
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

    /// @notice updates price & end time for first proof-of-work purchase.
    function _checkIfMerged() internal {
        if (merged()) {
            uint256 preMergePrice = MERGE_TTD / 1000000;
            bool isFirstProofOfWorkPurchase = (singlePrice == preMergePrice);
            if (isFirstProofOfWorkPurchase) {
                _activatePostMerge();
            }
        }
    }
}
