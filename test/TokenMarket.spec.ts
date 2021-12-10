import { Wallet, BigNumber } from 'ethers'
import { ethers, waffle } from 'hardhat'
import { TestToken } from '../typechain/TestToken'
import { TokenMarket } from '../typechain/TokenMarket'
import { expect } from './shared/expect'
import { bigNumber18 } from './shared/fixturesCommon'
import { tokenMarketFixture } from './shared/fixturesTokenMarket'

const createFixtureLoader = waffle.createFixtureLoader

describe('GameTicket', async () => {
    let wallet: Wallet, other: Wallet;

    let tokenMarket: TokenMarket;

    let loadFixTure: ReturnType<typeof createFixtureLoader>;

    before('create fixture loader', async () => {
        [wallet, other] = await (ethers as any).getSigners()
        loadFixTure = createFixtureLoader([wallet, other])
    })

    beforeEach('deploy GameTicket', async () => {
        ; ({ tokenMarket} = await loadFixTure(tokenMarketFixture));
    })
})