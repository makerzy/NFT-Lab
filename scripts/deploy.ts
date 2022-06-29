import { ethers } from "hardhat";

async function main() {
  // We get the contract to deploy
  const NFTContract = await ethers.getContractFactory("LabNFT");
  const nft_contract = await NFTContract.deploy();

  await nft_contract.deployed();

  console.log("NFTContract deployed to:", nft_contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
