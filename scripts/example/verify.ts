import fs from "fs";
import path from "path";
let hre = require("hardhat");

const filePath = path.dirname(process.argv.slice(1)[0]) + "/.data.json";

async function main() {
    console.log("============Start verify contract.============");

    // get deploy data from .data.json
    let rawdata = fs.readFileSync(filePath);
    let data = JSON.parse(rawdata.toString());

    // verify
    for (const ele of Object.keys(data)) {
        await hre.run("verify:verify", {
            address: data[ele].address,
            constructorArguments: data[ele].constructorArgs,
        })
        data[ele].verified = true
    }

    // updata .data.json
    let content = JSON.stringify(data);
    fs.writeFileSync(filePath, content);

    console.log("============Verify contract Done!============");
}

main();
