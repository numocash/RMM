pragma solidity 0.8.20;
// import "./E2E_Helper.sol";

// // npx hardhat clean && npx hardhat compile && echidna-test-2.0 . --contract E2E_swap --config contracts/crytic/E2E_swap.yaml
// contract E2E_Swap_Adjusted is E2E_Helper {
//     bool inited;
//     PoolParams params;
//     CreateArgs createArgs;

//     // Tests

//     // just to stay sane
//     function test_init(uint128 _seed) internal {
//         if (!inited)  {
//             mint_tokens(1e11 ether, 1e11 ether);
//         }

//         // Step 1
//         uint32 time = uint32(engine.time());
//         assert(params.strike > 0);
//         assert(params.sigma > 0);
//         assert(params.gamma > 0);
//         assert(params.maturity >= time);
//         assert(params.lastTimestamp >= time);

//         // Step 2
//         assert(createArgs.quotePerLp > 0);
//         assert(createArgs.quotePerLp <= _getMaxquote());
//         assert(createArgs.delLiquidity >= engine.MIN_LIQUIDITY());

//         // Step 4
//         assert(createdPoolIds[address(engine)].length > 0);
//         assert(quote.balanceOf(address(engine)) > 0);
//         assert(base.balanceOf(address(engine)) > 0);

//         // Step 5
//         assert(inited);
//     }

//     function test_swap_quote_in(uint128 _amountIn) public {
//         // Step 1 - conditions
//         require(_amountIn != 0);

//         // Step 2
//         if (!inited) _init(_amountIn);

//         // Step 3
//         bytes32 poolId = createdPoolIds[address(engine)][0];
//         (uint128 strike, uint32 sigma, uint32 maturity, , uint32 gamma) = engine.calibrations(poolId);
//         (uint128 reservequote, uint128 reservebase, uint128 liquidity, , , , ) = engine.reserves(poolId);
//         uint32 tau = uint32(engine.time()) > maturity ? 0 : maturity - uint32(engine.time());
//         {
//             uint256 maxDeltaIn = _compute_max_swap_input(true, reservequote, reservebase, liquidity, strike);
//             _amountIn = uint128(1 + (_amountIn % (maxDeltaIn - 1))); // add 1 so its always > 0
//         }

//         ExactInput memory exactIn = ExactInput({
//             poolId: poolId,
//             amountIn: uint128(_amountIn),
//             reservequote: reservequote,
//             reservebase: reservebase,
//             reserveLiquidity: liquidity,
//             strike: strike,
//             sigma: sigma,
//             gamma: gamma,
//             maturity: maturity,
//             tau: tau
//         });

//         // Step 3 - conditions
//         _swap_precondition_1(exactIn.maturity);

//         // Step 4
//         uint256 amountOut = _simulate_exact_quote_in(exactIn);

//         SwapHelper memory swapHelper = SwapHelper({
//             poolId: poolId,
//             quoteForbase: true,
//             deltaIn: exactIn.amountIn,
//             deltaOut: amountOut,
//             fromMargin: false,
//             toMargin: false
//         });

//         // Step 5
//         _swap_pre_condition_2(swapHelper.deltaIn, swapHelper.deltaOut);
//         if (quote.balanceOf(address(this)) < exactIn.amountIn) quote.mint(address(this), exactIn.amountIn);
//         _swap_helper(swapHelper);
//     }

//     function test_reverse_swap(uint128 _amountIn) public {
//         // Step 1 - conditions
//         require(_amountIn != 0);

//         // Step 2
//         if (!inited) _init(_amountIn);

//         // Step 3
//         bytes32 poolId = createdPoolIds[address(engine)][0];
//         (uint128 strike, uint32 sigma, uint32 maturity, , uint32 gamma) = engine.calibrations(poolId);
//         (uint128 reservequote, uint128 reservebase, uint128 liquidity, , , , ) = engine.reserves(poolId);
//         uint32 tau = uint32(engine.time()) > maturity ? 0 : maturity - uint32(engine.time());
//         {
//             uint256 maxDeltaIn = _compute_max_swap_input(true, reservequote, reservebase, liquidity, strike);
//             _amountIn = uint128(1 + (_amountIn % (maxDeltaIn - 1))); // add 1 so its always > 0
//         }

