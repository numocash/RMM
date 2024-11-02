// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "../../libraries/ReplicationMath.sol";
// import "../../libraries/Units.sol";

// /// @title   ReplicationMath Lib API Test
// /// @author  Primitive
// /// @dev     For testing purposes ONLY

// contract TestReplicationMath {
//     using Units for uint256;
//     uint256 public scaleFactorQuote;
//     uint256 public scaleFactorBase;

//     function set(uint256 prec0, uint256 prec1) public {
//         scaleFactorQuote = prec0;
//         scaleFactorBase = prec1;
//     }

//     /// @return vol The sigma * sqrt(tau)
//     function getProportionalVolatility(uint256 sigma, uint256 tau) public pure returns (int128 vol) {
//         vol = ReplicationMath.getProportionalVolatility(sigma, tau);
//     }

//     /// @return reserveBase The calculated base reserve, using the quote reserve
//     function getBaseGivenQuote(
//         int128 invariantLast,
//         uint256 reserveQuote,
//         uint256 strike,
//         uint256 sigma,
//         uint256 tau
//     ) public view returns (int128 reserveBase) {
//         reserveBase = ReplicationMath
//             .getBaseGivenQuote(invariantLast, scaleFactorQuote, scaleFactorBase, reserveQuote, strike, sigma, tau)
//             .scaleToX64(scaleFactorBase);
//     }

//     /// @return invariant Uses the trading function to calculate the invariant, which starts at 0 and grows with fees
//     function calcInvariant(
//         uint256 reserveQuote,
//         uint256 reserveBase,
//         uint256 strike,
//         uint256 sigma,
//         uint256 tau
//     ) public view returns (int128 invariant) {
//         invariant = ReplicationMath.calcInvariant(
//             scaleFactorQuote,
//             scaleFactorBase,
//             reserveQuote,
//             reserveBase,
//             strike,
//             sigma,
//             tau
//         );
//     }

//     function YEAR() public pure returns (uint256) {
//         return Units.YEAR;
//     }

//     function PRECISION() public pure returns (uint256) {
//         return Units.PRECISION;
//     }

//     function PERCENTAGE() public pure returns (uint256) {
//         return Units.PERCENTAGE;
//     }
// }
