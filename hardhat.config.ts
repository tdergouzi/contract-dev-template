/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 import { HardhatUserConfig } from "hardhat/types";

 import "@nomiclabs/hardhat-waffle";
 import "@nomiclabs/hardhat-etherscan";
 import "hardhat-typechain";
 import myConfig from "./config";
 
 const config: HardhatUserConfig = {
   defaultNetwork: "hardhat",
   solidity: {
     compilers:[{version: "0.5.12", settings: {}}],
     settings: {
       optimizer: {
         enabled: true,
         runs: 200
       }
     }
   },
   networks: {
     hardhat: {},
     ropsten: {
       url: `https://ropsten.infura.io/v3/${myConfig.InfuraApiKey}`,
       accounts: [myConfig.PrivateKey]
     },
   },
   etherscan: {
     apiKey: myConfig.EtherscanApiKey,
   },
   paths: {
     sources: "./contracts/example",
     tests: "./test/example",
     cache: "./cache",
     artifacts: "./artifacts"
   },
   mocha: {
     timeout: 20000
   }
 };

 export default config;