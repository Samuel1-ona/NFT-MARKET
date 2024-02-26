import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

dotenv.config();

const { Mumbia, KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    mumbai: {
      url: Mumbia,
      accounts: [KEY as string],
    },
  },
};

export default config;
