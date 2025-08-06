// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
require('dotenv').config();

async function main() {
  // It's recommended to use environment variables for configuration
  // to avoid hardcoding values, especially for different networks (testnet vs mainnet).
  // Create a .env file in your project root with these values.
  const NAME = process.env.NFT_NAME || 'Dapp Punks';
  const SYMBOL = process.env.NFT_SYMBOL || 'DP';
  const COST = hre.ethers.parseEther(process.env.NFT_COST_ETH || '10');
  const MAX_SUPPLY = process.env.NFT_MAX_SUPPLY || 25;
  const IPFS_METADATA_URI = process.env.NFT_IPFS_METADATA_URI || 'ipfs://QmQ2jnDYecFhrf3asEWjyjZRX1pZSsNWG3qHzmNDvXa9qg/';

  // Setting a mint date relative to deployment time can be risky.
  // If the deployment transaction takes too long, the mint date might be in the past.
  // It's safer to set a specific future timestamp or provide a larger buffer.
  // Example: 10 minutes from now.
  const MINT_DATE_DELAY_MS = 10 * 60 * 1000; // 10 minutes in milliseconds
  const NFT_MINT_DATE = Math.floor((Date.now() + MINT_DATE_DELAY_MS) / 1000).toString();

  // Deploy NFT
  const NFT = await hre.ethers.getContractFactory('NFT')
  let nft = await NFT.deploy(NAME, SYMBOL, COST, MAX_SUPPLY, NFT_MINT_DATE, IPFS_METADATA_URI)

  await nft.waitForDeployment()
  const nftAddress = await nft.getAddress();
  console.log(`NFT deployed to: ${nftAddress}\n`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
