pragma solidity 0.8.20;
// import "./E2E_Helper.sol";

// contract E2E_Manager is E2E_Helper {

//     event ManagerAllocateMarginBalance(uint128 quoteBefore, uint128 baseBefore, uint256 delquote, uint256 delbase);
//     event ManagerRevertAllocateMarginBalance(uint256 delquote, uint256 delbase);
//     event ManagerReserveStatus(string functionName, uint256 liquidity, uint256 reservequote, uint256 reservebase);
//     event Time();
//     struct ManagerAllocateCall {
//         uint256 delquote;
//         uint256 delbase;
//         bytes32 poolId;
//         bool fromMargin;
//     }

//     ManagerPoolData manager_precall;
//     ManagerPoolData manager_postcall;

//     function manager_allocate_with_safe_range(
//         uint256 randomId,
//         uint256 delquote,
//         uint256 delbase
//         //bool fromMargin
//     ) public {
//         // For now we only want not fromMargin
//         //if (fromMargin) {
//         //    delquote = E2E_Helper.one_to_max_uint64(delquote);
//         //    delbase = E2E_Helper.one_to_max_uint64(delbase);
//         //}
//         bytes32 poolId = Addresses.retrieve_created_pool(randomId);
//         ManagerAllocateCall memory args = ManagerAllocateCall({
//             delquote: delquote,
//             delbase: delbase,
//             fromMargin: false,
//             poolId: poolId
//         });
//         allocate_helper(args);
//     }

//     function allocate_helper(ManagerAllocateCall memory params) internal returns (uint256) {
//         mint_tokens(params.delquote, params.delbase);
//         approve_tokens_sender(address(manager), params.delquote, params.delbase);
//         (, , uint32 maturity, , ) = engine.calibrations(params.poolId);
//         if (engine.time() > maturity) {
//             emit Time();
//             return allocate_should_revert(params);
//         }

//         return allocate_should_succeed(params);
//     }

//     function allocate_should_succeed(ManagerAllocateCall memory params) internal returns (uint256) {
//         (uint128 marginquoteBefore, uint128 marginbaseBefore) = engine.margins(address(this));
//         if (params.fromMargin && (marginquoteBefore < params.delquote || marginbaseBefore < params.delbase)) {
//             return allocate_should_revert(params);
//         }
//         manager_retrieve_current_pool_data(params.poolId, true);
//         uint256 erc1155_preBalance = manager.balanceOf(address(this), uint256(params.poolId));
//         uint256 preCalcLiquidity;
//         {
//             uint256 liquidity0 = (params.delquote * manager_precall.reserve.liquidity) / uint256(manager_precall.reserve.reservequote);
//             uint256 liquidity1 = (params.delbase * manager_precall.reserve.liquidity) / uint256(manager_precall.reserve.reservebase);
//             preCalcLiquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
//             require(preCalcLiquidity > 0);
//         }
//         emit ManagerAllocateMarginBalance(marginquoteBefore, marginbaseBefore, params.delquote, params.delbase);
//         try
//             manager.allocate(
//                 params.poolId,
//                 address(quote),
//                 address(base),
//                 params.delquote,
//                 params.delbase,
//                 false,
//                 0
//             )
//         returns (uint256 delLiquidity) {
//             {
//                 manager_retrieve_current_pool_data(params.poolId, false);
//                 assert(manager_postcall.reserve.blockTimestamp == engine.time());
//                 assert(manager_postcall.reserve.blockTimestamp >= manager_postcall.reserve.blockTimestamp);
//                 // reserves increase by allocated amount
//                 assert(manager_postcall.reserve.reservequote - manager_precall.reserve.reservequote == params.delquote);
//                 assert(manager_postcall.reserve.reservebase - manager_precall.reserve.reservebase == params.delbase);
//                 assert(manager_postcall.reserve.liquidity - manager_precall.reserve.liquidity == delLiquidity);
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
//                 uint256 erc1155_postBalance = manager.balanceOf(address(this), uint256(params.poolId));
//                 assert(erc1155_postBalance - erc1155_preBalance == delLiquidity);
//                 return delLiquidity;
//             }
//         } catch {
//             assert(false);
//         }
//         manager_clear_pre_post_call();
//     }
//     function allocate_should_revert(ManagerAllocateCall memory params) internal returns (uint256) {
//         emit ManagerRevertAllocateMarginBalance(params.delquote, params.delbase);
        
//         try
//             manager.allocate(
//                 params.poolId,
//                 address(quote),
//                 address(base),
//                 params.delquote,
//                 params.delbase,
//                 false,
//                 0
//             )
//         {
//             assert(false);
//         } catch {
//             assert(true);
//             return 0;
//         }
//     }

//     function manager_retrieve_current_pool_data(bytes32 poolId, bool ismanager_precall) private {
//         ManagerPoolData storage data;
//         if (ismanager_precall) {
//             data = manager_precall;
//         } else {
//             data = manager_postcall;
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

//     function manager_clear_pre_post_call() internal {
//         delete manager_precall;
//         delete manager_postcall;
//     }
    
//     struct ManagerPoolData {
//         Reserve.Data reserve;
//         Margin.Data margin;
//         uint256 liquidity;
//     }

//     function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns (bytes4) {
//         return 0xf23a6e61;
//     }

