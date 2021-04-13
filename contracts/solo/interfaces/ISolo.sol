// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * ------------------------ Solo HECO: MDEX Pools ------------------------

 * Contract address: 0x1cF73836aE625005897a1aF831479237B6d1e4D2
 * Reward Token: MDX
 * Pools (pid => token):
 *  0 => BTC (0x66a79D23E58475D2738179Ca52cd0b41d73f0BEa)
 *  1 => ETH (0x64FF637fB478863B7468bc97D30a5bF3A428a1fD)
 *  2 => DOT (0xA2c49cEe16a5E5bDEFDe931107dc1fae9f7773E3)
 *  3 => USDT (0xa71EdC38d189767582C38A3145b5873052c3e47a)
 *  4 => HUSD (0x0298c2b32eaE4da002a15f36fdf7615BEa3DA047), Closed
 *  5 => MDX (0x25D2e80cB6B86881Fd7e07dd263Fb79f4AbE033c)
 *  6 => WHT (0x5545153CCFcA01fbd7Dd11C0b23ba694D9509A6F)
 *
 * ------------------------ Solo HECO: BXH Pools ------------------------
 *
 * Contract address: 0xE1f39a72a1D012315d581c4F35bb40e24196DAc8
 * Reward Token: BXH
 * Pools (pid => token):
 *  0 => BXH (0xcBD6Cb9243d8e3381Fea611EF023e17D1B7AeDF0)
 *  1 => USDT (0xa71EdC38d189767582C38A3145b5873052c3e47a)
 *  2 => HUSD (0x0298c2b32eaE4da002a15f36fdf7615BEa3DA047)
 *  3 => ETH (0x64FF637fB478863B7468bc97D30a5bF3A428a1fD)
 *  4 => BTC (0x66a79D23E58475D2738179Ca52cd0b41d73f0BEa)
 *  5 => DOT (0xA2c49cEe16a5E5bDEFDe931107dc1fae9f7773E3)
 *  6 => LTC (0xecb56cf772B5c9A6907FB7d32387Da2fCbfB63b4)
 *  7 => FIL (0xae3a768f9aB104c69A7CD6041fE16fFa235d1810)
 *  8 => HPT (0xE499Ef4616993730CEd0f31FA2703B92B50bB536)
 *
 * ------------------------ Solo BSC: MDEX Pools ------------------------
 *
 * Contract address: 0x7033A512639119C759A51b250BfA461AE100894b
 * Reward Token: MDX
 * Pools (pid => token):
 *  0 => MDX (0x9C65AB58d8d978DB963e63f2bfB7121627e3a739)
 *  1 => HMDX (0xAEE4164c1ee46ed0bbC34790f1a3d1Fc87796668)
 *  2 => WBNB (0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)
 *  3 => BTCB (0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c)
 *  4 => ETH (0x2170Ed0880ac9A755fd29B2688956BD959F933F8)
 *  5 => DOT (0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402), Closed
 *  6 => BUSD (0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56)
 *  7 => USDT (0x55d398326f99059fF775485246999027B3197955)
 */

interface ISolo {

    /**
     * @dev Get Pool infos
     * If you want to get the pool's available quota, let "avail = depositCap - accShare"
     */
    function pools(uint256 pid) external view returns (
        address token,              // Address of token contract
        uint256 depositCap,         // Max deposit amount
        uint256 depositClosed,      // Deposit closed
        uint256 lastRewardBlock,    // Last block number that reward distributed
        uint256 accRewardPerShare,  // Accumulated rewards per share
        uint256 accShare,           // Accumulated Share
        uint256 apy,                // APY, times 10000
        uint256 used                // How many tokens used for farming
    );

    /**
    * @dev Get pid of given token
    */
    function pidOfToken(address token) external view returns (uint256 pid);

    /**
    * @dev Get User infos
    */
    function users(uint256 pid, address user) external view returns (
        uint256 amount,     // Deposited amount of user
        uint256 rewardDebt  // Ignore
    );

    /**
     * @dev Get user unclaimed reward
     */
    function unclaimedReward(uint256 pid, address user) external view returns (uint256 reward);

    /**
     * @dev Get user total claimed reward of all pools
     */
    function userStatistics(address user) external view returns (uint256 claimedReward);

    /**
     * @dev Deposit tokens and Claim rewards
     * If you just want to claim rewards, call function: "deposit(pid, 0)"
     */
    function deposit(uint256 pid, uint256 amount) external;

    /**
     * @dev Withdraw tokens
     */
    function withdraw(uint256 pid, uint256 amount) external;

}