import { Wallet, BigNumber } from 'ethers'
import { ethers } from 'hardhat'
import { Fixture} from 'ethereum-waffle'
import { Example } from '../../typechain-types/Example'

export const bigNumber18 = BigNumber.from("1000000000000000000")  // 1e18
export const bigNumber17 = BigNumber.from("100000000000000000")  //1e17
export const bigNumber8 = BigNumber.from("100000000")  //1e8

interface ExampleFixture {
    e: Example
}

export const exampleFixture: Fixture<ExampleFixture> = async function ([wallet, other]: Wallet[]): Promise<ExampleFixture> {
    let exampleFactory = await ethers.getContractFactory('Example')
    let e = (await exampleFactory.deploy()) as Example
    await e.initialize()
    return { e }
}