// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "./TestBase.sol";
// import "../libraries/ReplicationMath.sol";
// import "../libraries/Units.sol";
// import "forge-std/console.sol";
// import "../interfaces/engine/IEngineErrors.sol";
// import "../libraries/ABDKMath64x64.sol";
// import "../libraries/CumulativeNormalDistribution.sol";

// contract TestRouter is TestBase {
//     using Units for uint256;
//     using Units for int128;
//     using ABDKMath64x64 for int128;
//     using CumulativeNormalDistribution for int128;

//     constructor(address engine_) TestBase(engine_) {}

//     string public expectedError;

//     function expect(string memory errorString) public {
//         expectedError = errorString;
//     }

//     // ===== Create =====

//     function create(
//         uint256 strike,
//         uint256 sigma,
//         uint256 maturity,
//         uint256 gamma,
//         uint256 quotePerLp,
//         uint256 delLiquidity,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         try
//             IEngine(engine).create(
//                 uint128(strike),
//                 uint32(sigma),
//                 uint32(maturity),
//                 uint32(gamma),
//                 quotePerLp,
//                 delLiquidity,
//                 data
//             )
//         {} catch (bytes memory err) {
//             if (keccak256(abi.encodeWithSignature(expectedError)) == keccak256(err)) {
//                 revert(expectedError);
//             } else {
//                 revert("Unknown()");
//             }
//         }
//     }

//     // ===== Margin =====

//     function deposit(
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         IEngine(engine).deposit(owner, delQuote, delBase, data);
//     }

//     function depositFail(
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         scenario = Scenario.FAIL;
//         IEngine(engine).deposit(owner, delQuote, delBase, data);
//         scenario = Scenario.SUCCESS;
//     }

//     function depositReentrancy(
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         scenario = Scenario.REENTRANCY;
//         IEngine(engine).deposit(owner, delQuote, delBase, data);
//         scenario = Scenario.SUCCESS;
//     }

//     function depositOnlyQuote(
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         scenario = Scenario.QUOTE_ONLY;
//         IEngine(engine).deposit(owner, delQuote, delBase, data);
//         scenario = Scenario.SUCCESS;
//     }

//     function depositOnlyBase(
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         scenario = Scenario.BASE_ONLY;
//         IEngine(engine).deposit(owner, delQuote, delBase, data);
//         scenario = Scenario.SUCCESS;
//     }

//     function withdraw(uint256 delQuote, uint256 delBase) public {
//         caller = msg.sender;
//         IEngine(engine).withdraw(msg.sender, delQuote, delBase);
//     }

//     function withdrawToRecipient(
//         address recipient,
//         uint256 delQuote,
//         uint256 delBase
//     ) public {
//         caller = msg.sender;
//         IEngine(engine).withdraw(recipient, delQuote, delBase);
//     }

//     // ===== Allocate =====

//     function allocate(
//         bytes32 poolId,
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         IEngine(engine).allocate(poolId, owner, delQuote, delBase, false, data);
//     }

//     function allocateFromMargin(
//         bytes32 poolId,
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         IEngine(engine).allocate(poolId, owner, delQuote, delBase, true, data);
//     }

//     function allocateFromExternal(
//         bytes32 poolId,
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         IEngine(engine).allocate(poolId, owner, delQuote, delBase, false, data);
//     }

//     function allocateFromExternalNoQuote(
//         bytes32 poolId,
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         scenario = Scenario.BASE_ONLY;
//         IEngine(engine).allocate(poolId, owner, delQuote, delBase, false, data);
//     }

//     function allocateFromExternalNoBase(
//         bytes32 poolId,
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         scenario = Scenario.QUOTE_ONLY;
//         IEngine(engine).allocate(poolId, owner, delQuote, delBase, false, data);
//     }

//     function allocateFromExternalReentrancy(
//         bytes32 poolId,
//         address owner,
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         scenario = Scenario.REENTRANCY;
//         IEngine(engine).allocate(poolId, owner, delQuote, delBase, false, data);
//     }

//     // ===== Remove =====

