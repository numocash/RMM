// // SPDX-License-Identifier: GPL-3.0-only
// pragma solidity 0.8.20;

// // import "../../libraries/ReplicationMath.sol";

// // /// @title   ReplicationMath Lib API Test
// // /// @author  Primitive
// // /// @dev     For testing purposes ONLY

// // contract TestCalcInvariant {
// //     using ABDKMath64x64 for int128;
// //     using ABDKMath64x64 for uint256;
// //     using CumulativeNormalDistribution for int128;
// //     using Units for int128;
// //     using Units for uint256;

// //     uint256 public scaleFactorQuote;
// //     uint256 public scaleFactorBase;

// //     function set(uint256 prec0, uint256 prec1) public {
// //         scaleFactorQuote = prec0;
// //         scaleFactorBase = prec1;
// //     }

// //     function step0(
// //         uint256 reserveQuote,
// //         uint256 strike,
// //         uint256 sigma,
// //         uint256 tau
// //     ) public view returns (int128 reserve2) {
// //         reserve2 = ReplicationMath
// //             .getBaseGivenQuote(0, scaleFactorQuote, scaleFactorBase, reserveQuote, strike, sigma, tau)
// //             .scaleToX64(scaleFactorBase);
// //     }

// //     function step1(uint256 reserveBase, int128 reserve2) public view returns (int128 invariant) {
// //         invariant = reserveBase.scaleToX64(scaleFactorBase).sub(reserve2);
// //     }

// //     /// @return invariant Uses the trading function to calculate the invariant, which starts at 0 and grows with fees
// //     function calcInvariantQuote(
// //         uint256 reserveQuote,
// //         uint256 reserveBase,
// //         uint256 strike,
// //         uint256 sigma,
// //         uint256 tau
// //     ) public view returns (int128 invariant) {
// //         int128 reserve2 = step0(reserveQuote, strike, sigma, tau);
// //         invariant = step1(reserveBase, reserve2);
// //     }

// //     function calcInvariantBase(
// //         uint256 reserveQuote,
// //         uint256 reserveBase,
// //         uint256 strike,
// //         uint256 sigma,
// //         uint256 tau
// //     ) public view returns (int128 invariant) {
// //         int128 reserve2 = step0(reserveQuote, strike, sigma, tau);
// //         invariant = step1(reserveBase, reserve2);
// //     }
// // }