//         ExactInput memory exactIn = ExactInput({
//             poolId: poolId,
//             amountIn: uint128(_amountIn),
//             reservequote: reservequote,
//             reservebase: reservebase,
//             reserveLiquidity: liquidity,
//             strike: strike,
//             sigma: sigma,
//             gamma: gamma,
//             maturity: maturity,
//             tau: tau
//         });

//         // Step 3 - conditions
//         _swap_precondition_1(exactIn.maturity);

//         // Step 4
//         uint256 amountOut = _simulate_exact_quote_in(exactIn);

//         SwapHelper memory swapHelper = SwapHelper({
//             poolId: poolId,
//             quoteForbase: true,
//             deltaIn: exactIn.amountIn,
//             deltaOut: amountOut,
//             fromMargin: false,
//             toMargin: false
//         });

//         // Step 5 - Swap some amount in forward direction
//         _swap_pre_condition_2(swapHelper.deltaIn, swapHelper.deltaOut);
//         if (quote.balanceOf(address(this)) < exactIn.amountIn) quote.mint(address(this), exactIn.amountIn);
//         _swap_helper(swapHelper);

//         // Step 6 - Then swap it back
//         require(exactIn.gamma < 10000); // fee is non-zero
//         swapHelper = SwapHelper({
//             poolId: poolId,
//             quoteForbase: false,
//             deltaIn: amountOut,
//             deltaOut: exactIn.amountIn, // should not be getting same amount out, since fees were paid
//             fromMargin: false,
//             toMargin: false
//         });
//         _reverting_swap_helper(swapHelper);
//     }

//     function test_swap_base_in(uint128 _amountIn) public {
//         // Step 1 - conditions
//         require(_amountIn != 0);

//         // Step 2
//         if (!inited) _init(_amountIn);

//         // Step 3
//         bytes32 poolId = createdPoolIds[address(engine)][0];
//         (uint128 strike, uint32 sigma, uint32 maturity, , uint32 gamma) = engine.calibrations(poolId);
//         (uint128 reservequote, uint128 reservebase, uint128 liquidity, , , , ) = engine.reserves(poolId);
//         uint32 tau = uint32(engine.time()) > maturity ? 0 : maturity - uint32(engine.time());
//         {
//             uint256 maxDeltaIn = _compute_max_swap_input(false, reservequote, reservebase, liquidity, strike);
//             _amountIn = uint128(1 + (_amountIn % (maxDeltaIn - 1))); // add 1 so its always > 0
//         }

//         ExactInput memory exactIn = ExactInput({
//             poolId: poolId,
//             amountIn: uint128(_amountIn),
//             reservequote: reservequote,
//             reservebase: reservebase,
//             reserveLiquidity: liquidity,
//             strike: strike,
//             sigma: sigma,
//             gamma: gamma,
//             maturity: maturity,
//             tau: tau
//         });

//         // Step 3 - conditions
//         _swap_precondition_1(exactIn.maturity);

//         // Step 4
//         uint256 amountOut = _simulate_exact_base_in(exactIn);

//         SwapHelper memory swapHelper = SwapHelper({
//             poolId: poolId,
//             quoteForbase: false,
//             deltaIn: exactIn.amountIn,
//             deltaOut: amountOut,
//             fromMargin: false,
//             toMargin: false
//         });

//         // Step 5
//         _swap_pre_condition_2(swapHelper.deltaIn, swapHelper.deltaOut);
//         if (base.balanceOf(address(this)) < exactIn.amountIn) base.mint(address(this), exactIn.amountIn);
//         _swap_helper(swapHelper);
//     }

//     // Utils

//     function check_swap_invariants(
//         bytes32 poolId,
//         bool quoteForbase,
//         int128 pre_invariant,
//         uint128 pre_quote,
//         uint128 pre_base
//     ) internal {
//         // #post1
//         (, , uint32 maturity, uint32 lastTimestamp, ) = engine.calibrations(poolId);
//         if (maturity <= engine.time()) {
//             assert(lastTimestamp == maturity);
//         } else {
//             assert(lastTimestamp == engine.time());
//         }

//         // #post2
//         int128 post_invariant = engine.invariantOf(poolId);
//         assert(post_invariant >= pre_invariant);

//         // #post3
//         (uint128 post_quote, uint128 post_base, , , , , ) = engine.reserves(poolId);
//         if (quoteForbase) {
//             // This will fail if deltaInWithFee == 0
//             assert(post_quote > pre_quote);
//             assert(post_base < pre_base);
//         } else {
//             assert(post_quote < pre_quote);
//             // This will fail if deltaInWithFee == 0
//             assert(post_base > pre_base);
//         }
//     }

