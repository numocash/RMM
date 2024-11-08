// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import {Market} from "./Market.sol";

contract Factory {
    event NewPool(address indexed caller, address indexed pool, string name, string symbol);

    address public immutable WETH;

    address[] public pools;

    constructor(address weth_) {
        WETH = weth_;
    }

    function createMarket(string memory poolName, string memory poolSymbol, uint256 sigma, uint256 fee)
        external
        returns (Market)
    {
        Market option = new Market(poolName, poolSymbol, sigma, fee);
        emit NewPool(msg.sender, address(option), poolName, poolSymbol);
        pools.push(address(option));
        return option;
    }
}
