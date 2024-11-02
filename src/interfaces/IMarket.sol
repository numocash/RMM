// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.4;

import "./market/IMarketActions.sol";
import "./market/IMarketEvents.sol";
import "./market/IMarketView.sol";
import "./market/IMarketErrors.sol";

/// @title Market Interface
interface IMarket is
    IMarketActions,
    IMarketEvents,
    IMarketView,
    IMarketErrors
{

}
