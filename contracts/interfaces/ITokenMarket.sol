// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ITokenMarket {
    function addSellConf() external;

    function updateSellConf() external;

    function cancelSell() external;

    function buyToken(address _token, address _amount) external;
}
