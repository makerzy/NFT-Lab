// import { ethers } from "hardhat";
// import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
// import chai, { expect } from "chai";
// import { solidity } from "ethereum-waffle";
// import { Contract, utils } from "ethers";
// import { describe, it } from "mocha";
// chai.use(solidity);

// let accounts: SignerWithAddress[],
//   wallet: SignerWithAddress,
//   other0: SignerWithAddress,
//   other1: SignerWithAddress,
//   other2: SignerWithAddress,
//   other3: SignerWithAddress,
//   other4: SignerWithAddress,
//   other5: SignerWithAddress,
//   other6: SignerWithAddress;
// let RattlerNFT: Contract;
// const domain = (verifyingContract: string) => ({
//   name: "Lab Royalty NFT",
//   version: "1.0.1",
//   chainId: 31337,
//   verifyingContract,
// });

// const types = {
//   SafeMintWithSig: [
//     { name: "to", type: "address" },
//     { name: "tokenId", type: "uint256" },
//     { name: "uri", type: "string" },
//     { name: "nonce", type: "uint256" },
//   ],
// };
// const metadata =
//   "ipfs://bafybeiei2m6wpjky3i5m3qod3xd2tpxnk4jnqsbimlr5ou2imbmnqplc44/rattler-nft.json";
// describe("Rattler NFT", () => {
//   beforeEach("txn", async () => {
//     accounts = await ethers.getSigners();
//     [wallet, other0, other1, other2, other3, other4, other5, other6] = accounts;
//     const RATTLER_NFT = await ethers.getContractFactory("LabNFT", wallet);
//     RattlerNFT = await RATTLER_NFT.deploy();
//     console.log({ contract_address: RattlerNFT.address });
//   });
//   describe("Tx", () => {
//     it("mint", async () => {
//       const value = {
//         to: other0.address,
//         tokenId: 1,
//         uri: metadata,
//         nonce: 1,
//       };

//       const signature = await wallet._signTypedData(
//         domain(RattlerNFT.address),
//         types,
//         value
//       );
//       const { v, r, s } = utils.splitSignature(signature);
//       console.log({ v, r, s });
//       const txn = await RattlerNFT.safeMintWithSig(
//         value.to,
//         value.tokenId,
//         value.uri,
//         v,
//         r,
//         s
//       );
//       const completed_tx = await txn.wait();
//       console.log("object :>> ", { completed_tx });
//       console.log({
//         transactionHash: `https://rinkeby.etherscan.io/tx/${txn.hash}`,
//       });
//     });
//   });
// });
