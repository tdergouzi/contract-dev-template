pragma solidity 0.5.12;

import "./SafeMath.sol";

contract Counter {
    using SafeMath for uint256;

    uint256 count = 0;
    address public owner;

    event CountedTo(uint256 number);
    
    constructor(uint256 _count, address _owner) public {
        count = _count;
        owner = _owner;
    }

    function countUp() public {
        count = count.add(1);
        emit CountedTo(count);
    }

    function countDown() public {
        count = count.sub(1);
        emit CountedTo(count);
    }

    function getCount() public view returns (uint256) {
        return count;
    }
}