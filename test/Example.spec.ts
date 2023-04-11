import { Wallet } from 'ethers'
import { ethers, waffle } from 'hardhat'
import { expect } from 'chai'
import { Example } from '../typechain-types/Example'
import { exampleFixture } from './shared/fixtures'

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

    describe('#initialize', async () => {
        it('fail for init again', async () => {
            await expect(e.initialize()).to.reverted
        })
    })

    describe('#setOwner', async () => {
        it('fail for not owner A', async () => {
            await expect(e.connect(other).setOwner(other.address)).to.reverted
        })

        it("fail for same param", async () => {
            await expect(e.setOwner(wallet.address)).to.reverted
        })

        it('success', async () => {
            await e.setOwner(other.address)
            expect(await e.owner()).to.eq(other.address)
        })
    })
})