import { HardhatUserConfig } from "hardhat/types";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import '@openzeppelin/hardhat-upgrades';
import "hardhat-gas-reporter";
import 'solidity-coverage'
import "dotenv/config";
import env from "hardhat";
// import * as dotenv from "dotenv"
// dotenv.config()

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000
          }
        }
      }
    ],
  },
  networks: {
    hardhat: {
      gas: "auto"
    },
    goerli: {
      url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [String(process.env.PRIVATE_KEY)]
    },
    bsctestnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
      accounts: [String(process.env.PRIVATE_KEY)]
    },
    bscmainnet: {
      url: `https://bsc-dataseed.binance.org/`,
      accounts: [String(process.env.PRIVATE_KEY)]
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    gasPrice: 21
  }
};

export default config;