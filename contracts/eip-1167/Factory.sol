// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Factory {
    function create(
        address implementation,
        uint256 a,
        uint256 b
    ) external returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(
                ptr,
                0x60753d8160093d39f33d3d3d3d363d3d37604060353639604036013d73000000
            )
            mstore(add(ptr, 0x1d), shl(0x60, implementation))
            mstore(
                add(ptr, 0x31),
                0x5af43d3d93803e603357fd5bf300000000000000000000000000000000000000
            )
            mstore(add(ptr, 0x3e), a)
            mstore(add(ptr, 0x5e), b)
            instance := create(0, ptr, 0x7e)
        }
    }
}
