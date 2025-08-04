// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.28;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received( // This function takes 4 parameters. Operator, from, tokenId, and data. 
        address operator, // The "operator" is the address that is transferring the token.
        address from, // The "from" is the address that is sending the token.
        uint256 tokenId, // The "tokenId" is the token that is being transferred.
        bytes calldata data // The "data" is any additional data that is being sent with the transfer.
    ) external returns (bytes4);
}
