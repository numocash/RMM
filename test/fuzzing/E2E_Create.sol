pragma solidity 0.8.20;
// import "./E2E_Helper.sol";

// contract E2E_Create is Addresses, E2E_Helper {
//     struct CreateHelper {
//         uint128 strike;
//         uint32 sigma;
//         uint32 maturity;
//         uint256 quotePerLp;
//         uint256 delLiquidity;
//         uint32 gamma;
//     }

//     function create_new_pool_should_not_revert(
//         uint128 _strike,
//         uint32 _sigma,
//         uint32 _maturity,
//         uint32 _gamma,
//         uint256 quotePerLp,
//         uint256 _delLiquidity
//     ) public {
//         uint128 strike = (1 ether + (_strike % (10000 ether - 1 ether)));
//         uint32 sigma = (100 + (_sigma % (1e7 - 100)));
//         uint32 gamma = (9000 + (_gamma % (10000 - 9000)));
//         uint256 delLiquidity = (engine.MIN_LIQUIDITY() + 1 + (_delLiquidity % (10 ether - engine.MIN_LIQUIDITY())));
//         uint32 maturity = (31556952 + _maturity);
//         require(maturity >= uint32(engine.time()));
//         CreateHelper memory args = CreateHelper({
//             strike: strike,
//             sigma: sigma,
//             maturity: maturity,
//             delLiquidity: delLiquidity,
//             quotePerLp: quotePerLp,
//             gamma: gamma
//         });
//         (uint256 delquote, uint256 delbase) = calculate_del_quote_and_base(args);

//         create_helper(args, abi.encode(0));
//     }

//     function create_new_pool_with_wrong_gamma_should_revert(
//         uint128 _strike,
//         uint32 _sigma,
//         uint32 _maturity,
//         uint32 gamma,
//         uint256 quotePerLp,
//         uint256 _delLiquidity
//     ) public {
//         uint128 strike = (1 ether + (_strike % (10000 ether - 1 ether)));
//         uint32 sigma = (100 + (_sigma % (1e7 - 100)));
//         uint256 delLiquidity = (engine.MIN_LIQUIDITY() + 1 + (_delLiquidity % (10 ether - engine.MIN_LIQUIDITY())));
//         uint32 maturity = (31556952 + _maturity);
//         require(maturity >= uint32(engine.time()));
//         CreateHelper memory args = CreateHelper({
//             strike: strike,
//             sigma: sigma,
//             maturity: maturity,
//             delLiquidity: delLiquidity,
//             quotePerLp: quotePerLp,
//             gamma: gamma
//         });
//         (uint256 delquote, uint256 delbase) = calculate_del_quote_and_base(args);

//         if (gamma > 10000 || gamma < 9000) {
//             create_should_revert(args, abi.encode(0));
//         }
//     }

//     function create_should_revert(CreateHelper memory params, bytes memory data) internal {
//         try
//             engine.create(
//                 params.strike,
//                 params.sigma,
//                 params.maturity,
//                 params.gamma,
//                 params.quotePerLp,
//                 params.delLiquidity,
//                 abi.encode(0)
//             )
//         {
//             assert(false);
//         } catch {
//             assert(true);
//         }
//     }

//     function create_helper(
//         CreateHelper memory params,
//         bytes memory data

//     ) internal {
//         try engine.create(params.strike, params.sigma, params.maturity, params.gamma, params.quotePerLp, params.delLiquidity, data) {
//             bytes32 poolId = keccak256(abi.encodePacked(address(engine), params.strike, params.sigma, params.maturity, params.gamma));
//             Addresses.add_to_created_pool(poolId);
//             (
//                 uint128 calibrationStrike,
//                 uint32 calibrationSigma,
//                 uint32 calibrationMaturity,
//                 uint32 calibrationTimestamp,
//                 uint32 calibrationGamma
//             ) = engine.calibrations(poolId);
//             assert(calibrationTimestamp == engine.time());
//             assert(calibrationGamma == params.gamma);
//             assert(calibrationStrike == params.strike);
//             assert(calibrationSigma == params.sigma);
//             assert(calibrationMaturity == params.maturity);
//         } catch {
//             assert(false);
//         }
//     }

//     function calculate_del_quote_and_base(CreateHelper memory params)
//         internal
//         returns (uint256 delquote, uint256 delbase)
//     {
//         uint256 factor0 = engine.scaleFactorquote();
//         uint256 factor1 = engine.scaleFactorbase();
//         uint32 tau = params.maturity - uint32(engine.time()); // time until expiry
//         require(params.quotePerLp <= engine.PRECISION() / factor0);

//         delbase = ReplicationMath.getbaseGivenquote(
//             0,
//             factor0,
//             factor1,
//             params.quotePerLp,
//             params.strike,
//             params.sigma,
//             tau
//         );
//         delquote = (params.quotePerLp * params.delLiquidity) / engine.PRECISION(); // quoteDecimals * 1e18 decimals / 1e18 = quoteDecimals
//         require(delquote > 0);
//         delbase = (delbase * params.delLiquidity) / engine.PRECISION();
//         require(delbase > 0);
//         mint_tokens(delquote, delbase);
//     }

//     function createCallback(
//         uint256 delquote,
//         uint256 delbase,
//         bytes calldata data
//     ) external {
//         executeCallback(delquote, delbase);
//     }
// }
