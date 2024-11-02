// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "../libraries/Margin.sol";
// import "../libraries/ReplicationMath.sol";
// import "../libraries/Reserve.sol";
// import "../libraries/SafeCast.sol";
// import "../libraries/Transfers.sol";
// import "../libraries/Units.sol";

// import "../interfaces/callback/ICreateCallback.sol";
// import "../interfaces/callback/IDepositCallback.sol";
// import "../interfaces/callback/ILiquidityCallback.sol";
// import "../interfaces/callback/ISwapCallback.sol";

// import "../interfaces/IERC20.sol";
// import "../interfaces/IEngine.sol";
// import "../interfaces/IFactory.sol";

// /// @title   Engine
// /// @author  Primitive
// /// @notice  Replicating Market Maker
// /// @dev     RMM-01
// contract EchidnaEngine is IEngine {
//     using ReplicationMath for int128;
//     using Units for uint256;
//     using SafeCast for uint256;
//     using Reserve for mapping(bytes32 => Reserve.Data);
//     using Reserve for Reserve.Data;
//     using Margin for mapping(address => Margin.Data);
//     using Margin for Margin.Data;
//     using Transfers for IERC20;

//     /// @dev            Parameters of each pool
//     /// @param strike   Strike price of pool with base token decimals
//     /// @param sigma    Implied volatility, with 1e4 decimals such that 10000 = 100%
//     /// @param maturity Timestamp of pool expiration, in seconds
//     /// @param lastTimestamp Timestamp of the pool's last update, in seconds
//     /// @param gamma    Multiplied against deltaIn amounts to apply swap fee, gamma = 1 - fee %, scaled up by 1e4
//     struct Calibration {
//         uint128 strike;
//         uint32 sigma;
//         uint32 maturity;
//         uint32 lastTimestamp;
//         uint32 gamma;
//     }

//     /// @inheritdoc IengineView
//     uint256 public constant override PRECISION = 10**18;
//     /// @inheritdoc IengineView
//     uint256 public constant override BUFFER = 120 seconds;
//     /// @inheritdoc IengineView
//     uint256 public immutable override MIN_LIQUIDITY;
//     /// @inheritdoc IengineView
//     uint256 public immutable override scaleFactorQuote;
//     /// @inheritdoc IengineView
//     uint256 public immutable override scaleFactorBase;
//     /// @inheritdoc IengineView
//     address public override factory; // immutable in main engine
//     /// @inheritdoc IengineView
//     address public immutable override quote;
//     /// @inheritdoc IengineView
//     address public immutable override base;
//     /// @dev Reentrancy guard initialized to state
//     uint256 private locked = 1;
//     /// @inheritdoc IengineView
//     mapping(bytes32 => Calibration) public override calibrations;
//     /// @inheritdoc IengineView
//     mapping(address => Margin.Data) public override margins;
//     /// @inheritdoc IengineView
//     mapping(bytes32 => Reserve.Data) public override reserves;
//     /// @inheritdoc IengineView
//     mapping(address => mapping(bytes32 => uint256)) public override liquidity;

//     modifier lock() {
//         if (locked != 1) revert LockedError();

//         locked = 2;
//         _;
//         locked = 1;
//     }

//     /// @notice Deploys an Engine with two tokens, a 'quote' and 'base'
//     constructor(address _quote, address _base, uint256 _scaleFactorquote, uint256 _scaleFactorbase, uint256 _min_liquidity) {
//         quote = _quote;
//         base = _base;
//         scaleFactorquote = _scaleFactorQuote;
//         scaleFactorbase = _scaleFactorBase;
//         MIN_LIQUIDITY = _min_liquidity;
//     }

//     /// @return quote token balance of this contract
//     function balanceQuote() private view returns (uint256) {
//         (bool success, bytes memory data) = quote.staticcall(
//             abi.encodeWithSelector(IERC20.balanceOf.selector, address(this))
//         );
//         if (!success || data.length != 32) revert BalanceError();
//         return abi.decode(data, (uint256));
//     }

//     /// @return base token balance of this contract
//     function balanceBase() private view returns (uint256) {
//         (bool success, bytes memory data) = base.staticcall(
//             abi.encodeWithSelector(IERC20.balanceOf.selector, address(this))
//         );
//         if (!success || data.length != 32) revert BalanceError();
//         return abi.decode(data, (uint256));
//     }

