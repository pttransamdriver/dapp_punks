// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.28;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory); // Returns the name of the token as a string value to the caller. The caller can be any user or contract.
    // This function is important for the front end to display the name of the token.
    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory); // Returns the symbol of the token as a string value to the caller. The caller can be any user or contract.
    // This function is important for the front end to display the symbol of the token.
    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory); // Returns the URI of the token as a string value to the caller. The caller can be any user or contract.
    // This function is important for the front end to display the URI of the image of the token.
}
