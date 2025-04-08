// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @title Address Library
 * @dev This library provides utility functions for handling Ethereum addresses
 * 
 * External Contract Dependencies:
 * - None - This is a standalone utility library
 * 
 * Internal Interactions:
 * - Makes low-level calls to other contracts using call(), staticcall(), and delegatecall()
 * - Interacts with contract bytecode through address.code.length
 */
library Address {
    /**
     * @dev Determines if an address belongs to a contract
     * @param targetAddress The address to check
     * @return bool Returns true if the address contains contract code
     * 
     * WARNING: This function can return false negatives for contracts under construction
     * or contracts that have been destroyed
     */
    function isContract(address targetAddress) internal view returns (bool) {
        return targetAddress.code.length > 0;
    }

    /**
     * @dev Safely sends Ether to an address
     * @param recipientAddress The address to send Ether to
     * @param etherAmount The amount of Ether to send (in wei)
     * 
     * This function is safer than using transfer() as it:
     * - Forwards all available gas
     * - Doesn't fail on high gas costs
     */
    function sendValue(address payable recipientAddress, uint256 etherAmount) internal {
        require(
            address(this).balance >= etherAmount,
            "Address: insufficient balance"
        );

        (bool transferSuccess, ) = recipientAddress.call{value: etherAmount}("");
        require(
            transferSuccess,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Makes a function call to another contract (simplified version)
     * @param targetContract Address of the contract to call
     * @param encodedData The call data (encoded function signature and parameters)
     * @return bytes The return data from the function call
     */
    function functionCall(address targetContract, bytes memory encodedData)
        internal
        returns (bytes memory)
    {
        return functionCall(
            targetContract, 
            encodedData, 
            "Address: low-level call failed"
        );
    }

    /**
     * @dev Makes a function call to another contract with custom error message
     * @param targetContract Address of the contract to call
     * @param encodedData The call data (encoded function signature and parameters)
     * @param errorMessage Custom error message on failure
     * @return bytes The return data from the function call
     */
    function functionCall(
        address targetContract,
        bytes memory encodedData,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(targetContract, encodedData, 0, errorMessage);
    }

    /**
     * @dev Makes a function call with value transfer (simplified version)
     * @param targetContract Address of the contract to call
     * @param encodedData The call data
     * @param transferAmount Amount of ETH to send with the call
     * @return bytes The return data from the function call
     */
    function functionCallWithValue(
        address targetContract,
        bytes memory encodedData,
        uint256 transferAmount
    ) internal returns (bytes memory) {
        return functionCallWithValue(
            targetContract,
            encodedData,
            transferAmount,
            "Address: low-level call with value failed"
        );
    }

    /**
     * @dev Makes a function call with value transfer and custom error message
     * @param targetContract Address of the contract to call
     * @param encodedData The call data
     * @param transferAmount Amount of ETH to send with the call
     * @param errorMessage Custom error message on failure
     * @return bytes The return data from the function call
     */
    function functionCallWithValue(
        address targetContract,
        bytes memory encodedData,
        uint256 transferAmount,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= transferAmount,
            "Address: insufficient balance for call"
        );
        require(isContract(targetContract), "Address: call to non-contract");

        (bool callSuccess, bytes memory returnData) = targetContract.call{value: transferAmount}(
            encodedData
        );
        return verifyCallResult(callSuccess, returnData, errorMessage);
    }

    /**
     * @dev Makes a static function call (read-only, no state changes)
     * @param targetContract Address of the contract to call
     * @param encodedData The call data
     * @return bytes The return data from the function call
     */
    function functionStaticCall(address targetContract, bytes memory encodedData)
        internal
        view
        returns (bytes memory)
    {
        return functionStaticCall(
            targetContract,
            encodedData,
            "Address: low-level static call failed"
        );
    }

    /**
     * @dev Makes a static function call with custom error message
     * @param targetContract Address of the contract to call
     * @param encodedData The call data
     * @param errorMessage Custom error message on failure
     * @return bytes The return data from the function call
     */
    function functionStaticCall(
        address targetContract,
        bytes memory encodedData,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(targetContract), "Address: static call to non-contract");

        (bool callSuccess, bytes memory returnData) = targetContract.staticcall(encodedData);
        return verifyCallResult(callSuccess, returnData, errorMessage);
    }

    /**
     * @dev Makes a delegate call (executes code in the context of the caller)
     * @param targetContract Address of the contract to delegate call to
     * @param encodedData The call data
     * @return bytes The return data from the function call
     */
    function functionDelegateCall(address targetContract, bytes memory encodedData)
        internal
        returns (bytes memory)
    {
        return functionDelegateCall(
            targetContract,
            encodedData,
            "Address: low-level delegate call failed"
        );
    }

    /**
     * @dev Makes a delegate call with custom error message
     * @param targetContract Address of the contract to delegate call to
     * @param encodedData The call data
     * @param errorMessage Custom error message on failure
     * @return bytes The return data from the function call
     */
    function functionDelegateCall(
        address targetContract,
        bytes memory encodedData,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(targetContract), "Address: delegate call to non-contract");

        (bool callSuccess, bytes memory returnData) = targetContract.delegatecall(encodedData);
        return verifyCallResult(callSuccess, returnData, errorMessage);
    }

    /**
     * @dev Verifies the result of a function call and handles the return data
     * @param callSuccess Whether the call was successful
     * @param returnData Data returned from the call
     * @param errorMessage Message to show if call failed
     * @return bytes The verified return data
     */
    function verifyCallResult(
        bool callSuccess,
        bytes memory returnData,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (callSuccess) {
            return returnData;
        } else {
            // Look for revert reason and bubble it up if present
            if (returnData.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returnDataSize := mload(returnData)
                    revert(add(32, returnData), returnDataSize)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