//     /// @notice Revert if expected amount does not exceed current balance
//     function checkquoteBalance(uint256 expectedquote) private view {
//         uint256 actualquote = balancequote();
//         if (actualquote < expectedquote) revert quoteBalanceError(expectedquote, actualquote);
//     }

//     /// @notice Revert if expected amount does not exceed current balance
//     function checkbaseBalance(uint256 expectedbase) private view {
//         uint256 actualbase = balancebase();
//         if (actualbase < expectedbase) revert baseBalanceError(expectedbase, actualbase);
//     }

//     /// @return blockTimestamp casted as a uint32
//     function _blockTimestamp() internal view virtual returns (uint32 blockTimestamp) {
//         // solhint-disable-next-line
//         blockTimestamp = uint32(block.timestamp);
//     }

//     /// @inheritdoc IengineActions
//     function updateLastTimestamp(bytes32 poolId) external override lock returns (uint32 lastTimestamp) {
//         lastTimestamp = _updateLastTimestamp(poolId);
//     }

//     /// @notice Sets the lastTimestamp of `poolId` to `block.timestamp`, max value is `maturity`
//     /// @return lastTimestamp of the pool, used in calculating the time until expiry
//     function _updateLastTimestamp(bytes32 poolId) internal virtual returns (uint32 lastTimestamp) {
//         Calibration storage cal = calibrations[poolId];
//         if (cal.lastTimestamp == 0) revert UninitializedError();

//         lastTimestamp = _blockTimestamp();
//         uint32 maturity = cal.maturity;
//         if (lastTimestamp > maturity) lastTimestamp = maturity; // if expired, set to the maturity

//         cal.lastTimestamp = lastTimestamp; // set state
//         emit UpdateLastTimestamp(poolId);
//     }

//     /// @inheritdoc IengineActions
//     function create(
//         uint128 strike,
//         uint32 sigma,
//         uint32 maturity,
//         uint32 gamma,
//         uint256 quotePerLp,
//         uint256 delLiquidity,
//         bytes calldata data
//     )
//         external
//         override
//         lock
//         returns (
//             bytes32 poolId,
//             uint256 delquote,
//             uint256 delbase
//         )
//     {
//         (uint256 factor0, uint256 factor1) = (scaleFactorquote, scaleFactorbase);
//         poolId = keccak256(abi.encodePacked(address(this), strike, sigma, maturity, gamma));
//         if (calibrations[poolId].lastTimestamp != 0) revert PoolDuplicateError();
//         if (sigma > 1e7 || sigma < 1) revert SigmaError(sigma);
//         if (strike == 0) revert StrikeError(strike);
//         if (delLiquidity <= MIN_LIQUIDITY) revert MinLiquidityError(delLiquidity);
//         if (quotePerLp > PRECISION / factor0 || quotePerLp == 0) revert quotePerLpError(quotePerLp);
//         if (gamma > Units.PERCENTAGE || gamma < 9000) revert GammaError(gamma);

//         Calibration memory cal = Calibration({
//             strike: strike,
//             sigma: sigma,
//             maturity: maturity,
//             lastTimestamp: _blockTimestamp(),
//             gamma: gamma
//         });

//         if (cal.lastTimestamp > cal.maturity) revert PoolExpiredError();
//         uint32 tau = cal.maturity - cal.lastTimestamp; // time until expiry
//         delbase = ReplicationMath.getbaseGivenquote(0, factor0, factor1, quotePerLp, cal.strike, cal.sigma, tau);
//         delquote = (quotePerLp * delLiquidity) / PRECISION; // quoteDecimals * 1e18 decimals / 1e18 = quoteDecimals
//         delbase = (delbase * delLiquidity) / PRECISION;
//         if (delquote == 0 || delbase == 0) revert CalibrationError(delquote, delbase);

//         calibrations[poolId] = cal; // state update
//         uint256 amount = delLiquidity - MIN_LIQUIDITY;
//         liquidity[msg.sender][poolId] += amount; // burn min liquidity, at cost of msg.sender
//         reserves[poolId].allocate(delquote, delbase, delLiquidity, cal.lastTimestamp); // state update

//         (uint256 balquote, uint256 balbase) = (balancequote(), balancebase());
//         IPrimitiveCreateCallback(msg.sender).createCallback(delquote, delbase, data);
//         checkquoteBalance(balquote + delquote);
//         checkbaseBalance(balbase + delbase);

//         emit Create(msg.sender, cal.strike, cal.sigma, cal.maturity, cal.gamma, delquote, delbase, amount);
//     }

