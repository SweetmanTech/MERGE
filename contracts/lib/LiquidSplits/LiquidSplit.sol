// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./lib/SplitHelpers.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidSplit is SplitHelpers {
    constructor(
        address _coreDevs,
        address _songaDAO,
        address _nftContractAddress,
        uint32[] memory _tokenIds
    ) SplitHelpers(_coreDevs, _songaDAO, _nftContractAddress, _tokenIds) {}

    /// @notice This allows this contract to receive native currency funds from other contracts
    /// Uses event logging for UI reasons.
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    /// @notice distributes ETH to Liquid Split NFT holders
    function withdraw() external {
        (
            address[] memory recipients,
            uint32[] memory percentAllocations
        ) = getRecipientsAndAllocations();
        // atomically deposit funds into split, update recipients to reflect current supercharged NFT holders,
        // and distribute
        payoutSplit.transfer(address(this).balance);
        splitMain.updateAndDistributeETH(
            payoutSplit,
            recipients,
            percentAllocations,
            0,
            address(0)
        );
    }

    /// @notice receive ERC-20 tokens
    fallback() external payable {}

    /// @notice withdraw balance of ERC20 token & activate liquid split
    function withdrawToken(address _tokenContract) external {
        IERC20 tokenContract = IERC20(_tokenContract);

        tokenContract.transfer(
            payoutSplit,
            tokenContract.balanceOf(address(this))
        );
    }
}
