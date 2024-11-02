// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5.0;

/// @title  Create Callback
/// @author Primitive
interface ICreateCallback {
    /// @notice              Triggered when creating a new pool for an Engine
    /// @param  delQuote     Amount of quote tokens required to initialize quote reserve
    /// @param  delBase    Amount of base tokens required to initialize base reserve
    /// @param  data         Calldata passed on create function call
    function createCallback(
        uint256 delQuote,
        uint256 delBase,
        bytes calldata data
    ) external;
}
