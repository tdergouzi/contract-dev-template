import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

let data = {
  Counter: {
    address: "",
    deployed: false,
    verified: false
  },
  ContractA: {
    address: "",
    deployed: false,
    verified: false
  },
  ContractB: {
    address: "",
    deployed: false,
    verified: false
  },
};

async function before() {
  // deploy test contracts
}

async function deploy() {
  console.log("============Start to deploy project's contracts.============");

  // contract Counter deploy
  let contractName = "Counter"
  const factory = await ethers.getContractFactory(contractName);
  // If we had constructor arguments, they would be passed into deploy()
  let counter = await factory.deploy();
  // The contract is NOT deployed yet; we must wait until it is mined
  await counter.deployed();
  // The address the Contract WILL have once mined
  data.Counter.address = counter.address;
  data.Counter.deployed = true;
  console.log(`Deploy contract ${contractName} successful!`)

  // contract A deploy
  contractName = "ContractA"
  data.ContractA.address = "ContractAAddress";
  data.ContractA.deployed = true
  console.log(`Deploy contract ${contractName} successful!`)

  // contract B deploy
  contractName = "ContractB"
  data.ContractB.address = "contractBAddress";
  data.ContractB.deployed = true;
  console.log(`Deploy contract ${contractName} successful!`)

  // write to file
  let content = JSON.stringify(data);
  let filePath = path.join(__dirname, `.data.json`);
  fs.writeFileSync(filePath, content);

  console.log("======================Deploy Done!.=====================");
}

async function init() {
  // init project's contracts
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