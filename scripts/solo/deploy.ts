import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

let data = {
  XBurger: {
    address: "",
    deployed: false,
    verified: false
  },
  DemaxShackChef: {
    address: "",
    deployed: false,
    verified: false
  }
};

let ShackAddress = "0x0000000000000000000000000000000000000000"
let DevAddress = "0x4645a1Cfcd402f6EAEb3aa51D252A2734d1C4c9B"
let MintPerBlock = 1000000000000000000
let StartBlock = 7940456

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

  // contract A deploy
  contractName = "DemaxShackChef"
  const demaxShackChefFactory = await ethers.getContractFactory(contractName);
  let demaxShackChef = await demaxShackChefFactory.deploy(
    ShackAddress,
    xburger.address,
    DevAddress,
    MintPerBlock,
    StartBlock
  ); // deploy args
  await demaxShackChef.deployed();
  data.XBurger.address = demaxShackChef.address;
  data.XBurger.deployed = true;
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