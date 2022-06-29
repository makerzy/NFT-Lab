import dotenv from "dotenv";
import { ethers, Wallet } from "ethers";
import { provider } from "./ethersReadOnly";
dotenv.config();

const { MNEMONIC, RINKEBY_RPC_URL } = process.env;

export const generateWallets = async () => {
  const wallets: Wallet[] = [];
  const accounts: any[] = [];
  const HDNode = ethers.utils.HDNode.fromMnemonic(MNEMONIC);
  for (let i = 0; i < 20; i++) {
    const account = HDNode.derivePath(`m/44'/60'/0'/0/${i}`); // This returns a new HDNode
    wallets.push(new ethers.Wallet(account.privateKey));
    accounts.push(account);
  }
  return wallets;
};

export async function getProvidersFromWallet(rpcURL: string = RINKEBY_RPC_URL) {
  const wallets = await generateWallets();
  return wallets.map((wallet) => wallet.connect(provider(rpcURL)));
}