//     function manager_remove_with_safe_range(uint256 id, uint256 delLiquidity) public returns (uint256, uint256) {
//         delLiquidity = E2E_Helper.one_to_max_uint64(delLiquidity);
//         bytes32 poolId = Addresses.retrieve_created_pool(id);
//         manager_remove_should_succeed(poolId, delLiquidity);
//     }

//     function manager_remove_should_succeed(bytes32 poolId, uint256 delLiquidity) internal returns (uint256, uint256) {
//         manager_retrieve_current_pool_data(poolId, true);
//         (uint256 calcquote, uint256 calcbase) = Reserve.getAmounts(manager_precall.reserve, delLiquidity);
//         uint256 erc1155_preBalance = manager.balanceOf(address(this), uint256(poolId));        
//         if (
//             delLiquidity == 0 ||
//             delLiquidity > manager_precall.liquidity ||
//             calcquote > manager_precall.reserve.reservequote ||
//             calcbase > manager_precall.reserve.reservebase ||
//             erc1155_preBalance < delLiquidity
//         ) {
//             return manager_remove_should_revert(poolId, delLiquidity);
//         } else {
//             try manager.remove(poolId, delLiquidity, 0, 0) returns (uint256 delquote, uint256 delbase) {
//                 {
//                     manager_retrieve_current_pool_data(poolId, false);
//                     // check liquidity decreased
//                     uint256 liquidityAmountAfter = engine.liquidity(address(this), poolId);
//                     assert(manager_postcall.liquidity == manager_precall.liquidity - delLiquidity);

//                     // check margins for recipient increased
//                     assert(manager_postcall.margin.balancequote == manager_precall.margin.balancequote + delquote);
//                     assert(manager_postcall.margin.balancebase == manager_precall.margin.balancebase + delbase);
//                     (, , , uint32 calibrationTimestamp, ) = engine.calibrations(poolId);

//                     assert(calibrationTimestamp == engine.time());
//                     // check decrease in reserves
//                     manager_assert_remove_postconditions(manager_precall.reserve, manager_postcall.reserve, delquote, delbase, delLiquidity);
//                 }
//                 return (delquote, delbase);
//             } catch {
//                 assert(false);
//             }
//         }
//         manager_clear_pre_post_call();
//     }

//     function manager_remove_should_revert(bytes32 poolId, uint256 delLiquidity) internal returns (uint256, uint256) {
//         uint256 liquidityAmountBefore = engine.liquidity(address(this), poolId);
//         try manager.remove(poolId, delLiquidity, 0, 0) returns (uint256 delquote, uint256 delbase) {
//             assert(false);
//         } catch {
//             assert(liquidityAmountBefore == engine.liquidity(address(this), poolId));
//             return (0, 0);
//         }
//     }

//     function manager_assert_remove_postconditions(
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

//     function user_mint_approve_tokens(uint256 quoteAmt, uint256 baseAmt) internal {
//         mint_tokens_sender(quoteAmt, baseAmt);
//         approve_tokens_sender(address(manager), quoteAmt, baseAmt);
//     }

//     function check_manager() public {
//         assert(manager.WETH9() == weth9);
//         assert(manager.positionDescriptor() != address(0));
//     }

//     event DepositManager(uint128 quoteBefore, uint128 baseBefore, uint128 quoteAfter, uint128 baseAfter);

//     function check_deposit_manager_safe(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) public {
//         delquote = E2E_Helper.one_to_max_uint64(delquote);
//         delbase = E2E_Helper.one_to_max_uint64(delbase);
//         user_mint_approve_tokens(delquote, delbase);
//         manager_deposit_should_succeed(recipient, delquote, delbase);
//     }

//     function check_manager_deposit_zero_zero(address recipient) public {
//         manager_deposit_should_revert(recipient, 0, 0);
//     }

//     event Failed(string reason);

//     function manager_deposit_should_succeed(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) internal {
//         (uint128 marginquoteBefore, uint128 marginbaseBefore) = manager.margins(recipient, address(engine));
//         try manager.deposit(recipient, address(quote), address(base), delquote, delbase) {
//             (uint128 marginquoteAfter, uint128 marginbaseAfter) = manager.margins(recipient, address(engine));
//             emit DepositManager(marginquoteBefore, marginbaseBefore, marginquoteAfter, marginbaseAfter);
//             assert(marginquoteAfter == marginquoteBefore + delquote);
//             assert(marginbaseAfter == marginbaseBefore + delbase);
// 		} catch {
// 			bytes memory payload = abi.encodeWithSignature("deposit(address,address,address,uint256,uint256)", recipient, address(quote), address(base), delquote, delbase);
// 			(bool success, bytes memory result) = address(manager).call(payload);
//             string memory revertReason = abi.decode(result, (string));
//             emit Failed(revertReason);
// 			assert(false);
// 		}
//         // } catch Error(string memory reason) {
//         //     //
//         //     emit Failed(reason);
//         //     assert(false);
//         // } catch (bytes memory reason) {
//         //     emit DepositManager(marginquoteBefore, marginbaseBefore, 0, 0);
//         //     string memory revertReason = abi.decode(reason, (string));
//         //     emit Failed(revertReason);
//         //     assert(false);
// 		// }
//     }

//     function manager_deposit_should_revert(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) internal {
//         try manager.deposit(recipient, address(quote), address(base), delquote, delbase) {
//             assert(false);
//         } catch {
//             assert(true);
//         }
//     }
// }
