// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

import "./interfaces/IERC20.sol";
import './libraries/SafeMath.sol';
import "./modules/Ownable.sol";
import "./modules/ReentrancyGuard.sol";

interface IRewardToken {
    function mint(address to, uint value) external returns (bool);
}

interface IShackChef {

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

// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once mintToken is sufficiently
// distributed and the community can show to govern itself.
contract DemaxShackChef is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public version = 1;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 earnDebt;     // Earn debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of RewardTokens, the amount of EarnTokens
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRewardPerShare) - user.rewardDebt
        //   pending earn = (user.amount * pool.accEarnPerShare) - user.earnDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accRewardPerShare` (and `lastUpdateBlock`) gets updated.
        //   2. User receives the pending reward and earn sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
        //   5. User's `earnDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 pid;
        IERC20 depositToken;           // Address of deposit token contract.
        IERC20 earnToken;           // Address of earn token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. RewardTokens to distribute per block.
        uint256 lastUpdateBlock;  // Last block number that RewardTokens distribution occurs.
        uint256 lastRewardAmount; // Last RewardToken amunt that RewardTokens distribution occurs.
        uint256 lastEarnAmount; // Last EarnToken amunt that EarnTokens distribution occurs.
        uint256 accRewardPerShare;   // Accumulated RewardTokens per share, times 1e18. See below.
        uint256 accEarnPerShare;   // Accumulated EarnTokens per share, times 1e18. See below.
        uint16 tokenType;
        bool added;
    }

    // The XBurger TOKEN!
    address public mintToken;
    // Dev address.
    address public devaddr;
    // mintToken tokens created per block.
    uint256 public mintPerBlock;
    // Bonus muliplier for early mintToken makers.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // Shack Chef address
    address public shackAddress;

    uint256 public rewardTotal;
    uint256 public devRewardRate = 0;
    uint256 public devEarnRate = 0;
    mapping(IERC20 => uint256) public earnTokensTotal;

    // Info of each pool.
    mapping(uint256 => PoolInfo) public poolInfo;
    uint256[] pids;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when mintToken mining starts.
    uint256 public startBlock;
    uint256 public endBlock;
    uint256 public accRewardShare;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);
    event SetDevAddress(address indexed user, address indexed newAddress);
    event UpdateEmissionRate(address indexed user, uint256 mintPerBlock);

    constructor(
        address _shackAddress,
        address _mintToken,
        address _devaddr,
        uint256 _mintPerBlock,
        uint256 _startBlock
    ) public {
        shackAddress = _shackAddress;
        mintToken = _mintToken;
        devaddr = _devaddr;
        mintPerBlock = _mintPerBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {
        return pids.length;
    }

    mapping(IERC20 => mapping(IERC20 => bool)) public poolExistence;
    modifier nonDuplicated(IERC20 _depositToken, IERC20 _earnToken) {
        require(poolExistence[_depositToken][_earnToken] == false, "nonDuplicated: duplicated");
        _;
    }

    // Set a new lp to the pool. Can only be called by the owner.
    function add(bool _withUpdate, uint256 _pid, uint256 _allocPoint, IERC20 _depositToken, IERC20 _earnToken, uint16 _tokenType) public onlyOwner nonDuplicated(_depositToken, _earnToken) {
        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastUpdateBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_depositToken][_earnToken] = true;
        poolInfo[_pid] = PoolInfo({
            pid: _pid,
            depositToken : _depositToken,
            earnToken: _earnToken,
            allocPoint : _allocPoint,
            lastUpdateBlock : lastUpdateBlock,
            lastRewardAmount : 0,
            lastEarnAmount : 0,
            accRewardPerShare : 0,
            accEarnPerShare: 0,
            tokenType: _tokenType,
            added: true
        });
    }

    function set(uint256 _pid, uint256 _allocPoint, IERC20 _depositToken, IERC20 _earnToken, uint16 _tokenType) public onlyOwner nonDuplicated(_depositToken, _earnToken) {
        add(true, _pid, _allocPoint, _depositToken, _earnToken, _tokenType);
    }

    function batchAdd(bool _withUpdate, uint256[] memory _pids, uint256[] memory _allocPoints, IERC20[] memory _depositTokens, IERC20[] memory _earnTokens, uint16[] memory _tokenTypes) public onlyOwner {
        for(uint256 i; i<_allocPoints.length; i++) {
            add(false, _pids[i], _allocPoints[i], _depositTokens[i], _earnTokens[i], _tokenTypes[i]);
        }
        if (_withUpdate) {
            massUpdatePools();
        }
    }

    function batchSet(uint256[] memory _pids, uint256[] memory _allocPoints, IERC20[] memory _depositTokens, IERC20[] memory _earnTokens, uint16[] memory _tokenTypes) public onlyOwner {
        batchAdd(true, _pids, _allocPoints, _depositTokens, _earnTokens, _tokenTypes);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    function getToBlock() public view returns (uint256) {
        return block.number;
    }

    function getDepositTokenSupply(uint256 _pid) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        if(shackAddress != address(0)) {
            (uint256 balance, ) = IShackChef(shackAddress).users(_pid, address(this));
            return balance;
        }
        return pool.depositToken.balanceOf(address(this));
    }

    function pendingRewardInfo(uint256 _pid) public view returns (uint256, uint256, uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        if (getToBlock() > pool.lastUpdateBlock && totalAllocPoint > 0) {
            uint256 multiplier = getMultiplier(pool.lastUpdateBlock, getToBlock());
            uint256 reward = multiplier.mul(mintPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            uint256 devValue;
            if(devRewardRate > 0) {
                devValue = reward.div(devRewardRate);
            }
            return (reward, devValue, block.number);
        }
        return (0, 0, block.number);
    }

    function pendingEarnInfo(uint256 _pid) public view returns (uint256, uint256, uint256) {
        if(shackAddress != address(0)) {
            uint256 earn = IShackChef(shackAddress).unclaimedReward(_pid, address(this));
            uint256 devValue;
            if(devEarnRate > 0) {
                devValue = earn.div(devEarnRate);
                earn = earn.sub(devValue);
            }
            return (earn, devValue, block.number);
        }
        return (0, 0, block.number);
    }

    // View function to see pending RewardTokens on frontend.
    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 depositTokenSupply = getDepositTokenSupply(_pid);
        if (depositTokenSupply >0) {
            (uint256 reward, ,) = pendingRewardInfo(_pid);
            accRewardPerShare = accRewardPerShare.add(reward.mul(1e18).div(depositTokenSupply));
        }
        uint256 result = user.amount.mul(accRewardPerShare).div(1e18).sub(user.rewardDebt);
        return result;
    }

    function pendingEarn(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accEarnPerShare = pool.accEarnPerShare;
        uint256 depositTokenSupply = getDepositTokenSupply(_pid);
        if (depositTokenSupply != 0 && shackAddress != address(0)) {
            (uint256 earn, ,) = pendingEarnInfo(_pid);
            accEarnPerShare = accEarnPerShare.add(earn.mul(1e18).div(depositTokenSupply));
        }
        uint256 result = user.amount.mul(accEarnPerShare).div(1e18).sub(user.earnDebt);
        return result;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() internal {
        uint256 length = pids.length;
        for (uint256 i = 0; i < length; ++i) {
            updatePool(pids[i]);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 toBlock = getToBlock();
        if (toBlock <= pool.lastUpdateBlock) {
            return;
        }
        uint256 depositTokenSupply = getDepositTokenSupply(_pid);
        if (depositTokenSupply == 0 || pool.allocPoint == 0) {
            pool.lastUpdateBlock = toBlock;
            return;
        }
        
        (uint256 reward, uint256 devReward,) = pendingRewardInfo(_pid);
        pool.lastRewardAmount = reward;
        IRewardToken(mintToken).mint(address(this), reward);
        rewardTotal = rewardTotal.add(reward);
        if(devReward > 0) {
            IRewardToken(mintToken).mint(devaddr, devReward);
            rewardTotal = rewardTotal.add(devReward);
        }
        pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(1e18).div(depositTokenSupply));

        (uint256 earn, uint256 devEarn,) = _mintEarnToken(_pid);
        pool.lastEarnAmount = earn.add(devEarn);
        pool.accEarnPerShare = pool.accEarnPerShare.add(earn.mul(1e18).div(depositTokenSupply));

        pool.lastUpdateBlock = toBlock;
    }

    // Deposit LP tokens to MasterChef for mintToken allocation.
    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        _harvestMintToken(_pid);
        _harvestEarnToken(_pid);
        if (_amount > 0) {
            pool.depositToken.transferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);

            if(shackAddress != address(0)) {
                IShackChef(shackAddress).deposit(_pid, _amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e18);
        user.earnDebt = user.amount.mul(pool.accEarnPerShare).div(1e18);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        _harvestMintToken(_pid);
        _harvestEarnToken(_pid);
        if (_amount > 0) {
            if(shackAddress != address(0)) {
                IShackChef(shackAddress).withdraw(_pid, _amount);
            }
            user.amount = user.amount.sub(_amount);
            pool.depositToken.transfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e18);
        user.earnDebt = user.amount.mul(pool.accEarnPerShare).div(1e18);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.earnDebt = 0;
        pool.depositToken.transfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function _mintEarnToken(uint256 _pid) internal returns (uint256, uint256, uint256) {
        if(shackAddress == address(0)) {
            return (0, 0, block.number);
        }

        PoolInfo memory pool = poolInfo[_pid];
        uint256 beforeBalance = pool.earnToken.balanceOf(address(this));
        IShackChef(shackAddress).deposit(_pid, 0);
        uint256 afterBalance = pool.earnToken.balanceOf(address(this));
        uint256 earn = afterBalance.sub(beforeBalance);
        earnTokensTotal[pool.earnToken] = earnTokensTotal[pool.earnToken].add(earn);
        uint256 devValue;
        if(devEarnRate > 0) {
            devValue = earn.div(devEarnRate);
            earn = earn.sub(devValue);
        }
        return (earn, devValue, block.number);
    }

    function _harvestMintToken(uint256 _pid) internal returns(uint256 amount) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e18).sub(user.rewardDebt);
        amount = safeTokenTransfer(mintToken, msg.sender, pending);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e18);
        return amount;
    }

    function _harvestEarnToken(uint256 _pid) internal returns(uint256 amount) {
        if(shackAddress == address(0)) {
            return 0;
        }
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pending = user.amount.mul(pool.accEarnPerShare).div(1e18).sub(user.earnDebt);
        amount = safeTokenTransfer(address(pool.earnToken), msg.sender, pending);
        user.earnDebt = user.amount.mul(pool.accEarnPerShare).div(1e18);
        return amount;
    }

    function harvest(uint256 _pid) public nonReentrant {
        updatePool(_pid);
        _harvestMintToken(_pid);
        _harvestEarnToken(_pid);
    }

    // Safe Token transfer function, just in case if rounding error causes pool to not have enough tokens.
    function safeTokenTransfer(address _token, address _to, uint256 _amount) internal returns(uint256) {
        uint256 tokenBal = IERC20(_token).balanceOf(address(this));
        if(_amount > 0 && tokenBal > 0) {
            if (_amount > tokenBal) {
                _amount = tokenBal;
            }
            IERC20(_token).transfer(_to, _amount);
        }
        return _amount;
    }

    function emergencyExitShakChef() public {
        require(msg.sender == owner, "emergencyExitShakChef: FORBIDDEN");
        require(shackAddress != address(0), "emergencyExitShakChef: Invalid Address");
        uint256 length = pids.length;
        for (uint256 i = 0; i < length; ++i) {
            (uint256 amount,) = IShackChef(shackAddress).users(pids[i], address(this));
            IShackChef(shackAddress).withdraw(pids[i], amount);
        }
    }

    // Update dev address by the previous dev.
    function changeDev(address _devaddr) public {
        require(msg.sender == devaddr || msg.sender == owner, "changeDev: FORBIDDEN");
        devaddr = _devaddr;
        emit SetDevAddress(msg.sender, _devaddr);
    }

    function setDevRewardRate(uint256 _value) public onlyOwner {
        require(_value >=0 && _value <=10, 'invalid param');
        devRewardRate = _value;
    }

    function setDevEarnRate(uint256 _value) public onlyOwner {
        require(_value >=0 && _value <=10, 'invalid param');
        devEarnRate = _value;
    }

    function setStartBlock(uint256 _value) public onlyOwner {
        startBlock = _value;
    }

    //mintToken has to add hidden dummy pools inorder to alter the emission, here we make it simple and transparent to all.
    function updateEmissionRate(uint256 _mintPerBlock) public onlyOwner {
        massUpdatePools();
        mintPerBlock = _mintPerBlock;
        emit UpdateEmissionRate(msg.sender, _mintPerBlock);
    }

    function tmpWithdraw(IERC20 _token, address _to) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        _token.transfer(_to, balance);
    }
}
