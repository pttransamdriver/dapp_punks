// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721Enumerable, Ownable, ReentrancyGuard, Pausable {
    using Strings for uint256;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost;
    uint256 public maxSupply;
    uint256 public allowMintingOn;
    uint256 public maxMintAmount = 10; // Maximum tokens per transaction
    
    // Security constants
    uint256 public constant MAX_COST = 100 ether; // Maximum cost protection
    bool public mintingPermanentlyDisabled = false; // Emergency stop


    event Mint(uint256 amount, address minter);
    event Withdraw(uint256 amount, address owner);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _cost,
        uint256 _maxSupply,
        uint256 _allowMintingOn,
        string memory _baseURI
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        cost = _cost;
        maxSupply = _maxSupply;
        allowMintingOn = _allowMintingOn;
        baseURI = _baseURI;
    }

    function mint(uint256 _mintAmount) public payable nonReentrant whenNotPaused {
        // Emergency stop check
        require(!mintingPermanentlyDisabled, "Minting permanently disabled");
        // Must mint at least 1 token
        require(_mintAmount > 0, "Must mint at least 1 token");
        // Check maximum mint amount per transaction
        require(_mintAmount <= maxMintAmount, "Exceeds maximum mint amount per transaction");
        // Only allow minting after specified time
        require(block.timestamp >= allowMintingOn, "Minting not allowed yet");
        // Require enough payment
        require(msg.value >= cost * _mintAmount, "Insufficient payment");

        uint256 supply = totalSupply();

        // Do not let them mint more tokens than available
        require(supply + _mintAmount <= maxSupply, "Exceeds maximum supply");
        // Overflow protection for token IDs
        require(supply + _mintAmount <= type(uint256).max, "Token ID overflow");

        // Create tokens
        for(uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }

        // Emit event
        emit Mint(_mintAmount, msg.sender);
    }

    // Return metadata IPFS url
    // EG: 'ipfs://QmQ2jnDYecFhrf3asEWjyjZRX1pZSsNWG3qHzmNDvXa9qg/1.json'
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns(string memory)
    {
        require(_ownerOf(_tokenId) != address(0), 'token does not exist');
        return(string(abi.encodePacked(baseURI, _tokenId.toString(), baseExtension)));
    }

    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for(uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }
    

    // Owner functions

    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Withdrawal failed");

        emit Withdraw(balance, msg.sender);
    }

    function setCost(uint256 _newCost) public onlyOwner {
        require(_newCost <= MAX_COST, "Cost exceeds maximum limit");
        cost = _newCost;
    }

    function setMaxMintAmount(uint256 _newMaxMintAmount) public onlyOwner {
        maxMintAmount = _newMaxMintAmount;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    
    // Emergency function to permanently disable minting
    function permanentlyDisableMinting() public onlyOwner {
        mintingPermanentlyDisabled = true;
    }

}