//     // ===== Margin =====

//     /// @inheritdoc IengineActions
//     function deposit(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase,
//         bytes calldata data
//     ) external override lock {
//         if (delquote == 0 && delbase == 0) revert ZeroDeltasError();
//         margins[recipient].deposit(delquote, delbase); // state update

//         uint256 balquote;
//         uint256 balbase;
//         if (delquote != 0) balquote = balancequote();
//         if (delbase != 0) balbase = balancebase();
//         IPrimitiveDepositCallback(msg.sender).depositCallback(delquote, delbase, data); // agnostic payment
//         if (delquote != 0) checkquoteBalance(balquote + delquote);
//         if (delbase != 0) checkbaseBalance(balbase + delbase);
//         emit Deposit(msg.sender, recipient, delquote, delbase);
//     }

//     /// @inheritdoc IengineActions
//     function withdraw(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) external override lock {
//         if (delquote == 0 && delbase == 0) revert ZeroDeltasError();
//         margins.withdraw(delquote, delbase); // state update
//         if (delquote != 0) IERC20(quote).safeTransfer(recipient, delquote);
//         if (delbase != 0) IERC20(base).safeTransfer(recipient, delbase);
//         emit Withdraw(msg.sender, recipient, delquote, delbase);
//     }

//     // ===== Liquidity =====

//     /// @inheritdoc IengineActions
//     function allocate(
//         bytes32 poolId,
//         address recipient,
//         uint256 delquote,
//         uint256 delbase,
//         bool fromMargin,
//         bytes calldata data
//     ) external override lock returns (uint256 delLiquidity) {
//         if (delquote == 0 || delbase == 0) revert ZeroDeltasError();
//         Reserve.Data storage reserve = reserves[poolId];
//         if (reserve.blockTimestamp == 0) revert UninitializedError();
//         uint32 timestamp = _blockTimestamp();

//         uint256 liquidity0 = (delquote * reserve.liquidity) / uint256(reserve.reservequote);
//         uint256 liquidity1 = (delbase * reserve.liquidity) / uint256(reserve.reservebase);
//         delLiquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
//         if (delLiquidity == 0) revert ZeroLiquidityError();

//         liquidity[recipient][poolId] += delLiquidity; // increase position liquidity
//         reserve.allocate(delquote, delbase, delLiquidity, timestamp); // increase reserves and liquidity

//         if (fromMargin) {
//             margins.withdraw(delquote, delbase); // removes tokens from `msg.sender` margin account
//         } else {
//             (uint256 balquote, uint256 balbase) = (balancequote(), balancebase());
//             IPrimitiveLiquidityCallback(msg.sender).allocateCallback(delquote, delbase, data); // agnostic payment
//             checkquoteBalance(balquote + delquote);
//             checkbaseBalance(balbase + delbase);
//         }

//         emit Allocate(msg.sender, recipient, poolId, delquote, delbase, delLiquidity);
//     }

//     /// @inheritdoc IengineActions
//     function remove(bytes32 poolId, uint256 delLiquidity)
//         external
//         override
//         lock
//         returns (uint256 delquote, uint256 delbase)
//     {
//         if (delLiquidity == 0) revert ZeroLiquidityError();
//         Reserve.Data storage reserve = reserves[poolId];
//         if (reserve.blockTimestamp == 0) revert UninitializedError();
//         (delquote, delbase) = reserve.getAmounts(delLiquidity);

//         liquidity[msg.sender][poolId] -= delLiquidity; // state update
//         reserve.remove(delquote, delbase, delLiquidity, _blockTimestamp());
//         margins[msg.sender].deposit(delquote, delbase);

//         emit Remove(msg.sender, poolId, delquote, delbase, delLiquidity);
//     }

//     struct SwapDetails {
//         address recipient;
//         bool quoteForbase;
//         bool fromMargin;
//         bool toMargin;
//         uint32 timestamp;
//         bytes32 poolId;
//         uint256 deltaIn;
//         uint256 deltaOut;
//     }

//     /// @inheritdoc IengineActions
//     function swap(
//         address recipient,
//         bytes32 poolId,
//         bool quoteForbase,
//         uint256 deltaIn,
//         uint256 deltaOut,
//         bool fromMargin,
//         bool toMargin,
//         bytes calldata data
//     ) external override lock {
//         if (deltaIn == 0) revert DeltaInError();
//         if (deltaOut == 0) revert DeltaOutError();

//         SwapDetails memory details = SwapDetails({
//             recipient: recipient,
//             poolId: poolId,
//             deltaIn: deltaIn,
//             deltaOut: deltaOut,
//             quoteForbase: quoteForbase,
//             fromMargin: fromMargin,
//             toMargin: toMargin,
//             timestamp: _blockTimestamp()
//         });

//         uint32 lastTimestamp = _updateLastTimestamp(details.poolId); // updates lastTimestamp of `poolId`
//         if (details.timestamp > lastTimestamp + BUFFER) revert PoolExpiredError(); // 120s buffer to allow final swaps
//         int128 invariantX64 = invariantOf(details.poolId); // stored in memory to perform the invariant check

//         {
//             // swap scope, avoids stack too deep errors
//             Calibration memory cal = calibrations[details.poolId];
//             Reserve.Data storage reserve = reserves[details.poolId];
//             uint32 tau = cal.maturity - cal.lastTimestamp;
//             uint256 deltaInWithFee = (details.deltaIn * cal.gamma) / Units.PERCENTAGE; // amount * (1 - fee %)

//             uint256 adjustedquote;
//             uint256 adjustedbase;
//             if (details.quoteForbase) {
//                 adjustedquote = uint256(reserve.reservequote) + deltaInWithFee;
//                 adjustedbase = uint256(reserve.reservebase) - deltaOut;
//             } else {
//                 adjustedquote = uint256(reserve.reservequote) - deltaOut;
//                 adjustedbase = uint256(reserve.reservebase) + deltaInWithFee;
//             }
//             adjustedquote = (adjustedquote * PRECISION) / reserve.liquidity;
//             adjustedbase = (adjustedbase * PRECISION) / reserve.liquidity;

//             int128 invariantAfter = ReplicationMath.calcInvariant(
//                 scaleFactorquote,
//                 scaleFactorbase,
//                 adjustedquote,
//                 adjustedbase,
//                 cal.strike,
//                 cal.sigma,
//                 tau
//             );

//             if (invariantX64 > invariantAfter) revert InvariantError(invariantX64, invariantAfter);
//             reserve.swap(details.quoteForbase, details.deltaIn, details.deltaOut, details.timestamp); // state update
//         }

//         if (details.quoteForbase) {
//             if (details.toMargin) {
//                 margins[details.recipient].deposit(0, details.deltaOut);
//             } else {
//                 IERC20(base).safeTransfer(details.recipient, details.deltaOut); // optimistic transfer out
//             }

//             if (details.fromMargin) {
//                 margins.withdraw(details.deltaIn, 0); // pay for swap
//             } else {
//                 uint256 balquote = balancequote();
//                 IPrimitiveSwapCallback(msg.sender).swapCallback(details.deltaIn, 0, data); // agnostic transfer in
//                 checkquoteBalance(balquote + details.deltaIn);
//             }
//         } else {
//             if (details.toMargin) {
//                 margins[details.recipient].deposit(details.deltaOut, 0);
//             } else {
//                 IERC20(quote).safeTransfer(details.recipient, details.deltaOut); // optimistic transfer out
//             }

//             if (details.fromMargin) {
//                 margins.withdraw(0, details.deltaIn); // pay for swap
//             } else {
//                 uint256 balbase = balancebase();
//                 IPrimitiveSwapCallback(msg.sender).swapCallback(0, details.deltaIn, data); // agnostic transfer in
//                 checkbaseBalance(balbase + details.deltaIn);
//             }
//         }

//         emit Swap(
//             msg.sender,
//             details.recipient,
//             details.poolId,
//             details.quoteForbase,
//             details.deltaIn,
//             details.deltaOut
//         );
//     }

//     // ===== View =====

//     /// @inheritdoc IengineView
//     function invariantOf(bytes32 poolId) public view override returns (int128 invariant) {
//         Calibration memory cal = calibrations[poolId];
//         uint32 tau = cal.maturity - cal.lastTimestamp; // cal maturity can never be less than lastTimestamp
//         (uint256 quotePerLiquidity, uint256 basePerLiquidity) = reserves[poolId].getAmounts(PRECISION); // 1e18 liquidity
//         invariant = ReplicationMath.calcInvariant(
//             scaleFactorquote,
//             scaleFactorbase,
//             quotePerLiquidity,
//             basePerLiquidity,
//             cal.strike,
//             cal.sigma,
//             tau
//         );
//     }
// }