//     function remove(
//         bytes32 poolId,
//         uint256 delLiquidity,
//         bytes memory data
//     ) public {
//         data;
//         IEngine(engine).remove(poolId, delLiquidity);
//     }

//     function removeToMargin(
//         bytes32 poolId,
//         uint256 delLiquidity,
//         bytes memory data
//     ) public {
//         data;
//         IEngine(engine).remove(poolId, delLiquidity);
//     }

//     function removeToExternal(
//         bytes32 poolId,
//         uint256 delLiquidity,
//         bytes memory data
//     ) public {
//         data;
//         (uint256 delQuote, uint256 delBase) = IEngine(engine).remove(poolId, delLiquidity);
//         IEngine(engine).withdraw(msg.sender, delQuote, delBase);
//     }

//     // ===== Swaps =====

//     function swap(
//         address recipient,
//         bytes32 pid,
//         bool quoteForBase,
//         uint256 deltaIn,
//         uint256 deltaOut,
//         bool fromMargin,
//         bool toMargin,
//         bytes calldata data
//     ) public {
//         caller = msg.sender;
//         IEngine(engine).swap(recipient, pid, quoteForBase, deltaIn, deltaOut, fromMargin, toMargin, data);
//     }

//     function getBaseOutGivenQuoteIn(bytes32 poolId, uint256 deltaIn) public view returns (uint256) {
//         IEngineView lens = IEngineView(engine);
//         (uint128 reserveQuote, uint128 reserveBase, uint128 liquidity, , , , ) = lens.reserves(poolId);
//         (uint128 strike, uint32 sigma, uint32 maturity, uint32 lastTimestamp, uint32 gamma) = lens.calibrations(poolId);
//         uint256 amountInWithFee = (deltaIn * gamma) / 1e4;
//         int128 invariant = lens.invariantOf(poolId);

//         uint256 nextQuote = ((uint256(reserveQuote) + amountInWithFee) * lens.PRECISION()) / liquidity;
//         uint256 nextBase = ReplicationMath.getBaseGivenQuote(
//             invariant,
//             lens.scaleFactorQuote(),
//             lens.scaleFactorBase(),
//             nextQuote,
//             strike,
//             sigma,
//             maturity - lastTimestamp
//         );

//         uint256 deltaOut = uint256(reserveBase) - (nextBase * liquidity) / lens.PRECISION();
//         return deltaOut;
//     }

//     /// @notice                 Uses basePerLiquidity and invariant to calculate quotePerLiquidity
//     /// @dev                    Converts unsigned 256-bit values to fixed point 64.64 numbers w/ decimals of precision
//     /// @param   invariantLastX64   Signed 64.64 fixed point number. Calculated w/ same `tau` as the parameter `tau`
//     /// @param   scaleFactorQuote   Unsigned 256-bit integer scaling factor for `Quote`, 10^(18 - Quote.decimals())
//     /// @param   scaleFactorBase  Unsigned 256-bit integer scaling factor for `Base`, 10^(18 - Base.decimals())
//     /// @param   basePerLiquidity Unsigned 256-bit integer of Pool's Base reserves *per liquidity*, 0 <= x <= strike
//     /// @param   strike         Unsigned 256-bit integer value with precision equal to 10^(18 - scaleFactorBase)
//     /// @param   sigma          Volatility of the Pool as an unsigned 256-bit integer w/ precision of 1e4, 10000 = 100%
//     /// @param   tau            Time until expiry in seconds as an unsigned 256-bit integer
//     /// @return  quotePerLiquidity = 1 - CDF(CDF^-1((basePerLiquidity - invariantLastX64)/K) + sigma*sqrt(tau))
//     function getQuoteGivenBase(
//         int128 invariantLastX64,
//         uint256 scaleFactorQuote,
//         uint256 scaleFactorBase,
//         uint256 basePerLiquidity,
//         uint256 strike,
//         uint256 sigma,
//         uint256 tau
//     ) internal pure returns (uint256 quotePerLiquidity) {
//         int128 strikeX64 = strike.scaleToX64(scaleFactorBase);
//         int128 volX64 = ReplicationMath.getProportionalVolatility(sigma, tau);
//         int128 baseX64 = basePerLiquidity.scaleToX64(scaleFactorBase);
//         int128 phi = baseX64.sub(invariantLastX64).div(strikeX64).getInverseCDF();
//         int128 input = phi.add(volX64);
//         int128 quoteX64 = ReplicationMath.ONE_INT.sub(input.getCDF());
//         quotePerLiquidity = quoteX64.scaleFromX64(scaleFactorQuote);
//     }

