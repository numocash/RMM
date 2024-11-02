// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "../../crytic/Echidnaengine.sol";

// contract EchidnaMockEngine is EchidnaEngine {
//     uint256 public time = 1;

//     constructor(address _quote, address _base, uint256 _scaleFactorquote, uint256 _scaleFactorbase, uint256 _min_liquidity) public Echidnaengine(_quote, _base, _scaleFactorquote, _scaleFactorbase, _min_liquidity)
//             {}

//     function advanceTime(uint256 by) external {
//         time += by;
//     }

//     function _blockTimestamp() internal view override returns (uint32 blockTimestamp) {
//         blockTimestamp = uint32(time);
//     }

//     function setReserves(
//         bytes32 poolId,
//         uint256 reservequote,
//         uint256 reservebase
//     ) public {
//         Reserve.Data storage res = reserves[poolId];
//         res.reservequote = SafeCast.toUint128(reservequote);
//         res.reservebase = SafeCast.toUint128(reservebase);
//     }

//     function updateReserves(bytes32 poolId, uint256 reservequote) public {
//         Reserve.Data storage res = reserves[poolId];
//         Calibration memory cal = calibrations[poolId];
//         (uint256 curquote, uint256 curbase) = (res.reservequote, res.reservebase);
//         int128 invariant = invariantOf(poolId);
//         res.reservequote = SafeCast.toUint128(reservequote);
//         uint256 reservebase = ReplicationMath.getbaseGivenquote(
//             invariant,
//             scaleFactorquote,
//             scaleFactorbase,
//             reservequote,
//             cal.strike,
//             cal.sigma,
//             cal.maturity - cal.lastTimestamp
//         );
//         res.reservebase = SafeCast.toUint128(reservebase);
//         (uint256 nextquote, uint256 nextbase) = (res.reservequote, res.reservebase);

//         {
//             uint256 quoteDeficit = nextquote > curquote ? nextquote - curquote : 0;
//             uint256 quoteSurplus = nextquote > curquote ? 0 : curquote - nextquote;

//             uint256 baseDeficit = nextbase > curbase ? nextbase - curbase : 0;
//             uint256 baseSurplus = nextbase > curbase ? 0 : curbase - nextbase;
//             IERC20(quote).transfer(msg.sender, quoteSurplus);
//             IERC20(quote).transferFrom(msg.sender, address(this), quoteDeficit);

//             IERC20(base).transfer(msg.sender, baseSurplus);
//             IERC20(base).transferFrom(msg.sender, address(this), baseDeficit);
//         }
//     }
// }