//     function _swap_precondition_1(uint32 maturity) internal {
//         require(maturity + engine.BUFFER() >= uint32(engine.time()));
//     }

//     function _swap_pre_condition_2(uint256 input, uint256 output) internal {
//         require(input != 0 && output != 0);
//     }

//     event InvariantCheck(int128 pre, int128 post);

//     // parameters for a swap
//     struct ExactInput {
//         bytes32 poolId;
//         uint256 amountIn;
//         uint128 reservequote;
//         uint128 reservebase;
//         uint128 reserveLiquidity;
//         uint128 strike;
//         uint32 sigma;
//         uint32 gamma;
//         uint32 maturity;
//         uint32 tau;
//     }

//     function _simulate_exact_quote_in(ExactInput memory i) internal returns (uint256) {
//         // quoteDecimals, baseDecinmals = 18 for now
//         // Need timestamp updated
//         int128 invariantBefore = engine.invariantOf(i.poolId);

//         uint256 deltaOut;
//         uint256 adjustedquote;
//         uint256 adjustedbase;
//         {
//             uint256 deltaInWithFee = (i.amountIn * i.gamma) / 1e4; // amount * (1 - fee %)
//             uint256 upscaledAdjustedquote = uint256(i.reservequote) + deltaInWithFee; // total

//             // compute delta out
//             adjustedquote = (upscaledAdjustedquote * 1e18) / i.reserveLiquidity; // per
//             adjustedbase = ReplicationMath.getbaseGivenquote(
//                 invariantBefore,
//                 engine.scaleFactorquote(),
//                 engine.scaleFactorbase(),
//                 adjustedquote,
//                 i.strike,
//                 i.sigma,
//                 i.tau
//             );
//             adjustedbase += 1; // round up on output reserve
//         }

//         require(i.tau == 0 ? adjustedquote >= 0 : adjustedquote > 0);
//         require(i.tau == 0 ? adjustedbase >= 0 : adjustedbase > 0);
//         require(adjustedquote <= 10**quote.decimals());
//         require(adjustedbase <= i.strike);

//         int128 invariantAfter = ReplicationMath.calcInvariant(
//             engine.scaleFactorquote(),
//             engine.scaleFactorbase(),
//             adjustedquote,
//             adjustedbase,
//             i.strike,
//             i.sigma,
//             i.tau
//         );

//         emit InvariantCheck(invariantBefore, invariantAfter);
//         assert(invariantAfter >= invariantBefore);

//         uint256 upscaledAdjustedbase = (adjustedbase * i.reserveLiquidity) / 1e18 + 1; // round up on output reserve
//         deltaOut = uint256(i.reservebase) - upscaledAdjustedbase; // total
//         return deltaOut;
//     }

//     function _simulate_exact_base_in(ExactInput memory i) internal returns (uint256) {
//         // quoteDecimals, baseDecinmals = 18 for now
//         // Need timestamp updated
//         int128 invariantBefore = engine.invariantOf(i.poolId);

//         uint256 deltaOut;
//         uint256 adjustedquote;
//         uint256 adjustedbase;
//         {
//             uint256 deltaInWithFee = (i.amountIn * i.gamma) / 1e4; // amount * (1 - fee %)
//             uint256 upscaledAdjustedbase = uint256(i.reservebase) + deltaInWithFee; // total

//             // compute delta out
//             adjustedbase = (upscaledAdjustedbase * 1e18) / i.reserveLiquidity; // per
//             adjustedquote = get_quote_given_base_bisection(adjustedbase, i.strike, i.sigma, i.tau);
//             //adjustedquote = ReplicationMath.getquoteGivenbase(
//             //    invariantBefore,
//             //    engine.scaleFactorquote(),
//             //    engine.scaleFactorbase(),
//             //    adjustedbase,
//             //    i.strike,
//             //    i.sigma,
//             //    i.tau
//             //);
//             adjustedquote += 1; // round up on output reserve
//         }

//         require(i.tau == 0 ? adjustedquote >= 0 : adjustedquote > 0);
//         require(i.tau == 0 ? adjustedbase >= 0 : adjustedbase > 0);
//         require(adjustedquote <= 10**quote.decimals());
//         require(adjustedbase <= i.strike);

