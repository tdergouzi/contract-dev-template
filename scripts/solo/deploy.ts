import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

let data = {
  XBurger: {
    address: "",
    constructorArgs: [],
    deployed: false,
    verified: false
  },
  DemaxShackChef: {
    address: "",
    constructorArgs: [
      "0x0000000000000000000000000000000000000000",
      "",
      "0x4645a1Cfcd402f6EAEb3aa51D252A2734d1C4c9B",
      "1000000000000000000",
      7940456
    ],
    deployed: false,
    verified: false
  }
};

async function before() {
  // deploy test contracts
}

async function deploy() {
  console.log("============Start to deploy project's contracts.============");

  // contract Counter deploy
  let contractName = "XBurger"
  const xBurgerFactory = await ethers.getContractFactory(contractName);
  let xburger = await xBurgerFactory.deploy();
  await xburger.deployed();
  data.XBurger.address = xburger.address;
  data.XBurger.deployed = true;
  console.log(`Deploy contract ${contractName} successful!`)
  data.DemaxShackChef.constructorArgs[1] = xburger.address

  // contract A deploy
  contractName = "DemaxShackChef"
  const demaxShackChefFactory = await ethers.getContractFactory(contractName);
  let demaxShackChef = await demaxShackChefFactory.deploy(
    data.DemaxShackChef.constructorArgs[0],
    data.DemaxShackChef.constructorArgs[1],
    data.DemaxShackChef.constructorArgs[2],
    data.DemaxShackChef.constructorArgs[3],
    data.DemaxShackChef.constructorArgs[4]
  ); // deploy args
  await demaxShackChef.deployed();
  data.DemaxShackChef.address = demaxShackChef.address;
  data.DemaxShackChef.deployed = true;
  console.log(`Deploy contract ${contractName} successful!`)

  // write to file
  let content = JSON.stringify(data);
  let filePath = path.join(__dirname, `.data.json`);
  fs.writeFileSync(filePath, content);

  console.log("======================Deploy Done!.=====================");
}

async function init() {
  // init project's contracts
  // batch add
}

async function after() {
  // ready test data
}

async function main() {
  await before();
  await deploy();
  await init();
  await after();
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });