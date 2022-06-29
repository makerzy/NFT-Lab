const metadata =
  "ipfs://bafybeiei2m6wpjky3i5m3qod3xd2tpxnk4jnqsbimlr5ou2imbmnqplc44/rattler-nft.json";
import dotenv from "dotenv";
import { ethers, utils, Wallet } from "ethers";
import RATTLERNFT from "../artifacts/contracts/ERC721.sol/LabNFT.json";
import { getProvidersFromWallet } from "./ethersSigner";

dotenv.config();
const { MNEMONIC, RINKEBY_RPC_URL } = process.env;
const contract_address = "";

const mint = async () => {
  const wallets = await getProvidersFromWallet(RINKEBY_RPC_URL);

  const signer = wallets[0];
  const msgSender = wallets[1];
  const errorSender = wallets[2];

  const rattlerInstance = new ethers.Contract(
    contract_address,
    RATTLERNFT.abi,
    signer
  );

  const contract_data = await Promise.all([
    rattlerInstance.version(),
    rattlerInstance.name(),
    rattlerInstance.nonce(signer.address),
    rattlerInstance.owner(),
  ]);

  const domain = {
    name: contract_data[1],
    version: contract_data[0],
    chainId: 4,
    verifyingContract: rattlerInstance.address,
  };

  const types = {
    SafeMintWithSig: [
      { name: "to", type: "address" },
      { name: "tokenId", type: "uint256" },
      { name: "uri", type: "string" },
      { name: "nonce", type: "uint256" },
    ],
  };

  const value = {
    to: msgSender.address,
    tokenId: 2,
    uri: metadata,
    nonce: 2,
  };

  const signature = await signer._signTypedData(domain, types, value);
  console.log({ signature });
  const { v, r, s } = utils.splitSignature(signature);
  console.log("Splitted signature: >>",{ v, r, s });
  const trxn = await rattlerInstance
    .connect(msgSender)
    .safeMintWithSig(errorSender.address, value.tokenId, value.uri, v, r, s);
  await trxn.wait();
  console.log({
    transactionHash: `https://rinkeby.etherscan.io/tx/${trxn.hash}`,
  });
};

mint()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error({ "Error reason": e?.error?.reason });
    process.exit(1);
  });
