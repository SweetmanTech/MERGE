// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract AlbumMetadata {
    /// @notice mapping from songId to songMetadataURI
    string[] internal songURIs;

    constructor(string[] memory _trackList) {
        songURIs = _trackList;
    }

    /// @notice Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function songURI(uint8 _songId) public view returns (string memory) {
        return songURIs[_songId];
    }

    /// @notice Returns current song URI based on TheMergeTTD.
    function currentSong() public view returns (uint8) {
        return uint8(block.timestamp % songURIs.length);
    }
}
