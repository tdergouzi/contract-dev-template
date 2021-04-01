/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 import { HardhatUserConfig } from "hardhat/types";

 import "@nomiclabs/hardhat-waffle";
 import "@nomiclabs/hardhat-etherscan";
 import "hardhat-typechain";

 const RINKEBY_PRIVATE_KEY = "23fbce256be92cfd6d54d56f77a0942ce2fd84d74c1a0391357d18bc34c59f8a"; // ted's dev account
 const INFURA_API_KEY = "fb40925bfc8444b0bc5677870300725c"; // ted's infura project01
 const ETHERSCAN_API_KEY = "B8VPJVPZY9EDIQ1S3X24MJRTUG15TD2DHB" // ted's etherscan app01
 
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
       url: `https://ropsten.infura.io/v3/${INFURA_API_KEY}`,
       accounts: [RINKEBY_PRIVATE_KEY]
     },
     rinkeby: {
       url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
       accounts: [RINKEBY_PRIVATE_KEY]
     },
   },
   etherscan: {
     apiKey: ETHERSCAN_API_KEY,
   },
   paths: {
     sources: "./contracts",
     tests: "./test",
     cache: "./cache",
     artifacts: "./artifacts"
   },
   mocha: {
     timeout: 20000
   }
 };

 export default config;