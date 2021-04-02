import { exec } from "child_process";

/*
    TODO
    read data from .data.json
    for ele = range dataObj {
        exec(`npx hardhat verify --network ${ele.newWork} ${ele.address}`, (error, stdout, stderr) => {})
    }
*/ 

const NetWork = 'ropsten'
const ContractAddress = ''

exec(`npx hardhat verify --network ${NetWork} ${ContractAddress}`, (error, stdout, stderr) => {
    if (error) {
        console.log(`error: ${error.message}`);
        return;
    }
    if (stderr) {
        console.log(`stderr: ${stderr}`);
        return;
    }
    console.log(`stdout: ${stdout}`);
})


