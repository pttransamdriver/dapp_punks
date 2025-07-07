// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.20;

// "Library" is a special kind of contract that contains only functions. It gets imbeded into the contract's bytcode at compile time and that's how it gets used on chain. It can't be deployed on chain alone.
library Address {

    // "internal" means that this "isContract" function can only be called from within this contract or contracts that inherit from it.
    function isContract(address targetAddress) internal view returns (bool) {
        return targetAddress.code.length > 0; // Returns bool true if the address contains contract code. Wallet addresses return false.
    }

    // This function is a "payable" function, which means it can receive Ether.
    function sendValue(address payable recipientAddress, uint256 etherAmount) internal {
        // This function requires that the caller has enough Ether to cover the transfer amount.
        require(
            address(this).balance >= etherAmount, // "address(this)" refers to the address of the contract that is calling this Library function.
            "Address: insufficient balance"
        );

        (bool transferSuccess, ) = recipientAddress.call{value: etherAmount}(""); // This is a low-level function to send Ether. It's used because it allows you to forward all available gas, which is important for security.
        require(
            transferSuccess, // "transferSuccess" is a boolean that indicates whether the transfer was successful.
            "Address: unable to send value, recipient may have reverted" // Message to indicate that the transfer failed. 
        );
    }

    function functionCall(address targetContract, bytes memory encodedData) // This function is used to call a function on another contract.
        internal // "internal" means that this function can only be called from within this contract or contracts that inherit from it.
        returns (bytes memory) // "returns (bytes memory)" means that this function returns a byte array.
    {
        return functionCall( // Returns the byte array returned from the function call.
            targetContract, // Address of the contract to call
            encodedData, // Encoded function call data
            "Address: low-level call failed" // Custom error message if the call fails
        );
    }

    function functionCall( // Three parameter version of functionCall.
        address targetContract,
        bytes memory encodedData,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(targetContract, encodedData, 0, errorMessage);
    }

    function functionCallWithValue( // Function that sends Ether to the target contract.
        address targetContract, // The contract to call
        bytes memory encodedData, // Encoded function call data from abi.encodeWithSignature()
        uint256 transferAmount // Amount of Ether to send
    ) internal returns (bytes memory) { // Returns the internal functionCallWithValue.
        return functionCallWithValue( // Returns the internal functionCallWithValue.
            targetContract, // Address of the contract to call
            encodedData,    // Encoded function call data
            transferAmount, // Amount of Ether to send
            "Address: low-level call with value failed" // Custom error message if the call fails
        );
    }

    function functionCallWithValue( // Four parameter version of functionCallWithValue.
        address targetContract, // The contract to call
        bytes memory encodedData, // Encoded function call data
        uint256 transferAmount, // Amount of Ether to send
        string memory errorMessage // Custom error message if the call fails
    ) internal returns (bytes memory) { // Returns the internal functionCallWithValue.
        require(
            address(this).balance >= transferAmount, // Requires that the caller has enough Ether to cover the transfer amount.
            "Address: insufficient balance for call"
        );
        require(isContract(targetContract), "Address: call to non-contract"); // Requires that the target address is a contract.

        (bool callSuccess, bytes memory returnData) = targetContract.call{value: transferAmount}( // Calls the target contract with the encoded function call data and the transfer amount.
            encodedData
        );
        return verifyCallResult(callSuccess, returnData, errorMessage); // Returns the internal verifyCallResult.
    }


    function functionStaticCall(address targetContract, bytes memory encodedData) // Function that calls a function on another contract without sending any Ether.
        internal // "internal" means that this function can only be called from within this contract or contracts that inherit from it.
        view // "view" means that this function does not modify any state variables.
        returns (bytes memory) // "returns (bytes memory)" means that this function returns a byte array.
    {
        return functionStaticCall( // Returns the internal functionStaticCall.
            targetContract, // Address of the contract to call
            encodedData,    // Encoded function call data
            "Address: low-level static call failed" // Custom error message if the call fails
        );
    }

    function functionStaticCall( // Three parameter version of functionStaticCall.
        address targetContract, // The contract to call
        bytes memory encodedData, // Encoded function call data
        string memory errorMessage // Custom error message if the call fails
    ) internal view returns (bytes memory) {
        require(isContract(targetContract), "Address: static call to non-contract"); // Requires that the target address is a contract.

        (bool callSuccess, bytes memory returnData) = targetContract.staticcall(encodedData);
        return verifyCallResult(callSuccess, returnData, errorMessage);
    }

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

    function functionDelegateCall(
        address targetContract,
        bytes memory encodedData,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(targetContract), "Address: delegate call to non-contract");

        (bool callSuccess, bytes memory returnData) = targetContract.delegatecall(encodedData);
        return verifyCallResult(callSuccess, returnData, errorMessage);
    }

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