//         int128 invariantAfter = ReplicationMath.calcInvariant(
//             engine.scaleFactorquote(),
//             engine.scaleFactorbase(),
//             adjustedquote,
//             adjustedbase,
//             i.strike,
//             i.sigma,
//             i.tau
//         );

//         emit InvariantCheck(invariantBefore, invariantAfter);
//         assert(invariantAfter >= invariantBefore);

//         uint256 upscaleAdjustedquote = (adjustedquote * i.reserveLiquidity) / 1e18 + 1; // round up on output reserve
//         deltaOut = uint256(i.reservequote) - upscaleAdjustedquote; // total
//         return deltaOut;
//     }

//     function _getMaxquote() internal returns (uint256) {
//         return 10**quote.decimals();
//     }

//     function _compute_max_swap_input(
//         bool quoteForbase,
//         uint128 reservequote,
//         uint128 reservebase,
//         uint128 liquidity,
//         uint128 strike
//     ) internal returns (uint256) {
//         if (quoteForbase) {
//             uint256 quotePerLiquidity = (uint256(reservequote) * 1e18) / liquidity;
//             return (uint256(_getMaxquote() - quotePerLiquidity) * liquidity) / 1e18;
//         } else {
//             uint256 basePerLiquidity = (uint256(reservebase) * 1e18) / liquidity;
//             return (uint256(strike - basePerLiquidity) * liquidity) / 1e18;
//         }
//     }

//     // Setup

//     function _init(uint128 _seed) internal {
//         // Step 1
//         params = _forgeCalibration(_seed);

//         // Step 2
//         createArgs = _forgeCreateArgs(_seed);
//         (uint256 delquote, uint256 delbase) = _calculate_create_pool_payment(
//             createArgs.quotePerLp,
//             createArgs.delLiquidity,
//             params.strike,
//             params.sigma,
//             params.maturity
//         );

//         // Step 3
//         E2E_Helper.mint_tokens(delquote, delbase);

//         // Step 4
//         _create_helper(createArgs.quotePerLp, createArgs.delLiquidity, abi.encode(0));

//         // Step 5
//         inited = true;
//     }

//     // verifies create argument `quotePerLp`, and condition for non-zero reserves
//     function _calculate_create_pool_payment(
//         uint256 quotePerLp,
//         uint256 delLiquidity,
//         uint128 _strike,
//         uint32 _sigma,
//         uint32 _maturity
//     ) internal returns (uint256 delquote, uint256 delbase) {
//         uint256 factor0 = engine.scaleFactorquote();
//         uint256 factor1 = engine.scaleFactorbase();
//         uint32 tau = _maturity - uint32(engine.time()); // time until expiry
//         require(quotePerLp <= engine.PRECISION() / factor0);

//         delbase = ReplicationMath.getbaseGivenquote(0, factor0, factor1, quotePerLp, _strike, _sigma, tau);
//         delquote = (quotePerLp * delLiquidity) / engine.PRECISION(); // quoteDecimals * 1e18 decimals / 1e18 = quoteDecimals
//         require(delquote > 0);
//         delbase = (delbase * delLiquidity) / engine.PRECISION();
//         require(delbase > 0);
//     }

//     struct PoolBounds {
//         uint128 min_strike;
//         uint128 max_strike;
//         uint32 min_sigma;
//         uint32 max_sigma;
//         uint32 min_gamma;
//         uint32 max_gamma;
//     }

//     struct PoolParams {
//         uint128 strike;
//         uint32 sigma;
//         uint32 maturity;
//         uint32 lastTimestamp;
//         uint32 gamma;
//     }

//     /// should always return valid calibration parameters
//     function _forgeCalibration(uint256 _seed) internal returns (PoolParams memory calibration) {
//         PoolBounds memory bounds = PoolBounds({
//             min_strike: 1 ether,
//             max_strike: 10_000 ether,
//             min_sigma: 100, // 0.01%
//             max_sigma: 10_000_000, // 1000%
//             min_gamma: 9_000, // 90%
//             max_gamma: 10_000 // 99.99%
//         });

//         calibration.strike = uint128(bounds.min_strike + (_seed % (bounds.max_strike - bounds.min_strike)));
//         calibration.sigma = uint32(bounds.min_sigma + (_seed % (bounds.max_sigma - bounds.min_sigma)));
//         calibration.gamma = uint32(bounds.min_gamma + (_seed % (bounds.max_gamma - bounds.min_gamma)));
//         calibration.maturity = uint32(31556952 + ((_seed % (type(uint32).max)) - 1));
//         calibration.lastTimestamp = uint32(engine.time());
//         require(calibration.maturity >= calibration.lastTimestamp);
//     }

