// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.28;

import "./ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account. The EIP is https://eips.ethereum.org/EIPS/eip-721[ERC721].
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) // This function is used to check if a contract supports a certain interface.
        public
        view
        virtual
        override(IERC165, ERC721) // Overrides the supportsInterface function in the ERC721 contract. Needed because we are inheriting from two contracts that have the same function.
        returns (bool)
    {
        return
            interfaceId == type(IERC721Enumerable).interfaceId || // Returns true if the interfaceId is equal to the interfaceId of the IERC721Enumerable interface.
            super.supportsInterface(interfaceId); // Returns true if the parent contract supports the interface that is being checked.
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) // This function references the "tokenOfOwnerByIndex" function in the IERC721Enumerable interface and takes in it's parameters.
        public
        view
        virtual
        override
        returns (uint256) // Returns the token ID as a uint256 value.
    {
        require(
            index < ERC721.balanceOf(owner), // Requires that the index is less than the number of tokens owned by the owner.
            "ERC721Enumerable: owner index out of bounds"
        );
        return _ownedTokens[owner][index]; // Returns the token ID at the index provided.
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) { // This function references the "totalSupply" function in the IERC721Enumerable interface that comes from the IERC721Enumerable.sol file.
        return _allTokens.length; // Returns the total number of tokens as a uint256 value.
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) // This function references the "tokenByIndex" function in the IERC721Enumerable interface.
        public
        view
        virtual
        override
        returns (uint256) // Returns the token ID as a uint256 value.
    {
        require(
            index < ERC721Enumerable.totalSupply(), // Requires that the index is less than the total number of tokens.
            "ERC721Enumerable: global index out of bounds" // Reverts the transaction if the index is out of bounds with this message.
        );
        return _allTokens[index]; // Returns the token ID at the index provided. "index" in this case comes from the "tokenOfOwnerByIndex" function.
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer( // This function overrides the "_beforeTokenTransfer" function in the ERC721 contract. It needs to be here because we are inheriting from the ERC721 contract.
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId); // Calls the "_beforeTokenTransfer" function in the ERC721 contract and uses "super" to call the parent contract's function.

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId); // if the token is being minted, then add it to the allTokens array.
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId); // if the token is being transferred, then remove it from the from address's owned tokens array.
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId); // if the token is being burned, then remove it from the allTokens array.
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId); // if the token is being transferred, then add it to the to address's owned tokens array.
        } // There are two if statments here because these operations can happen at the same time. For example, a token can be minted and transferred to another address at the same time.
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private { // This function adds a token to the "to" address's owned tokens array.
        uint256 length = ERC721.balanceOf(to); // Declares the variable "length" to be the number of tokens owned by the "to" address.
        _ownedTokens[to][length] = tokenId; // Adds the token ID to the "to" address's owned tokens array at the index of the number of tokens owned by the "to" address.
        _ownedTokensIndex[tokenId] = length; // Sets the length of the "to" address's owned tokens array to the token ID length.
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private { // This function adds a token to the allTokens array.
        _allTokensIndex[tokenId] = _allTokens.length; // Sets the allTokensIndex array "tokenId" to the length of the allTokens array. The way it keeps a tally of the minted tokens. 
        _allTokens.push(tokenId); // Adds the token ID to the allTokens array. ".push()" adds the token ID to the end of the array.
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) // This function removes a token from the "from" address's owned tokens array.
        private
    {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1; 
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) { // If the token to delete is not the last token, then we need to swap the last token with the token to delete.
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex]; // Gets the last token ID from the "from" address's owned tokens array.

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the empty array slot to avoid a gap in the array. This is called the "swap and pop" technique.
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId]; // Deletes the token ID from the "from" address's owned tokens array.
        delete _ownedTokens[from][lastTokenIndex]; // Deletes the last token ID from the "from" address's owned tokens array.
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1; // Gets the index of the last token in the allTokens array.
        uint256 tokenIndex = _allTokensIndex[tokenId]; // Gets the index of the token to delete in the allTokens array.

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex]; // Gets the last token ID from the allTokens array.

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        // TokenID is like a serial number and token index is the place it is in the array. The TokenID follows the token as it moves around.

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId]; // Deletes the token ID of the token to delete from the allTokensIndex array.
        _allTokens.pop(); // Deletes the last token ID from the allTokens array if the token to delete is the last token.
    }
}
