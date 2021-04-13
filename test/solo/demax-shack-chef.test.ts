import { ethers } from "hardhat";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { DemaxShackChef } from "../../typechain/DemaxShackChef";

chai.use(solidity);
const { expect } = chai;

describe("DemaxShackChef", () => {
    let demaxShackChef: DemaxShackChef

    beforeEach(async () => {
        const signers = await ethers.getSigners()
        const demaxShackChefFactory = await ethers.getContractFactory("DemaxShackChef", signers[0])
        demaxShackChef = (await demaxShackChefFactory.deploy()) as DemaxShackChef;
        await demaxShackChef.deployed();
        expect(demaxShackChef.address).to.properAddress;
    })

    describe("Deposit", () => {
        // TODO
    })

    describe("harvest", () => {
        // TODO
    })

    describe("withdraw", () => {
        // TODO
    })

})

