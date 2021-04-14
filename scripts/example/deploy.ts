import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

let data = {
  Counter: {
    address: "",
    constructorArgs: [0, "0x990Da169916448cd2753D7cA51A0458572275A42"],
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
  let contractName = "Counter"
  const factory = await ethers.getContractFactory(contractName);
  // If we had constructor arguments, they would be passed into deploy()
  let counter = await factory.deploy(data.Counter.constructorArgs[0], data.Counter.constructorArgs[1]);
  // The contract is NOT deployed yet; we must wait until it is mined
  await counter.deployed();
  // The address the Contract WILL have once mined
  data.Counter.address = counter.address;
  data.Counter.deployed = true;
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