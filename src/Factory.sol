// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import {Market} from "./Market.sol";

contract Factory {
    event NewPortfolio(address indexed caller, address indexed portfolio, string name, string symbol);

    address public immutable WETH;

    address[] public portfolios;

    constructor(address weth_) {
        WETH = weth_;
    }

    function createNumo(string memory portfolioName, string memory portfolioSymbol, uint256 sigma, uint256 fee)
        external
        returns (Numo)
    {
        Numo numo = new Market(portfolioName, portfolioSymbol, sigma, fee);
        emit NewPortfolio(msg.sender, address(numo), portfolioName, portfolioSymbol);
        portfolios.push(address(numo));
        return numo;
    }
}
