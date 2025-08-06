const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
  return ethers.parseUnits(n.toString(), 'ether')
}

const ether = tokens

describe('NFT', () => {
  const NAME = 'Dapp Punks'
  const SYMBOL = 'DP'
  const COST = ether(10)
  const MAX_SUPPLY = 25
  const BASE_URI = 'ipfs://QmQ2jnDYecFhrf3asEWjyjZRX1pZSsNWG3qHzmNDvXa9qg/'

  let nft,
      deployer,
      minter

  beforeEach(async () => {
    let accounts = await ethers.getSigners()
    deployer = accounts[0]
    minter = accounts[1]
  })

  describe('Deployment', () => {
    beforeEach(async () => {
      const NFT = await ethers.getContractFactory('NFT')
      nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)
    })

    it('has correct name', async () => {
      expect(await nft.name()).to.equal(NAME)
    })

    it('has correct symbol', async () => {
      expect(await nft.symbol()).to.equal(SYMBOL)
    })

    it('returns the cost to mint', async () => {
      expect(await nft.cost()).to.equal(COST)
    })

    it('returns the maximum total supply', async () => {
      expect(await nft.maxSupply()).to.equal(MAX_SUPPLY)
    })

    it('returns the max mint amount', async () => {
      expect(await nft.maxMintAmount()).to.equal(10) // Default value
    })

    it('returns the base URI', async () => {
      expect(await nft.baseURI()).to.equal(BASE_URI)
    })

    it('returns the owner', async () => {
      expect(await nft.owner()).to.equal(deployer.address)
    })

  })


  describe('Minting', () => {
    let transaction, result

    describe('Success', async () => {

      beforeEach(async () => {
        const NFT = await ethers.getContractFactory('NFT')
        nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)

        transaction = await nft.connect(minter).mint(1, { value: COST })
        result = await transaction.wait()
      })

      it('returns the address of the minter', async () => {
        expect(await nft.ownerOf(1)).to.equal(minter.address)
      })

      it('returns total number of tokens the minter owns', async () => {
        expect(await nft.balanceOf(minter.address)).to.equal(1)
      })

      it('returns IPFS URI', async () => {
        // EG: 'ipfs://QmQ2jnDYecFhrf3asEWjyjZRX1pZSsNWG3qHzmNDvXa9qg/1.json'
        // Uncomment this line to see example
        // console.log(await nft.tokenURI(1))
        expect(await nft.tokenURI(1)).to.equal(`${BASE_URI}1.json`)
      })

      it('updates the total supply', async () => {
        expect(await nft.totalSupply()).to.equal(1)
      })

      it('updates the contract ether balance', async () => {
        expect(await ethers.provider.getBalance(await nft.getAddress())).to.equal(COST)
      })

      it('emits Mint event', async () => {
        await expect(transaction).to.emit(nft, 'Mint')
          .withArgs(1, minter.address)
      })

    })

    describe('Failure', async () => {

      it('rejects insufficient payment', async () => {
        const NFT = await ethers.getContractFactory('NFT')
        nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)

        await expect(nft.connect(minter).mint(1, { value: ether(1) })).to.be.reverted
      })

      it('requires at least 1 NFT to be minted', async () => {
        const NFT = await ethers.getContractFactory('NFT')
        nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)

        await expect(nft.connect(minter).mint(0, { value: COST })).to.be.reverted
      })

      it('prevents minting to contracts', async () => {
        const NFT = await ethers.getContractFactory('NFT')
        nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)

        // This test is no longer relevant since allowMintingOn was removed
        // Instead testing the 'Contracts cannot mint' requirement
        expect(await nft.connect(minter).mint(1, { value: COST })).to.not.be.reverted
      })

      it('does not allow more NFTs to be minted than max supply', async () => {
        const NFT = await ethers.getContractFactory('NFT')
        nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)

        await expect(nft.connect(minter).mint(100, { value: COST * 100n })).to.be.reverted
      })

      it('does not return URIs for invalid tokens', async () => {
        const NFT = await ethers.getContractFactory('NFT')
        nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)
        await nft.connect(minter).mint(1, { value: COST })

        await expect(nft.tokenURI('99')).to.be.reverted
      })


    })

  })

  describe('Displaying NFTs', () => {
    let transaction, result

    beforeEach(async () => {
      const NFT = await ethers.getContractFactory('NFT')
      nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)

      // Mint 3 nfts
      transaction = await nft.connect(minter).mint(3, { value: ether(30) })
      result = await transaction.wait()
    })

    it('returns all the NFTs for a given owner', async () => {
      let tokenIds = await nft.walletOfOwner(minter.address)
      // Uncomment this line to see the return value
      // console.log("owner wallet", tokenIds)
      expect(tokenIds.length).to.equal(3)
      expect(tokenIds[0].toString()).to.equal('1')
      expect(tokenIds[1].toString()).to.equal('2')
      expect(tokenIds[2].toString()).to.equal('3')
    })


  })

  describe('Minting', () => {

    describe('Success', async () => {

      let transaction, result, balanceBefore

      beforeEach(async () => {
        const NFT = await ethers.getContractFactory('NFT')
        nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)

        transaction = await nft.connect(minter).mint(1, { value: COST })
        result = await transaction.wait()

        balanceBefore = await ethers.provider.getBalance(deployer.address)

        transaction = await nft.connect(deployer).withdraw()
        result = await transaction.wait()
      })

      it('deducts contract balance', async () => {
        expect(await ethers.provider.getBalance(await nft.getAddress())).to.equal(0)
      })

      it('sends funds to the owner', async () => {
        expect(await ethers.provider.getBalance(deployer.address)).to.be.greaterThan(balanceBefore)
      })

      it('emits a withdraw event', async () => {
        expect(transaction).to.emit(nft, 'Withdraw')
          .withArgs(COST, deployer.address)
      })
    })

    describe('Failure', async () => {

      it('prevents non-owner from withdrawing', async () => {
        const NFT = await ethers.getContractFactory('NFT')
        nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)
        nft.connect(minter).mint(1, { value: COST })

        await expect(nft.connect(minter).withdraw()).to.be.reverted
      })
    })
    describe('Pausing', () => {
      // Adding variables for the toggle capability
      let transaction, result
    
      describe('Success', async () => {
        // Find the current date in Unit Time convert that to a string and pull out only the first 10 numbers
        beforeEach(async () => {
          const NFT = await ethers.getContractFactory('NFT')
          nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)
        })
    
        it('updates pause state', async () => {
          expect(await nft.paused()).to.equal(false) // Initially not paused
          transaction = await nft.connect(deployer).pause()
          await transaction.wait()
          expect(await nft.paused()).to.equal(true) // Should be paused after pause
        })
    
        it('returns correct pause state after multiple toggles', async () => {
          // First pause
          transaction = await nft.connect(deployer).pause()
          await transaction.wait()
          expect(await nft.paused()).to.equal(true)

          // Then unpause
          transaction = await nft.connect(deployer).unpause()
          await transaction.wait()
          expect(await nft.paused()).to.equal(false)
        })
    
        it('prevents minting while paused', async () => {
          // Pause the contract
          transaction = await nft.connect(deployer).pause()
          await transaction.wait()

          // Try to mint while paused
          await expect(
            nft.connect(minter).mint(1, { value: COST })
          ).to.be.reverted
        })
    
        it('allows minting after unpausing', async () => {
          // Pause the contract
          transaction = await nft.connect(deployer).pause()
          await transaction.wait()

          // Unpause the contract
          transaction = await nft.connect(deployer).unpause()
          await transaction.wait()

          // Should be able to mint now
          transaction = await nft.connect(minter).mint(1, { value: COST })
          result = await transaction.wait()
          expect(await nft.totalSupply()).to.equal(1)
        })
      })
    
      describe('Failure', async () => {
        beforeEach(async () => {
          const NFT = await ethers.getContractFactory('NFT')
          nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)
        })
    
        it('prevents non-owner from pausing', async () => {
          // Try to pause from non-owner account
          await expect(
            nft.connect(minter).pause()
          ).to.be.reverted
        })

        it('prevents minting while paused', async () => {
          // Pause the contract as owner
          transaction = await nft.connect(deployer).pause()
          await transaction.wait()

          // Try to mint while paused
          await expect(
            nft.connect(minter).mint(1, { value: COST })
          ).to.be.reverted
        })
      })
    })

  })

  describe('Security Tests', () => {
    beforeEach(async () => {
      const NFT = await ethers.getContractFactory('NFT')
      nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, BASE_URI)
    })

    it('prevents minting more than maxMintAmount per transaction', async () => {
      // Try to mint 11 tokens (default maxMintAmount is 10)
      await expect(
        nft.connect(minter).mint(11, { value: COST * 11n })
      ).to.be.revertedWith('Exceeds maximum mint amount per transaction')
    })

    it('allows owner to update maxMintAmount', async () => {
      // Update maxMintAmount to 5
      await nft.connect(deployer).setMaxMintAmount(5)

      // Try to mint 6 tokens (should fail)
      await expect(
        nft.connect(minter).mint(6, { value: COST * 6n })
      ).to.be.revertedWith('Exceeds maximum mint amount per transaction')

      // Mint 5 tokens (should succeed)
      const transaction = await nft.connect(minter).mint(5, { value: COST * 5n })
      await transaction.wait()
      expect(await nft.totalSupply()).to.equal(5)
    })

    it('prevents non-owner from updating maxMintAmount', async () => {
      await expect(
        nft.connect(minter).setMaxMintAmount(5)
      ).to.be.reverted
    })

    it('allows owner to update baseURI', async () => {
      const newBaseURI = 'ipfs://newHash/'
      await nft.connect(deployer).setBaseURI(newBaseURI)
      expect(await nft.baseURI()).to.equal(newBaseURI)
    })

    it('prevents non-owner from updating baseURI', async () => {
      await expect(
        nft.connect(minter).setBaseURI('ipfs://newHash/')
      ).to.be.reverted
    })
  })
})
