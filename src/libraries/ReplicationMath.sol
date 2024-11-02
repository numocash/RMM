// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "./ABDKMath64x64.sol";
import "./CumulativeNormalDistribution.sol";
import "./Units.sol";

/// @title   Replication Math
/// @author  Primitive
/// @notice  Alex Evans, Guillermo Angeris, and Tarun Chitra. Replicating Market Makers.
///          https://stanford.edu/~guillean/papers/rmms.pdf
library ReplicationMath {
    using ABDKMath64x64 for int128;
    using ABDKMath64x64 for uint256;
    using CumulativeNormalDistribution for int128;
    using Units for int128;
    using Units for uint256;

    int128 internal constant ONE_INT = 0x10000000000000000;

    /// @notice         Normalizes volatility with respect to square root of time until expiry
    /// @param   sigma  Unsigned 256-bit percentage as an integer with precision of 1e4, 10000 = 100%
    /// @param   tau    Time until expiry in seconds as an unsigned 256-bit integer
    /// @return  vol    Signed fixed point 64.64 number equal to sigma * sqrt(tau)
    function getProportionalVolatility(uint256 sigma, uint256 tau) internal pure returns (int128 vol) {
        int128 sqrtTauX64 = tau.toYears().sqrt();
        int128 sigmaX64 = sigma.percentageToX64();
        vol = sigmaX64.mul(sqrtTauX64);
    }

    /// @notice                 Uses quotePerLiquidity and invariant to calculate basePerLiquidity
    /// @dev                    Converts unsigned 256-bit values to fixed point 64.64 numbers w/ decimals of precision
    /// @param   invariantLastX64   Signed 64.64 fixed point number. Calculated w/ same `tau` as the parameter `tau`
    /// @param   scaleFactorQuote   Unsigned 256-bit integer scaling factor for `quote`, 10^(18 - quote.decimals())
    /// @param   scaleFactorBase  Unsigned 256-bit integer scaling factor for `base`, 10^(18 - base.decimals())
    /// @param   quotePerLiquidity  Unsigned 256-bit integer of Pool's quote reserves *per liquidity*, 0 <= x <= 1
    /// @param   strike         Unsigned 256-bit integer value with precision equal to 10^(18 - scaleFactorBase)
    /// @param   sigma          Volatility of the Pool as an unsigned 256-bit integer w/ precision of 1e4, 10000 = 100%
    /// @param   tau            Time until expiry in seconds as an unsigned 256-bit integer
    /// @return  basePerLiquidity = K*CDF(CDF^-1(1 - quotePerLiquidity) - sigma*sqrt(tau)) + invariantLastX64 as uint
    function getBaseGivenQuote(
        int128 invariantLastX64,
        uint256 scaleFactorQuote,
        uint256 scaleFactorBase,
        uint256 quotePerLiquidity,
        uint256 strike,
        uint256 sigma,
        uint256 tau
    ) internal pure returns (uint256 basePerLiquidity) {
        int128 strikeX64 = strike.scaleToX64(scaleFactorBase);
        int128 quoteX64 = quotePerLiquidity.scaleToX64(scaleFactorQuote); // mul by 2^64, div by precision
        int128 oneMinusQuoteX64 = ONE_INT.sub(quoteX64);
        if (tau != 0) {
            int128 volX64 = getProportionalVolatility(sigma, tau);
            int128 phi = oneMinusQuoteX64.getInverseCDF();
            int128 input = phi.sub(volX64);
            int128 baseX64 = strikeX64.mul(input.getCDF()).add(invariantLastX64);
            basePerLiquidity = baseX64.scaleFromX64(scaleFactorBase);
        } else {
            basePerLiquidity = (strikeX64.mul(oneMinusQuoteX64).add(invariantLastX64)).scaleFromX64(
                scaleFactorBase
            );
        }
    }

    /// @notice                 Calculates the invariant of a curve
    /// @dev                    Per unit of replication, aka per unit of liquidity
    /// @param   scaleFactorQuote   Unsigned 256-bit integer scaling factor for `quote`, 10^(18 - quote.decimals())
    /// @param   scaleFactorBase  Unsigned 256-bit integer scaling factor for `base`, 10^(18 - base.decimals())
    /// @param   quotePerLiquidity  Unsigned 256-bit integer of Pool's quote reserves *per liquidity*, 0 <= x <= 1
    /// @param   basePerLiquidity Unsigned 256-bit integer of Pool's base reserves *per liquidity*, 0 <= x <= strike
    /// @return  invariantX64       = basePerLiquidity - K * CDF(CDF^-1(1 - quotePerLiquidity) - sigma * sqrt(tau))
    function calcInvariant(
        uint256 scaleFactorQuote,
        uint256 scaleFactorBase,
        uint256 quotePerLiquidity,
        uint256 basePerLiquidity,
        uint256 strike,
        uint256 sigma,
        uint256 tau
    ) internal pure returns (int128 invariantX64) {
        uint256 output = getBaseGivenQuote(
            0,
            scaleFactorQuote,
            scaleFactorBase,
            quotePerLiquidity,
            strike,
            sigma,
            tau
        );
        int128 outputX64 = output.scaleToX64(scaleFactorBase);
        int128 baseX64 = basePerLiquidity.scaleToX64(scaleFactorBase);
        invariantX64 = baseX64.sub(outputX64);
    }
}
