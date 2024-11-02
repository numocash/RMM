// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5.0;

/// @title  Swap Callback
/// @author Primitive
interface ISwapCallback {
    /// @notice              Triggered when swapping tokens in an Engine
    /// @param  delQuote     Amount of quote tokens required to pay the swap with
    /// @param  delBase    Amount of base tokens required to pay the swap with
    /// @param  data         Calldata passed on swap function call
    function swapCallback(
        uint256 delQuote,
        uint256 delBase,
        bytes calldata data
    ) external;
}
