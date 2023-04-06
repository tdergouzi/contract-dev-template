import { Wallet } from 'ethers'
import { ethers, waffle } from 'hardhat'
import { Example } from '../typechain-types/Example'
import { expect } from 'chai'
import { exampleFixture } from './shared/fixturesExample'

const createFixtureLoader = waffle.createFixtureLoader

describe('Example', async () => {
    let wallet: Wallet, other: Wallet;

    let e: Example;

    let loadFixTure: ReturnType<typeof createFixtureLoader>;

    before('create fixture loader', async () => {
        [wallet, other] = await (ethers as any).getSigners()
        loadFixTure = createFixtureLoader([wallet, other])
    })

    beforeEach('deploy Example', async () => {

        ; ({ e } = await loadFixTure(exampleFixture));
    })

    describe('#setOwner', async () => {
        it('success', async () => {
            await e.setOwner(other.address)
            expect(await e.owner()).to.eq(other.address)
        })
    })
})