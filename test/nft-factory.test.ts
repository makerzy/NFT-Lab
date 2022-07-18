import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import chai, { expect } from "chai";
import { solidity } from "ethereum-waffle";
import { Contract, utils } from "ethers";
import { describe, it } from "mocha";
import NFTJson from "../artifacts/contracts/ERC721EIP191.sol/NFTEIP712EIP191.json"
chai.use(solidity);

let accounts: SignerWithAddress[],
  wallet: SignerWithAddress,
  other0: SignerWithAddress,
  other1: SignerWithAddress,
  other2: SignerWithAddress,
  other3: SignerWithAddress,
  other4: SignerWithAddress,
  other5: SignerWithAddress,
  other6: SignerWithAddress;
let personalNFT: Contract, NftFactory:Contract;
let MINT_STRUCT_HASH: string, domainSeparator: string, SAFE_TRANSFER_SIG: string;
const domain = (verifyingContract: string) => ({
  name: "NFT EIP191&EIP712",
  version: "1.0.1",
  chainId: 31337,
  verifyingContract,
})
const types = {
  SafeMintWithSig: [
    { name: "to", type: "address" },
    { name: "tokenId", type: "uint256" },
    { name: "uri", type: "string" },
    { name: "nonce", type: "uint256" },
  ],
};
const transfer_types = {
  safeTransferFromSig: [
    { name: "to", type: "address" },
    { name: "tokenId", type: "uint256" },
    { name: "nonce", type: "uint256" },
  ],
};
describe("NFT Factory", () => {
  beforeEach("transaction", async () => {
    accounts = await ethers.getSigners();
    [wallet, other0, other1, other2, other3, other4, other5, other6] = accounts;
    const NFTFactory = await ethers.getContractFactory("NFTFactory", wallet);
    const Personal_NFT = await ethers.getContractFactory("NFTEIP712EIP191", wallet);
    const implementationNFT = await Personal_NFT.deploy();
    console.log({ contract_address: implementationNFT.address });
    NftFactory= await NFTFactory.deploy(implementationNFT.address);
    console.log({ NftFactory_address: NftFactory.address });
    const trxn = await NftFactory.createNFT()
    const wait = await trxn.wait()

    const nftAddress = (await NftFactory.getAllNFTs())[0]
    personalNFT = new ethers.Contract( nftAddress, NFTJson.abi , wallet)
    personalNFT=personalNFT.attach(nftAddress)
    let _owner = await personalNFT.owner()
    MINT_STRUCT_HASH = await personalNFT.MINT_STRUCT_HASH()
    SAFE_TRANSFER_SIG = await personalNFT.SAFE_TRANSFER_SIG()
    domainSeparator = await personalNFT.domainSeparator()
  })
  describe("nft factory", () => {

    it("create new nft", async()=>{
      expect(await NftFactory.userNFT(wallet.address)).to.equal(personalNFT.address)

    })

    it("mint with sig EIP712", async()=>{
      const _domain = domain(personalNFT.address)
            const value = {
        to: other0.address,
        tokenId: 1,
        uri: "Hello world!",
        nonce: 1,
      };

      const signature = await wallet._signTypedData(
        _domain,
        types,
        value
      );

      const { v, r, s } = utils.splitSignature(signature);

      console.log({ v, r, s });
      const txn = await personalNFT.safeMintWithSig(
        value.to,
        value.tokenId,
        value.uri,
        v,
        r,
        s
      )
    })
    it("mint with personal", async () => {
      console.log({ domainSeparator, MINT_STRUCT_HASH })
      const digest = utils.solidityKeccak256(
        ['bytes32', 'bytes32', 'address', 'uint256', 'string', 'uint256'],
        [domainSeparator, MINT_STRUCT_HASH, other0.address, 1, 'hello world!', 1]
      )
      const signature = await wallet.signMessage(utils.arrayify(digest))
      const { v, r, s } = utils.splitSignature(signature);
      console.log({ v, r, s });
      await personalNFT.safeMintWithSig(other0.address, 1, 'hello world!',  v, r, s)
    })

    it("transfer with personal", async () => {
      await personalNFT.safeMint(wallet.address, 1, "")      
      const digest = utils.solidityKeccak256(
            ['bytes32','bytes32','address','uint256','uint256'],
            [domainSeparator, SAFE_TRANSFER_SIG, other0.address, 1, 1]
        );
      const signature = await wallet.signMessage(utils.arrayify(digest))
      const { v, r, s } = utils.splitSignature(signature);
      console.log({ v, r, s });
      await personalNFT.safeTransferFromSig(wallet.address, other0.address, 1, v, r, s)
    })
    it("transfer with EIP712", async () => {
      await personalNFT.safeMint(other0.address, 1, "")      
      const _domain = domain(personalNFT.address)
      const value = {
        to: other0.address,
        tokenId: 1,
        nonce: 1,
      };
      const signature = await other0._signTypedData(
        _domain,
        transfer_types,
        value
      );
      const { v, r, s } = utils.splitSignature(signature);
      console.log({ v, r, s });
      await personalNFT.safeTransferFromSig(other0.address, other0.address, 1, v, r, s)
    })
  })
})