import { ethers } from "ethers";

export const provider = (url: string) =>
  new ethers.providers.JsonRpcProvider(url);
