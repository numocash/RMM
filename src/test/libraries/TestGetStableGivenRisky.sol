// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "../../libraries/ReplicationMath.sol";
// import "forge-std/console.sol";

// /// @title   Test Get base Given quote
// /// @author  Primitive
// /// @dev     Tests each step in ReplicationMath.getbaseGivenquote. For testing ONLY

// contract TestGetBaseGivenQuote {
//     using ABDKMath64x64 for int128;
//     using ABDKMath64x64 for uint256;
//     using CumulativeNormalDistribution for int128;
//     using Units for int128;
//     using Units for uint256;

//     uint256 public scaleFactorQuote;
//     uint256 public scaleFactorBase;

//     function set(uint256 prec0, uint256 prec1) public {
//         scaleFactorQuote = prec0;
//         scaleFactorBase = prec1;
//     }

//     function PRECISION() public pure returns (uint256) {
//         return Units.PRECISION;
//     }

//     function step0(uint256 strike) public view returns (int128 K) {
//         K = strike.scaleToX64(scaleFactorBase);
//     }

//     function step1(uint256 sigma, uint256 tau) public pure returns (int128 vol) {
//         vol = ReplicationMath.getProportionalVolatility(sigma, tau);
//     }

//     function step2(uint256 reserveQuote) public view returns (int128 reserve) {
//         reserve = reserveQuote.scaleToX64(scaleFactorQuote);
//     }

//     function step3(int128 reserve) public pure returns (int128 phi) {
//         console.log("reserve", reserve);
//         phi = ReplicationMath.ONE_INT.sub(reserve).getInverseCDF(); // CDF^-1(1-x)
//         console.log("CDF^1-1(1-x)", phi);
//     }

//     function step4(int128 phi, int128 vol) public pure returns (int128 input) {
//         console.log("phi", phi);
//         console.log("vol", vol);
//         input = phi.sub(vol); // phi - vol
//         console.log("phi-vol:", input);
//     }

//     function step5(
//         int128 K,
//         int128 input,
//         int128 invariantLast
//     ) public pure returns (int128 reserveBase) {
//         reserveBase = K.mul(input.getCDF()).add(invariantLast);
//     }

//     function testStep3(uint256 reserve) public view returns (int128 phi) {
//         phi = ReplicationMath.ONE_INT.sub(reserve.scaleToX64(scaleFactorQuote)).getInverseCDF();
//     }

//     function testStep4(
//         uint256 reserve,
//         uint256 sigma,
//         uint256 tau
//     ) public view returns (int128 input) {
//         int128 phi = testStep3(reserve);
//         int128 vol = step1(sigma, tau);
//         input = phi.sub(vol);
//     }

//     function testStep5(
//         uint256 reserve,
//         uint256 strike,
//         uint256 sigma,
//         uint256 tau
//     ) public view returns (int128 reserveBase) {
//         require(strike > 0, "Strike must be greater than zero");
//         require(scaleFactorBase > 0, "Scale factor base must be greater than zero");

//         int128 input = testStep4(reserve, sigma, tau);
//         console.log("Input:", ABDKMath64x64.toUInt(input));

//         int128 scaledStrike = strike.scaleToX64(scaleFactorBase);
//         console.log("Scaled strike:", ABDKMath64x64.toUInt(scaledStrike));

//         int128 cdf = input.getCDF();
//         console.log("CDF:", ABDKMath64x64.toUInt(cdf));

//         require(cdf != 0, "CDF is zero");

//         reserveBase = scaledStrike.mul(cdf);
//         console.log("Reserve base:", ABDKMath64x64.toUInt(reserveBase));
//     }

//     /// @return reserveBase The calculated base reserve, using the quote reserve
//     function getbaseGivenQuote(
//         int128 invariantLast,
//         uint256 precBase,
//         uint256 reserveQuote,
//         uint256 strike,
//         uint256 sigma,
//         uint256 tau
//     ) public view returns (int128 reserveBase) {
//         precBase;
//         int128 K = step0(strike);
//         int128 input;
//         {
//             int128 vol = step1(sigma, tau);
//             int128 reserve = step2(reserveQuote);
//             int128 phi = step3(reserve);
//             input = step4(phi, vol);
//         }
//         reserveBase = step5(K, input, invariantLast);
//     }

//     function name() public pure returns (string memory) {
//         return "TestGetbaseGivenQuote";
//     }
// }
