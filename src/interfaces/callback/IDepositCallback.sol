// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5.0;

/// @title  Deposit Callback
/// @author Primitive
interface IDepositCallback {
    /// @notice              Triggered when depositing tokens to an Engine
    /// @param  delQuote     Amount of quote tokens required to deposit to quote margin balance
    /// @param  delBase    Amount of base tokens required to deposit to base margin balance
    /// @param  data         Calldata passed on deposit function call
    function depositCallback(
        uint256 delQuote,
        uint256 delBase,
        bytes calldata data
    ) external;
}
