pragma solidity 0.8.20;
// import "./E2E_Helper.sol";

// contract E2E_Allocate_Remove is E2E_Helper {
//     PoolData precall;
//     PoolData postcall;
//     event AllocateRemoveDifference(uint256 delquote, uint256 removequote);
//     event AllocateDelLiquidity(uint256 delLiquidity);
//     struct AllocateCall {
//         uint256 delquote;
//         uint256 delbase;
//         bytes32 poolId;
//         bool fromMargin;
//     }

//     function check_allocate_remove_inverses(
//         uint256 randomId,
//         uint256 intendedLiquidity,
//         bool fromMargin
//     ) public {
//         AllocateCall memory allocate;
//         allocate.poolId = Addresses.retrieve_created_pool(randomId);
//         retrieve_current_pool_data(allocate.poolId, true);
//         intendedLiquidity = E2E_Helper.one_to_max_uint64(intendedLiquidity);
//         allocate.delquote = (intendedLiquidity * precall.reserve.reservequote) / precall.reserve.liquidity;
//         allocate.delbase = (intendedLiquidity * precall.reserve.reservebase) / precall.reserve.liquidity;

//         uint256 delLiquidity = allocate_helper(allocate);

//         // these are calculated the amount returned when remove is called
//         (uint256 removequote, uint256 removebase) = remove_should_succeed(allocate.poolId, delLiquidity);
//         emit AllocateRemoveDifference(allocate.delquote, removequote);
//         emit AllocateRemoveDifference(allocate.delbase, removebase);

//         assert(allocate.delquote == removequote);
//         assert(allocate.delbase == removebase);
//         assert(intendedLiquidity == delLiquidity);
//     }

//     event AllocateFailed(string reason, uint256 quote, uint256 base);
//     event AllocateRevert(bytes reason, uint256 quote, uint256 base);

//     function allocate_with_safe_range(
//         uint256 randomId,
//         uint256 delquote,
//         uint256 delbase,
//         bool fromMargin
//     ) public {
//         delquote = E2E_Helper.one_to_max_uint64(delquote);
//         delbase = E2E_Helper.one_to_max_uint64(delbase);
//         bytes32 poolId = Addresses.retrieve_created_pool(randomId);
//         AllocateCall memory args = AllocateCall({
//             delquote: delquote,
//             delbase: delbase,
//             fromMargin: fromMargin,
//             poolId: poolId
//         });
//         allocate_helper(args);
//     }

//     function allocate_helper(AllocateCall memory params) internal returns (uint256) {
//         mint_tokens(params.delquote, params.delbase);
//         (, , uint32 maturity, , ) = engine.calibrations(params.poolId);
//         if (engine.time() > maturity) {
//             return allocate_should_revert(params);
//         }

//         return allocate_should_succeed(params);
//     }

//     event AllocateMarginBalance(uint128 quoteBefore, uint128 baseBefore, uint256 delquote, uint256 delbase);
//     event ReserveStatus(string functionName, uint256 liquidity, uint256 reservequote, uint256 reservebase);

//     function allocate_should_succeed(AllocateCall memory params) internal returns (uint256) {
//         (uint128 marginquoteBefore, uint128 marginbaseBefore) = engine.margins(address(this));
//         retrieve_current_pool_data(params.poolId, true);
//         if (params.fromMargin && (marginquoteBefore < params.delquote || marginbaseBefore < params.delbase)) {
//             return allocate_should_revert(params);
//         }
//         uint256 preCalcLiquidity;
//         {
//             uint256 liquidity0 = (params.delquote * precall.reserve.liquidity) / uint256(precall.reserve.reservequote);
//             uint256 liquidity1 = (params.delbase * precall.reserve.liquidity) /
//                 uint256(precall.reserve.reservebase);
//             preCalcLiquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
//             require(preCalcLiquidity > 0);
//         }
//         emit AllocateMarginBalance(marginquoteBefore, marginbaseBefore, params.delquote, params.delbase);
//         try
//             engine.allocate(
//                 params.poolId,
//                 address(this),
//                 params.delquote,
//                 params.delbase,
//                 params.fromMargin,
//                 abi.encode(0)
//             )
//         returns (uint256 delLiquidity) {
//             {
//                 retrieve_current_pool_data(params.poolId, false);
//                 assert(postcall.liquidity == precall.liquidity + delLiquidity);
//                 assert(postcall.reserve.blockTimestamp == engine.time());
//                 assert(postcall.reserve.blockTimestamp >= postcall.reserve.blockTimestamp);
//                 // reserves increase by allocated amount
//                 assert(postcall.reserve.reservequote - precall.reserve.reservequote == params.delquote);
//                 assert(postcall.reserve.reservebase - precall.reserve.reservebase == params.delbase);
//                 assert(postcall.reserve.liquidity - precall.reserve.liquidity == delLiquidity);
//                 // save delLiquidity
//                 assert(preCalcLiquidity == delLiquidity);
//                 (uint128 marginquoteAfter, uint128 marginbaseAfter) = engine.margins(address(this));
//                 if (params.fromMargin) {
//                     assert(marginquoteAfter == marginquoteBefore - params.delquote);
//                     assert(marginbaseAfter == marginbaseBefore - params.delbase);
//                 } else {
//                     assert(marginquoteAfter == marginquoteBefore);
//                     assert(marginbaseAfter == marginbaseBefore);
//                 }
//                 return delLiquidity;
//             }
//         } catch {
//             assert(false);
//         }
//     }

