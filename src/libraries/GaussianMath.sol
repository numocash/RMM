// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Gaussian} from "lib/solidity-cdf/src/Gaussian.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

/// @title GaussianMath Library
/// @notice Mathematical functions for Gaussian (Normal) distribution calculations
/// @dev Builds on solidity-cdf for core functions and adds additional gaussian calculations
/// @custom:coauthor @transmissions11 - Fixed point math patterns
library GaussianMath {
    using FixedPointMathLib for int256;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/

    int256 internal constant ONE = 1e18;
    int256 internal constant TWO = 2e18;
    int256 internal constant SQRT_2PI = 2_506628274631000502;  // √(2π) * 1e18
    int256 internal constant NEGATIVE_EIGHT = -8e18;
    int256 internal constant POSITIVE_EIGHT = 8e18;
    uint256 internal constant PRECISION_THRESHOLD = 1e8;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error PPF_INPUT_TOO_LOW();
    error PPF_INPUT_TOO_HIGH();

    /*//////////////////////////////////////////////////////////////
                            GAUSSIAN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Computes the Percent Point Function (Inverse CDF)
    /// @dev Uses binary search with configurable precision
    /// @param p Probability value in WAD
    /// @return Inverse CDF value in WAD
    function ppf(int256 p) public pure returns (int256) {
        if (p <= 0) revert PPF_INPUT_TOO_LOW();
        if (p >= ONE) revert PPF_INPUT_TOO_HIGH();
        
        int256 left = NEGATIVE_EIGHT;
        int256 right = POSITIVE_EIGHT;
        int256 mid;
        
        for (uint256 i = 0; i < 128; i++) {
            mid = (left + right) / 2;
            uint256 cdfValue = Gaussian.cdf(mid, 0, ONE);
            
            if (abs(int256(cdfValue) - p) < PRECISION_THRESHOLD) {
                return mid;
            }
            
            if (int256(cdfValue) < p) {
                left = mid;
            } else {
                right = mid;
            }
        }
        return mid;
    }

    /// @notice Computes the Probability Density Function
    /// @dev Uses the standard normal PDF formula: (1/√(2π)) * e^(-x²/2)
    /// @param x Input value in WAD
    /// @return PDF value in WAD
    function pdf(int256 x) public pure returns (int256) {
        int256 xSquared = (x * x) / ONE;
        int256 exponent = (-xSquared / 2);
        return (ONE * exponent.expWad()) / SQRT_2PI;
    }

    /// @notice Computes the Standard Normal CDF
    /// @dev Wrapper around solidity-cdf's Gaussian.cdf
    /// @param x Input value in WAD
    /// @return CDF value in WAD
    function cdf(int256 x) public pure returns (uint256) {
        return Gaussian.cdf(x, 0, ONE);
    }

    /// @notice Computes the Error Function
    /// @dev erf(x) = 1 - erfc(x)
    /// @param x Input value in WAD
    /// @return Error function value in WAD
    function erf(int256 x) public pure returns (int256) {
        return ONE - int256(Gaussian.erfc(x));
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Computes absolute value
    /// @param x Input value
    /// @return Absolute value
    function abs(int256 x) internal pure returns (int256) {
        return x < 0 ? -x : x;
    }

    /// @notice Converts an unsigned integer to signed
    /// @param x Unsigned integer
    /// @return Signed integer
    function toInt(uint256 x) internal pure returns (int256) {
        require(x <= uint256(type(int256).max), "INT_OVERFLOW");
        return int256(x);
    }

    /// @notice Converts a signed integer to unsigned
    /// @param x Signed integer
    /// @return Unsigned integer
    function toUint(int256 x) internal pure returns (uint256) {
        require(x >= 0, "NEGATIVE_VALUE");
        return uint256(x);
    }
} 