// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.4;

/// @title  Errors for the Primitive Engine contract
/// @author Primitive
/// @notice Custom errors are encoded with their selector and arguments
/// @dev    Peripheral smart contracts should try catch and check if data matches another custom error
interface IMarketErrors {
    /// @notice Thrown on attempted re-entrancy on a function with a re-entrancy guard
    error LockedError();

    /// @notice Thrown when the balanceOf function is not successful and does not return data
    error BalanceError();

    /// @notice Thrown in create when a pool with computed poolId already exists
    error PoolDuplicateError();

    /// @notice Thrown when calling an expired pool, where block.timestamp > maturity, + BUFFER if swap
    error PoolExpiredError();

    /// @notice Thrown when liquidity is lower than or equal to the minimum amount of liquidity
    error MinLiquidityError(uint256 value);

    /// @notice Thrown when quotePerLp is outside the range of acceptable values, 0 < quotePerLp <= 1equoteDecimals
    error quotePerLpError(uint256 value);

    /// @notice Thrown when sigma is outside the range of acceptable values, 1 <= sigma <= 1e7 with 4 precision
    error SigmaError(uint256 value);

    /// @notice Thrown when strike is not valid, i.e. equal to 0 or greater than 2^128
    error StrikeError(uint256 value);

    /// @notice Thrown when gamma, equal to 1 - fee %, is outside its bounds: 9_000 <= gamma <= 10_000; 1_000 = 10% fee
    error GammaError(uint256 value);

    /// @notice Thrown when the parameters of a new pool are invalid, causing initial reserves to be 0
    error CalibrationError(uint256 delquote, uint256 delbase);

    /// @notice         Thrown when the expected quote balance is less than the actual balance
    /// @param expected Expected quote balance
    /// @param actual   Actual quote balance
    error quoteBalanceError(uint256 expected, uint256 actual);

    /// @notice         Thrown when the expected base balance is less than the actual balance
    /// @param expected Expected base balance
    /// @param actual   Actual base balance
    error baseBalanceError(uint256 expected, uint256 actual);

    /// @notice Thrown when the pool with poolId has not been created
    error UninitializedError();

    /// @notice Thrown when the quote or base amount is 0
    error ZeroDeltasError();

    /// @notice Thrown when the liquidity parameter is 0
    error ZeroLiquidityError();

    /// @notice Thrown when the deltaIn parameter is 0
    error DeltaInError();

    /// @notice Thrown when the deltaOut parameter is 0
    error DeltaOutError();

    /// @notice                 Thrown when the invariant check fails
    /// @dev                    Most important check as it verifies the validity of a desired swap
    /// @param  invariant       Pre-swap invariant updated with new tau
    /// @param  nextInvariant   Post-swap invariant after the swap amounts are applied to reserves
    error InvariantError(int128 invariant, int128 nextInvariant);
}
