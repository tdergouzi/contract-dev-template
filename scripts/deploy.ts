import { ethers, network } from "hardhat";
import fs from "fs";
import path from "path";
let chainId = 0;
let filePath = path.join(__dirname, `.data.json`);
let data: any = {
};

async function loadConfig() {
  chainId = await network.provider.send("eth_chainId");
  chainId = Number(chainId);
  let _filePath = path.join(__dirname, `.data.${chainId}.json`);
  if (fs.existsSync(_filePath)) {
    filePath = _filePath;
  }
  console.log('filePath:', filePath);
}

function updateConstructorArgs(name: string, address: string) {
  for (let k in data) {
    for (let i in data[k].constructorArgs) {
      let v = "${" + name + ".address}";
      if (data[k].constructorArgs[i] == v) {
        data[k].constructorArgs[i] = address;
      }
    }
  }
}

async function before() {
  await loadConfig();
  if (fs.existsSync(filePath)) {
    let rawdata = fs.readFileSync(filePath);
    data = JSON.parse(rawdata.toString());
    for (let k in data) {
      if (data[k].address != "") {
        updateConstructorArgs(k, data[k].address);
      }
    }
  }
}

async function deployContract(name: string, value: any) {
  if (data[name].deployed) {
    console.log(`Deploy contract ${name} exits: ${data[name].address}`)
    return;
  }
  console.log('Deploy contract...', name, value)
  let contractName = name;
  if(data[name].hasOwnProperty('contractName')) {
    contractName = data[name].contractName;
  }
  const Factory = await ethers.getContractFactory(contractName);
  let ins = await Factory.deploy(...value.constructorArgs);
  await ins.deployed();
  data[name].address = ins.address;
  data[name].deployed = true;
  data[name].verified = false;
  console.log(`Deploy contract ${name} new: ${ins.address}`)
  updateConstructorArgs(name, ins.address);
}

async function deploy() {
  console.log("============Start to deploy project's contracts.============");
  for (let k in data) {
    await deployContract(k, data[k])
  }
  console.log("======================Deploy Done!.=====================");
}


async function init() {
}

async function after() {
  let content = JSON.stringify(data, null, 2);
  let filePath = path.join(__dirname, `.data.json`);
  fs.writeFileSync(filePath, content);
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