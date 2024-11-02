// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5.0;

/// @title  Liquidity Callback
/// @author Primitive
interface ILiquidityCallback {
    /// @notice              Triggered when providing liquidity to an Engine
    /// @param  delQuote     Amount of quote tokens required to provide to quote reserve
    /// @param  delBase    Amount of base tokens required to provide to base reserve
    /// @param  data         Calldata passed on allocate function call
    function allocateCallback(
        uint256 delQuote,
        uint256 delBase,
        bytes calldata data
    ) external;
}