//     struct CreateBounds {
//         uint256 min_quote;
//         uint256 max_quote;
//         uint256 min_liquidity;
//         uint256 max_liquidity;
//     }

//     struct CreateArgs {
//         uint256 quotePerLp;
//         uint256 delLiquidity;
//     }

//     uint256 min_liquidity_override = 1 ether;

//     // should always return valid create args
//     function _forgeCreateArgs(uint256 _seed) internal returns (CreateArgs memory args) {
//         CreateBounds memory bounds = CreateBounds({
//             min_quote: 1,
//             max_quote: _getMaxquote(),
//             min_liquidity: engine.MIN_LIQUIDITY(),
//             max_liquidity: type(uint64).max
//         });

//         args.quotePerLp = bounds.min_quote + (_seed % (bounds.max_quote - bounds.min_quote));
//         args.delLiquidity = bounds.min_liquidity + (_seed % (bounds.max_liquidity - bounds.min_liquidity));
//         args.delLiquidity += min_liquidity_override; // for swaps, seed inital liquidity beyond min
//         require(args.quotePerLp <= engine.PRECISION() / engine.scaleFactorquote());
//     }

//     // Helper

//     event FailedSwap(
//         bytes32 poolId,
//         bool quoteForbase,
//         uint256 reservequote,
//         uint256 reservebase,
//         uint256 amountIn,
//         uint256 amountOut
//     );

//     event KnownError(string msg);
//     event UnknownError(string msg);
//     event Panicked(uint256 val);
//     event ErrorSig(bytes32 s);

//     struct SwapHelper {
//         bytes32 poolId;
//         uint256 deltaIn;
//         uint256 deltaOut;
//         bool fromMargin;
//         bool toMargin;
//         bool quoteForbase;
//     }

//     function _swap_helper(SwapHelper memory s) internal {
//         int128 pre_invariant = engine.invariantOf(s.poolId);
//         (uint128 pre_quote, uint128 pre_base, , , , , ) = engine.reserves(s.poolId);

//         require(s.quoteForbase ? pre_base >= s.deltaOut : pre_quote >= s.deltaOut);
//         try
//             engine.swap(
//                 address(this),
//                 s.poolId,
//                 s.quoteForbase,
//                 s.deltaIn,
//                 s.deltaOut,
//                 s.fromMargin,
//                 s.toMargin,
//                 abi.encode(0)
//             )
//         {
//             check_swap_invariants(s.poolId, s.quoteForbase, pre_invariant, pre_quote, pre_base);
//         } catch Error(string memory reason) {
//             emit KnownError(reason);
//         } catch Panic(uint256 code) {
//             emit Panicked(code);
//         } catch (bytes memory err) {
//             // better logging
//             if (bytes4(keccak256("InvariantError(int128,int128)")) == bytes4(err)) {
//                 emit KnownError("InvariantError(int128,int128)");
//             } else if (bytes4(keccak256(("PoolExpiredError()"))) == bytes4(err)) {
//                 emit KnownError("PoolExpiredError");
//             } else {
//                 emit ErrorSig(keccak256(err));
//                 emit UnknownError("Unknown");
//             }

//             emit FailedSwap(s.poolId, s.quoteForbase, pre_quote, pre_base, s.deltaIn, s.deltaOut);
//             assert(false);
//         }
//     }

//     function _reverting_swap_helper(SwapHelper memory s) internal {
//         (uint128 pre_quote, uint128 pre_base, , , , , ) = engine.reserves(s.poolId);
//         require(s.quoteForbase ? pre_base >= s.deltaOut : pre_quote >= s.deltaOut);
//         try
//             engine.swap(
//                 address(this),
//                 s.poolId,
//                 s.quoteForbase,
//                 s.deltaIn,
//                 s.deltaOut,
//                 s.fromMargin,
//                 s.toMargin,
//                 abi.encode(0)
//             )
//         {
//             assert(false);
//         } catch {
//             assert(true);
//         }
//     }

