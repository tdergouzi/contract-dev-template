let path = require("path");
let shell = require("shelljs");

const filePath = path.dirname(process.argv.slice(1)[0]) + "/deploy.ts";
const network = process.argv.slice(1)[1];

// console.log(filePath);
// console.log(network)

shell.exec(`npx hardhat run --network ${network} ${filePath}`);