//     // note: this will probably revert because getQuoteGivenBase is not precise enough to return a valid swap
//     function getQuoteOutGivenBaseIn(bytes32 poolId, uint256 deltaIn) public view returns (uint256) {
//         IEngineView lens = IEngineView(engine);
//         (uint128 reserveQuote, uint128 reserveBase, uint128 liquidity, , , , ) = lens.reserves(poolId);
//         (uint128 strike, uint32 sigma, uint32 maturity, uint32 lastTimestamp, uint32 gamma) = lens.calibrations(poolId);
//         uint256 amountInWithFee = (deltaIn * gamma) / 1e4;
//         int128 invariant = lens.invariantOf(poolId);

//         uint256 nextBase = ((uint256(reserveBase) + amountInWithFee) * lens.PRECISION()) / liquidity;
//         uint256 nextQuote = getQuoteGivenBase(
//             invariant,
//             lens.scaleFactorQuote(),
//             lens.scaleFactorBase(),
//             nextBase,
//             strike,
//             sigma,
//             maturity - lastTimestamp
//         );

//         uint256 deltaOut = uint256(reserveQuote) - (nextQuote * liquidity) / lens.PRECISION();
//         return deltaOut;
//     }

//     function getBaseInGivenQuoteOut(bytes32 poolId, uint256 deltaOut) public view returns (uint256) {
//         IEngineView lens = IEngineView(engine);
//         (uint128 reserveQuote, uint128 reserveBase, uint128 liquidity, , , , ) = lens.reserves(poolId);
//         (uint128 strike, uint32 sigma, uint32 maturity, uint32 lastTimestamp, uint32 gamma) = lens.calibrations(poolId);
//         int128 invariant = lens.invariantOf(poolId);

//         uint256 nextQuote = ((uint256(reserveQuote) - deltaOut) * lens.PRECISION()) / liquidity;
//         uint256 nextBase = ReplicationMath.getBaseGivenQuote(
//             invariant,
//             lens.scaleFactorQuote(),
//             lens.scaleFactorBase(),
//             nextQuote,
//             strike,
//             sigma,
//             maturity - lastTimestamp
//         );

//         uint256 deltaIn = (nextBase * liquidity) / lens.PRECISION() - uint256(reserveBase);
//         uint256 deltaInWithFee = (deltaIn * 1e4) / gamma + 1;
//         return deltaInWithFee;
//     }

//     // note: this will probably revert because getQuoteGivenBase is not precise enough to return a valid swap
//     function getQuoteInGivenBaseOut(bytes32 poolId, uint256 deltaOut) public view returns (uint256) {
//         IEngineView lens = IEngineView(engine);
//         (uint128 reserveQuote, uint128 reserveBase, uint128 liquidity, , , , ) = lens.reserves(poolId);
//         (uint128 strike, uint32 sigma, uint32 maturity, uint32 lastTimestamp, uint32 gamma) = lens.calibrations(poolId);
//         int128 invariant = lens.invariantOf(poolId);

//         uint256 nextBase = ((uint256(reserveBase) - deltaOut) * lens.PRECISION()) / liquidity;
//         uint256 nextQuote = getQuoteGivenBase(
//             invariant,
//             lens.scaleFactorQuote(),
//             lens.scaleFactorBase(),
//             nextBase,
//             strike,
//             sigma,
//             maturity - lastTimestamp
//         );

//         uint256 deltaIn = (nextQuote * liquidity) / lens.PRECISION() - uint256(reserveQuote);
//         uint256 deltaInWithFee = (deltaIn * 1e4) / gamma + 1;
//         return deltaInWithFee;
//     }

//     function name() public pure override(TestBase) returns (string memory) {
//         return "TestRouter";
//     }
// }
