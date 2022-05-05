import { Wallet } from 'ethers'
import { ethers } from 'hardhat'
import { Fixture} from 'ethereum-waffle'
import { Example } from '../../typechain/Example'

interface ExampleFixture {
    e: Example
}

export const exampleFixture: Fixture<ExampleFixture> = async function ([wallet, other]: Wallet[]): Promise<ExampleFixture> {
    let exampleFactory = await ethers.getContractFactory('Example')
    let e = (await exampleFactory.deploy()) as Example
    await e.initialize()
    return { e }
}