//     event AddedPool(
//         bytes32 poolId,
//         uint256 quotePerLiquidity,
//         uint256 delLiquidity,
//         uint128 strike,
//         uint32 sigma,
//         uint32 maturity,
//         uint32 gamma,
//         uint32 timestamp
//     );
//     event FailedCreating(
//         uint128 strike,
//         uint32 sigma,
//         uint32 maturity,
//         uint32 gamma,
//         uint256 quotePerLp,
//         uint256 liquidity
//     );

//     function _create_helper(
//         uint256 quotePerLp,
//         uint256 delLiquidity,
//         bytes memory data
//     ) internal {
//         (uint128 strike, uint32 sigma, uint32 maturity, uint32 gamma) = (
//             params.strike,
//             params.sigma,
//             params.maturity,
//             params.gamma
//         );
//         try engine.create(strike, sigma, maturity, gamma, quotePerLp, delLiquidity, data) {
//             bytes32 poolId = keccak256(abi.encodePacked(address(engine), strike, sigma, maturity, gamma));
//             createdPoolIds[address(engine)].push(poolId);

//             (
//                 uint128 calibrationStrike,
//                 uint32 calibrationSigma,
//                 uint32 calibrationMaturity,
//                 uint32 calibrationTimestamp,
//                 uint32 calibrationGamma
//             ) = engine.calibrations(poolId);
//             assert(calibrationTimestamp == engine.time());
//             assert(calibrationGamma == gamma);
//             assert(calibrationStrike == strike);
//             assert(calibrationSigma == sigma);
//             assert(calibrationMaturity == maturity);
//             emit AddedPool(
//                 poolId,
//                 quotePerLp,
//                 delLiquidity,
//                 calibrationStrike,
//                 calibrationSigma,
//                 calibrationMaturity,
//                 calibrationGamma,
//                 calibrationTimestamp
//             );
//         } catch {
//             emit FailedCreating(strike, sigma, maturity, gamma, quotePerLp, delLiquidity);
//             assert(false);
//         }
//     }

//     // Bisection
//     function epsilon() internal view returns (uint256) {
//         return 10**(quote.decimals() - 3);
//     }

//     function max_precision() internal view returns (uint256) {
//         return 10**(quote.decimals() - 5);
//     }

//     function get_quote_given_base_bisection(
//         uint256 res_base,
//         uint256 strike,
//         uint256 sigma,
//         uint256 tau
//     ) internal returns (uint256) {
//         uint256 scale_quote = engine.scaleFactorquote();
//         uint256 scale_base = engine.scaleFactorbase();

//         bargs = BisectionArgs({
//             scale_quote: scale_quote,
//             scale_base: scale_base,
//             res_base: res_base,
//             strike: strike,
//             sigma: sigma,
//             tau: tau
//         });

//         uint256 precision = max_precision(); // 5 decimal places
//         uint256 max_quote = 10**quote.decimals(); // 1
//         int128 i_max_precision = bisection_method(precision);
//         int128 i_max_quote_less_precision = bisection_method(max_quote - precision);

//         // if max precision is positive, and max quote less precision is negative, true
//         // else max precision is negative, if max quote less precision is position, true
//         uint256 optimal_out;
//         if (i_max_precision >= 0 ? i_max_quote_less_precision < 0 : i_max_quote_less_precision >= 0) {
//             optimal_out = bisection(precision, max_quote - precision);
//         } else {
//             optimal_out = max_quote;
//         }

//         return optimal_out;
//     }

//     struct BisectionArgs {
//         uint256 scale_quote;
//         uint256 scale_base;
//         uint256 res_base;
//         uint256 strike;
//         uint256 sigma;
//         uint256 tau;
//     }

//     BisectionArgs internal bargs;

//     function bisection_method(uint256 v) internal returns (int128) {
//         BisectionArgs memory b = bargs;
//         return ReplicationMath.calcInvariant(b.scale_quote, b.scale_base, v, b.res_base, b.strike, b.sigma, b.tau);
//     }

//     function bisection(uint256 a, uint256 b) internal returns (uint256) {
//         require(bisection_method(a) * bisection_method(b) < 0);

//         uint256 EPSILON = epsilon();

//         uint256 c = a;

//         uint256 diff;
//         unchecked {
//             diff = b - a;
//         }

//         while (diff >= EPSILON) {
//             c = (a + b) / 2;

//             if (bisection_method(c) == 0) break;
//             else if (bisection_method(c) * bisection_method(a) < 0) b = c;
//             else a = c;
//         }

//         return c;
//     }
// }
