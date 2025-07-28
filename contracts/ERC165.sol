// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.28;

import "./IERC165.sol"; // imports the IERC165 interface from the IERC165.sol file. This file comes from the OpenZeppelin library. We know that because we have the OpenZeppelin library installed in our project.

abstract contract ERC165 is IERC165 { // This contract is called "abstract" because it's meant to be inherited by other contracts. It's not meant to be deployed on chain alone. ERC165 and IERC165 are the same thing. ERC165 is the contract and IERC165 is the interface.

    function supportsInterface(bytes4 interfaceId) // This function is used to check if a contract supports a certain interface. 
        public // "public" means that this function can be called from outside this contract.
        view   // "view" means that this function does not modify any state variables.
        virtual // "virtual" means that this function can be overridden by a child contract.
        override // "override" means that this function is overriding a function in the parent contract. It might be used to override a function in the IERC165 interface just in case the interface changes in the future.
        returns (bool) // returns a boolean value. In this case, it returns true if the contract supports the interface.
    {
        return interfaceId == type(IERC165).interfaceId; // Returns true if the interfaceId is equal to the interfaceId of the IERC165 interface.
    }
}

/*
How ERC165 Works
The ERC165 contract you have is an interface detection standard. It's designed to be inherited by other contracts to declare what interfaces they support.

Current Implementation
This contract only returns true for the ERC165 interface itself:

return interfaceId == type(IERC165).interfaceId;


solidity
How It Works with ERC721
To make this work with ERC721, you would typically override the supportsInterface function in your ERC721 contract like this:

function supportsInterface(bytes4 interfaceId) 
    public 
    view 
    virtual 
    override 
    returns (bool) 
{
    return interfaceId == type(IERC721).interfaceId || 
           super.supportsInterface(interfaceId);
}


The Pattern
ERC165 provides the base interface detection mechanism

ERC721 (and other standards) inherit from ERC165

Each standard overrides supportsInterface to declare support for their specific interface

The super.supportsInterface(interfaceId) call ensures the chain continues up to check for ERC165 support

Why This Matters
External contracts and marketplaces can call supportsInterface() to check:

"Does this contract support ERC721?" → NFT functionality

"Does this contract support ERC165?" → Interface detection capability

So your ERC165 contract is the foundation that enables ERC721 and other standards to declare their capabilities in a standardized way.
*/