//     function allocate_should_revert(AllocateCall memory params) internal returns (uint256) {
//         try
//             engine.allocate(
//                 params.poolId,
//                 address(this),
//                 params.delquote,
//                 params.delbase,
//                 params.fromMargin,
//                 abi.encode(0)
//             )
//         {
//             assert(false);
//         } catch {
//             assert(true);
//             return 0;
//         }
//     }

//     function remove_with_safe_range(uint256 id, uint256 delLiquidity) public returns (uint256, uint256) {
//         delLiquidity = E2E_Helper.one_to_max_uint64(delLiquidity);
//         bytes32 poolId = Addresses.retrieve_created_pool(id);
//         remove_should_succeed(poolId, delLiquidity);
//     }

//     function remove_should_succeed(bytes32 poolId, uint256 delLiquidity) internal returns (uint256, uint256) {
//         retrieve_current_pool_data(poolId, true);
//         (uint256 calcquote, uint256 calcbase) = Reserve.getAmounts(precall.reserve, delLiquidity);
//         if (
//             delLiquidity == 0 ||
//             delLiquidity > precall.liquidity ||
//             calcquote > precall.reserve.reservequote ||
//             calcbase > precall.reserve.reservebase
//         ) {
//             return remove_should_revert(poolId, delLiquidity);
//         } else {
//             try engine.remove(poolId, delLiquidity) returns (uint256 delquote, uint256 delbase) {
//                 {
//                     retrieve_current_pool_data(poolId, false);
//                     // check liquidity decreased
//                     assert(postcall.liquidity == precall.liquidity - delLiquidity);

//                     // check margins for recipient increased
//                     assert(postcall.margin.balancequote == precall.margin.balancequote + delquote);
//                     assert(postcall.margin.balancebase == precall.margin.balancebase + delbase);
//                     (, , , uint32 calibrationTimestamp, ) = engine.calibrations(poolId);

//                     assert(calibrationTimestamp == engine.time());
//                     // check decrease in reserves
//                     assert_remove_postconditions(precall.reserve, postcall.reserve, delquote, delbase, delLiquidity);
//                 }
//                 return (delquote, delbase);
//             } catch {
//                 assert(false);
//             }
//         }
//     }

//     function remove_should_revert(bytes32 poolId, uint256 delLiquidity) internal returns (uint256, uint256) {
//         uint256 liquidityAmountBefore = engine.liquidity(address(this), poolId);
//         try engine.remove(poolId, delLiquidity) returns (uint256 delquote, uint256 delbase) {
//             assert(false);
//         } catch {
//             assert(liquidityAmountBefore == engine.liquidity(address(this), poolId));
//             return (0, 0);
//         }
//     }

//     function assert_remove_postconditions(
//         Reserve.Data storage preRemoveReserve,
//         Reserve.Data storage postRemoveReserve,
//         uint256 delquote,
//         uint256 delbase,
//         uint256 delLiquidity
//     ) internal {
//         assert(postRemoveReserve.reservequote == preRemoveReserve.reservequote - delquote);
//         assert(postRemoveReserve.reservebase == preRemoveReserve.reservebase - delbase);
//         assert(postRemoveReserve.liquidity == preRemoveReserve.liquidity - delLiquidity);
//     }

//     function allocateCallback(
//         uint256 delquote,
//         uint256 delbase,
//         bytes calldata data
//     ) external {
//         executeCallback(delquote, delbase);
//     }

//     function retrieve_current_pool_data(bytes32 poolId, bool isPrecall) private {
//         PoolData storage data;
//         if (isPrecall) {
//             data = precall;
//         } else {
//             data = postcall;
//         }
//         (
//             uint128 reservequote,
//             uint128 reservebase,
//             uint128 liquidity,
//             uint32 blockTimestamp,
//             uint256 cumulativequote,
//             uint256 cumulativebase,
//             uint256 cumulativeLiquidity
//         ) = engine.reserves(poolId);
//         data.reserve = Reserve.Data({
//             reservequote: reservequote,
//             reservebase: reservebase,
//             liquidity: liquidity,
//             blockTimestamp: blockTimestamp,
//             cumulativequote: cumulativequote,
//             cumulativebase: cumulativebase,
//             cumulativeLiquidity: cumulativeLiquidity
//         });

//         (uint128 marginquote, uint128 marginbase) = engine.margins(address(this));
//         data.margin = Margin.Data({balancequote: marginquote, balancebase: marginbase});

//         uint256 engineLiquidity = engine.liquidity(address(this), poolId);
//         data.liquidity = engineLiquidity;
//     }

//     struct PoolData {
//         Reserve.Data reserve;
//         Margin.Data margin;
//         uint256 liquidity;
//     }
// }
