// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.28;

abstract contract Context { // "abstract" means that this contract can't be deployed on chain alone. It's meant to be inherited by other contracts.
    function _msgSender() internal view virtual returns (address) { // "internal" means that this function can only be called from within this contract or contracts that inherit from it.
        return msg.sender; // Returns the address of the account that sent the transaction to this contract.
    }

    function _msgData() internal view virtual returns (bytes calldata) { // The purpose of _msgData() is to provide a way for contracts to access the data sent with a transaction. "calldata" is a bytes data location that is used for function arguments.
        return msg.data; // Returns "msg.data" which is the data sent with the transaction to this contract.
    }
}
