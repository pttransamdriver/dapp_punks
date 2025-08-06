// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721Enumerable, Ownable, ReentrancyGuard, Pausable {
    using Strings for uint256;

    string public baseURI;
    uint256 public cost;
    uint256 public maxSupply;
    uint256 public maxMintAmount = 10; // Maximum tokens per transaction
    bool public mintingPermanentlyDisabled = false; // Emergency stop


    event Mint(uint256 amount, address minter);
    event Withdraw(uint256 amount, address owner);
    event Paused(address account);
    event Unpaused(address account);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _cost,
        uint256 _maxSupply,
        string memory _baseURI
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        cost = _cost;
        maxSupply = _maxSupply;
        baseURI = _baseURI;
    }

    function mint(uint256 _mintAmount) public payable nonReentrant whenNotPaused {
        require(!mintingPermanentlyDisabled, "Minting permanently disabled");
        require(_mintAmount > 0, "Must mint at least 1 token");
        require(_mintAmount <= maxMintAmount, "Exceeds maximum mint amount per transaction");
        require(msg.sender == tx.origin, "Contracts cannot mint");
        uint256 totalCost = cost * _mintAmount;
        require(msg.value >= totalCost, "Insufficient payment");

        uint256 supply = totalSupply();
        require(supply + _mintAmount <= maxSupply, "Exceeds maximum supply");

        for(uint256 i = 0; i < _mintAmount; i++) {
            _safeMint(msg.sender, supply + i + 1);
        }

        if (msg.value > totalCost) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: msg.value - totalCost}("");
            require(refundSuccess, "Refund failed");
        }
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
        require(ownerOf(_tokenId) != address(0), 'token does not exist');
        return(string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")));
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
        cost = _newCost;
    }

    function setMaxMintAmount(uint256 _newMaxMintAmount) public onlyOwner {
        maxMintAmount = _newMaxMintAmount;
    }

    function pause() public onlyOwner {
        _pause();
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner {
        _unpause();
        emit Unpaused(msg.sender);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    
    // Emergency function to permanently disable minting
    function permanentlyDisableMinting() public onlyOwner {
        mintingPermanentlyDisabled = true;
    }

}
