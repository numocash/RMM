// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import "../../interfaces/IFactory.sol";
import "../engine/MockEngine.sol";

// contract MockFactory is IFactory {
//     error SameTokenError();
//     error ZeroAddressError();

//     /// @inheritdoc IFactory
//     uint256 public constant override MIN_LIQUIDITY_FACTOR = 6;
//     /// @inheritdoc IFactory
//     address public immutable override deployer;
//     mapping(address => mapping(address => address)) public override getEngine;

//     constructor() {
//         deployer = msg.sender;
//     }

//     struct Args {
//         address factory;
//         address quote;
//         address base;
//         uint256 scaleFactorQuote;
//         uint256 scaleFactorBase;
//         uint256 minLiquidity;
//     }

//     Args public override args; // Used instead of an initializer in Engine contract

//     function deploy(address quote, address base) external override returns (address engine) {
//         if (quote == base) revert SameTokenError();
//         if (quote == address(0) || base == address(0)) revert ZeroAddressError();
//         uint256 quoteDecimals = IERC20(quote).decimals();
//         uint256 baseDecimals = IERC20(base).decimals();
//         uint256 scaleFactorQuote = 10**(18 - quoteDecimals);
//         uint256 scaleFactorBase = 10**(18 - baseDecimals);
//         uint256 minLiquidity = 10**((quoteDecimals > baseDecimals ? baseDecimals : quoteDecimals) / 6);
//         args = Args({
//             factory: address(this),
//             quote: quote,
//             base: base,
//             scaleFactorQuote: scaleFactorQuote,
//             scaleFactorBase: scaleFactorBase,
//             minLiquidity: minLiquidity
//         }); // Engines call this to get constructor args
//         engine = address(new MockEngine{salt: keccak256(abi.encode(quote, base))}());
//         getEngine[quote][base] = engine;
//         emit DeployEngine(msg.sender, quote, base, engine);
//         delete args;
//     }
// }
