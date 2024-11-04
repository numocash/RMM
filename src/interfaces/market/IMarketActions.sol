// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.5.0;

/// @title  Action functions for the Engine contract
/// @author Primitive
interface IMarketActions {
    // ===== Pool Updates =====

    /// @notice             Updates the time until expiry of the pool by setting its last timestamp value
    /// @param  poolId      Keccak256 hash of engine address, strike, sigma, maturity, and gamma
    /// @return lastTimestamp Timestamp loaded into the state of the pool's Calibration.lastTimestamp
    function updateLastTimestamp(bytes32 poolId) external returns (uint32 lastTimestamp);

    /// @notice             Initializes a curve with parameters in the `calibrations` storage mapping in the Engine
    /// @param  strike      Marginal price of the pool's quote token at maturity, with the same decimals as the base token, valid [0, 2^128-1]
    /// @param  sigma       AKA Implied Volatility in basis points, determines the price impact of swaps, valid for (1, 10_000_000)
    /// @param  maturity    Timestamp which starts the BUFFER countdown until swaps will cease, in seconds, valid for (block.timestamp, 2^32-1]
    /// @param  gamma       Multiplied against swap in amounts to apply fee, equal to 1 - fee % but units are in basis points, valid for (9_000, 10_000)
    /// @param  quotePerBase  quote reserve per liq. with quote decimals, = 1 - N(d1), d1 = (ln(S/K)+(r*σ^2/2))/σ√τ, valid for [0, 1e^(quote token decimals))
    /// @param  delLiquidity Amount of liquidity units to allocate to the curve, wei value with 18 decimals of precision
    /// @param  data        Arbitrary data that is passed to the createCallback function
    /// @return poolId      Keccak256 hash of engine address, strike, sigma, maturity, and gamma
    /// @return delQuote    Total amount of quote tokens provided to reserves
    /// @return delBase   Total amount of base tokens provided to reserves
    function create(
        uint128 strike,
        uint32 sigma,
        uint32 maturity,
        uint32 gamma,
        uint256 quotePerBase,
        uint256 delLiquidity,
        bytes calldata data
    )
        external
        returns (
            bytes32 poolId,
            uint256 delQuote,
            uint256 delBase
        );

    // ===== Margin ====

    /// @notice             Adds quote and/or base tokens to a `recipient`'s internal balance account
    /// @param  recipient   Recipient margin account of the deposited tokens
    /// @param  delQuote    Amount of quote tokens to deposit
    /// @param  delBase   Amount of base tokens to deposit
    /// @param  data        Arbitrary data that is passed to the depositCallback function
    function deposit(
        address recipient,
        uint256 delQuote,
        uint256 delBase,
        bytes calldata data
    ) external;

    /// @notice             Removes quote and/or base tokens from a `msg.sender`'s internal balance account
    /// @param  recipient   Address that tokens are transferred to
    /// @param  delQuote    Amount of quote tokens to withdraw
    /// @param  delBase   Amount of base tokens to withdraw
    function withdraw(
        address recipient,
        uint256 delQuote,
        uint256 delBase
    ) external;

    // ===== Liquidity =====

    /// @notice             Allocates quote and base tokens to a specific curve with `poolId`
    /// @param  poolId      Keccak256 hash of engine address, strike, sigma, maturity, and gamma
    /// @param  recipient   Address to give the allocated liquidity to
    /// @param  delQuote    Amount of quote tokens to add
    /// @param  delBase   Amount of base tokens to add
    /// @param  fromMargin  Whether the `msg.sender` pays with their margin balance, or must send tokens
    /// @param  data        Arbitrary data that is passed to the allocateCallback function
    /// @return delLiquidity Amount of liquidity given to `recipient`
    function allocate(
        bytes32 poolId,
        address recipient,
        uint256 delQuote,
        uint256 delBase,
        bool fromMargin,
        bytes calldata data
    ) external returns (uint256 delLiquidity);

    /// @notice               Unallocates quote and base tokens from a specific curve with `poolId`
    /// @param  poolId        Keccak256 hash of engine address, strike, sigma, maturity, and gamma
    /// @param  delLiquidity  Amount of liquidity to remove
    /// @return delQuote      Amount of quote tokens received from removed liquidity
    /// @return delBase     Amount of base tokens received from removed liquidity
    function remove(bytes32 poolId, uint256 delLiquidity) external returns (uint256 delQuote, uint256 delBase);

    // ===== Swaps =====

    /// @notice             Swaps between `quote` and `base` tokens
    /// @param  recipient   Address that receives output token `deltaOut` amount
    /// @param  poolId      Keccak256 hash of engine address, strike, sigma, maturity, and gamma
    /// @param  quoteForBase If true, swap quote to base, else swap base to quote
    /// @param  deltaIn     Amount of tokens to swap in
    /// @param  deltaOut    Amount of tokens to swap out
    /// @param  fromMargin  Whether the `msg.sender` uses their margin balance, or must send tokens
    /// @param  toMargin    Whether the `deltaOut` amount is transferred or deposited into margin
    /// @param  data        Arbitrary data that is passed to the swapCallback function
    function swap(
        address recipient,
        bytes32 poolId,
        bool quoteForBase,
        uint256 deltaIn,
        uint256 deltaOut,
        bool fromMargin,
        bool toMargin,
        bytes calldata data
    ) external;
}
