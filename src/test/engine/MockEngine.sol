// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "../../Engine.sol";

// contract MockEngine is Engine {
//     uint256 public time = 1;

//     function advanceTime(uint256 by) external {
//         time += by;
//     }

//     function _blockTimestamp() internal view override returns (uint32 blockTimestamp) {
//         blockTimestamp = uint32(time);
//     }

//     function setReserves(
//         bytes32 poolId,
//         uint256 reserveQuote,
//         uint256 reserveBase
//     ) public {
//         Reserve.Data storage res = reserves[poolId];
//         res.reserveQuote = SafeCast.toUint128(reserveQuote);
//         res.reserveBase = SafeCast.toUint128(reserveBase);
//     }

//     function updateReserves(bytes32 poolId, uint256 reserveQuote) public {
//         Reserve.Data storage res = reserves[poolId];
//         Calibration memory cal = calibrations[poolId];
//         (uint256 curQuote, uint256 curBase) = (res.reserveQuote, res.reserveBase);
//         int128 invariant = invariantOf(poolId);
//         res.reserveQuote = SafeCast.toUint128(reserveQuote);
//         uint256 reserveBase = ReplicationMath.getBaseGivenQuote(
//             invariant,
//             scaleFactorQuote,
//             scaleFactorBase,
//             reserveQuote,
//             cal.strike,
//             cal.sigma,
//             cal.maturity - cal.lastTimestamp
//         );
//         res.reserveBase = SafeCast.toUint128(reserveBase);
//         (uint256 nextQuote, uint256 nextBase) = (res.reserveQuote, res.reserveBase);

//         {
//             uint256 quoteDeficit = nextQuote > curQuote ? nextQuote - curQuote : 0;
//             uint256 quoteSurplus = nextQuote > curQuote ? 0 : curQuote - nextQuote;

//             uint256 baseDeficit = nextBase > curBase ? nextBase - curBase : 0;
//             uint256 baseSurplus = nextBase > curBase ? 0 : curBase - nextBase;
//             IERC20(quote).transfer(msg.sender, quoteSurplus);
//             IERC20(quote).transferFrom(msg.sender, address(this), quoteDeficit);

//             IERC20(base).transfer(msg.sender, baseSurplus);
//             IERC20(base).transferFrom(msg.sender, address(this), baseDeficit);
//         }
//     }
// }
