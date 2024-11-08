// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import "./SafeCast.sol";

/// @title   Margin Library
/// @author  Primitive
/// @dev     Uses a data struct with two uint128s to optimize for one storage slot
library Margin {
    using SafeCast for uint256;

    struct Data {
        uint128 balanceQuote; // Balance of the quote token, aka underlying asset
        uint128 balanceBase; // Balance of the base token, aka "quote" asset
    }

    /// @notice             Adds to quote and base token balances
    /// @param  margin      Margin data of an account in storage to manipulate
    /// @param  delQuote    Amount of quote tokens to add to margin
    /// @param  delBase   Amount of base tokens to add to margin
    function deposit(
        Data storage margin,
        uint256 delQuote,
        uint256 delBase
    ) internal {
        if (delQuote != 0) margin.balanceQuote += delQuote.toUint128();
        if (delBase != 0) margin.balanceBase += delBase.toUint128();
    }

    /// @notice             Removes quote and base token balance from `msg.sender`'s internal margin account
    /// @param  margins     Margin data mapping, uses `msg.sender`'s margin account
    /// @param  delQuote    Amount of quote tokens to subtract from margin
    /// @param  delBase   Amount of base tokens to subtract from margin
    /// @return margin      Data storage of a margin account
    function withdraw(
        mapping(address => Data) storage margins,
        uint256 delQuote,
        uint256 delBase
    ) internal returns (Data storage margin) {
        margin = margins[msg.sender];
        if (delQuote != 0) margin.balanceQuote -= delQuote.toUint128();
        if (delBase != 0) margin.balanceBase -= delBase.toUint128();
    }
}
