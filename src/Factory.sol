// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import "./interfaces/IFactory.sol";
import "./Market.sol";

/// @title   Factory
/// @author  Robert Leifke
/// @notice  No access controls are available to deployer
/// @dev     Deploy new market contracts
contract Factory is IFactory {
    /// @notice Thrown when the quote and base tokens are the same
    error SameTokenError();

    /// @notice Thrown when the quote or the base token is 0x0...
    error ZeroAddressError();

    /// @notice Thrown on attempting to deploy an already deployed Market
    error DeployedError();

    /// @notice Thrown on attempting to deploy a pool using a token with unsupported decimals
    error DecimalsError(uint256 decimals);

    /// @notice Market will use these variables for its immutable variables
    struct Args {
        address factory;
        address quote;
        address base;
        uint256 scaleFactorquote;
        uint256 scaleFactorbase;
        uint256 minLiquidity;
    }

    /// @inheritdoc IFactory
    uint256 public constant override MIN_LIQUIDITY_FACTOR = 6;
    /// @inheritdoc IFactory
    address public immutable override deployer;
    /// @inheritdoc IFactory
    mapping(address => mapping(address => address)) public override getMarket;
    /// @inheritdoc IFactory
    Args public override args; // Used instead of an initializer in Market contract

    constructor() {
        deployer = msg.sender;
    }

    /// @inheritdoc IFactory
    function deploy(address quote, address base) external override returns (address market) {
        if (quote == base) revert SameTokenError();
        if (quote == address(0) || base == address(0)) revert ZeroAddressError();
        if (getMarket[quote][base] != address(0)) revert DeployedError();

        market = deploy(address(this), quote, base);
        getMarket[quote][base] = market;
        emit DeployMarket(msg.sender, quote, base, market);
    }

    /// @notice         Deploys an market contract with a `salt`. Only supports tokens with 6 <= decimals <= 18
    /// @dev            Market contract should have no constructor args, because this affects the deployed address
    ///                 From solidity docs:
    ///                 "It will compute the address from the address of the creating contract,
    ///                 the given salt value, the (creation) bytecode of the created contract,
    ///                 and the constructor arguments."
    ///                 While the address is still deterministic by appending constructor args to a contract's bytecode,
    ///                 it's not efficient to do so on chain.
    /// @param  factory Address of the deploying smart contract
    /// @param  quote   quote token address, underlying token
    /// @param  base  base token address, quote token
    /// @return market  Market contract address which was deployed
    function deploy(
        address factory,
        address quote,
        address base
    ) internal returns (address market) {
        (uint256 quoteDecimals, uint256 baseDecimals) = (IERC20(quote).decimals(), IERC20(base).decimals());
        if (quoteDecimals > 18 || quoteDecimals < 6) revert DecimalsError(quoteDecimals);
        if (baseDecimals > 18 || baseDecimals < 6) revert DecimalsError(baseDecimals);

        unchecked {
            uint256 scaleFactorquote = 10**(18 - quoteDecimals);
            uint256 scaleFactorbase = 10**(18 - baseDecimals);
            uint256 lowestDecimals = (quoteDecimals > baseDecimals ? baseDecimals : quoteDecimals);
            uint256 minLiquidity = 10**(lowestDecimals / MIN_LIQUIDITY_FACTOR);
            args = Args({
                factory: factory,
                quote: quote,
                base: base,
                scaleFactorquote: scaleFactorquote,
                scaleFactorbase: scaleFactorbase,
                minLiquidity: minLiquidity
            }); // Markets call this to get constructor args
        }
        
        market = address(new Market{salt: keccak256(abi.encode(quote, base))}());
        delete args;
    }
}
