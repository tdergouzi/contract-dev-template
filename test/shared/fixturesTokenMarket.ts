import { BigNumber, Wallet } from 'ethers'
import { ethers, network } from 'hardhat'
import { TestToken } from '../../typechain/TestToken'
import { TokenMarket } from '../../typechain/TokenMarket'
import { Fixture, deployMockContract, MockContract } from 'ethereum-waffle'
import { bigNumber18 } from './fixturesCommon'

interface TokenMarketFixture {
    tokenMarket: TokenMarket
}

export const tokenMarketFixture: Fixture<TokenMarketFixture> = async function ([wallet, other]: Wallet[]): Promise<TokenMarketFixture> {

    // deploy 
    let tokenMarketFactory = await ethers.getContractFactory('TokenMarket')
    let tokenMarket = (await tokenMarketFactory.deploy()) as TokenMarket

    return { tokenMarket }
}