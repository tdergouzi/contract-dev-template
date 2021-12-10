// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

import "./interfaces/IERC20.sol";
import "./libraries/EnumerableSet.sol";
import "./libraries/SafeMath.sol";
import "./modules/Initializable.sol";

contract TokenMarket is Initializable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    address public owner;

    struct SellConf {
        address seller;
        address sellToken;
        address payToken;
        uint256 price;
        uint256 totalAmount;
    }

    SellConf[] public sellConfs;
    mapping(address => EnumerableSet.UintSet) userToConfs;

    modifier onlyOwner() {
        require(msg.sender == owner, 'TM: NOT_OWNER');
        _;
    }

    receive() external payable {
    }

    function initialize() external initializer {
        owner = msg.sender;
    }

    function addSellConf() external {

    }

    function updateSellConf() external {

    }

    function cancelSell() external {

    }

    function buyToken(address _token, address _amount) external {

    }
}