let shell = require("shelljs");
let fs = require("fs");
let path = require("path");

const filePath = path.dirname(process.argv.slice(1)[0]) + "/.data.json";
const network = process.argv.slice(1)[1];

async function verify(data, ele) {
    return new Promise((resolve, reject) => {
        return shell.exec(`npx hardhat verify --network ${network} ${data[ele].address}`, (error, stdout, stderr) => {
        // return shell.exec(`pwd`, (error, stdout, stderr) => {
            if (error) {
                console.log(`error: ${error.message}`);
                reject(error);
            }
            // update contract verify state
            resolve()
        });
    })
}

async function main() {
    console.log("============Start verify contract.============");

    // get deploy data from .data.json
    let rawdata = fs.readFileSync(filePath);
    let data = JSON.parse(rawdata);

    // range to verify 
    for (const ele of Object.keys(data)) {
        await verify(data, ele);
        data[ele].verified = true
    }

    // const promises = Object.keys(data).map(verify(data))
    // await Promise.all(promises);

    // updata .data.json
    let content = JSON.stringify(data);
    fs.writeFileSync(filePath, content);

    console.log("============Verify contract Done!============");
}

main();

