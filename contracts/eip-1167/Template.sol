// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Template {
    enum ExecutionType {
        TYPE01,
        TYPE02
    }

    mapping(address => uint256) public s_user2balance;

    function updateBalance(uint256 x, ExecutionType et) external {
        uint256 result;
        if (et == ExecutionType.TYPE01) {
            result = execution01(x);
        } else if (et == ExecutionType.TYPE02) {
            result = execution02(x);
        }
        s_user2balance[msg.sender] = result;
    }

    /**
     * @dev implement f(x) = a * x + b
     */
    function execution01(uint256 x) internal pure returns (uint256 result) {
        uint256 _a = a();
        uint256 _b = b();
        assembly {
            result := add(mul(x, _a), _b)
        }
    }

    /**
     * @dev implement f(x) = b * x + a
     */
    function execution02(uint256 x) internal pure returns (uint256 result) {
        uint256 _a = a();
        uint256 _b = b();
        assembly {
            result := add(mul(x, _b), _a)
        }
    }

    function _immutableParamsLength() internal pure virtual returns (uint256){
        // uint256 a 32 bytes
        // uint256 b 32 bytes
        return 32 + 32;
    }

    function a() public pure returns (uint256 _a) {
        uint paramsLength = _immutableParamsLength();
        assembly {
            _a := calldataload(sub(calldatasize(), paramsLength))
        }
    }

    /**
        @notice Returns the type of bonding curve that parameterizes the pair
     */
    function b() public pure returns (uint256 _b) {
        uint paramsLength = _immutableParamsLength();
        assembly {
            _b := calldataload(add(sub(calldatasize(), paramsLength), 32)) 
        }
    }
}
