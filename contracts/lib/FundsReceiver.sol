// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FundsReceiver {
    /// @notice recipient of funds from primary sale.
    address payable public liquidSplit;

    /// @notice event for funds received.
    event FundsReceived(address indexed source, uint256 amount);

    constructor(address payable _liquidSplit) {
        liquidSplit = _liquidSplit;
    }

    /// @notice receive ETH
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    /// @notice receive ERC-20 tokens
    fallback() external payable {}

    /// @notice withdraw balance of ETH & activate liquid split
    function withdraw() public {
        liquidSplit.transfer(address(this).balance);
    }

    /// @notice withdraw balance of ERC20 token & activate liquid split
    function withdrawToken(address _tokenContract) external {
        IERC20 tokenContract = IERC20(_tokenContract);
        
        tokenContract.transfer(liquidSplit, tokenContract.balanceOf(address(this)));
    }
}
