// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.4;

/// @title   Factory Interface
/// @author  Primitive
interface IFactory {
    /// @notice         Created a new engine contract!
    /// @param  from    Calling `msg.sender` of deploy
    /// @param  quote   quote token of Engine to deploy
    /// @param  base  base token of Engine to deploy
    /// @param  market  Deployed engine address
    event DeployMarket(address indexed from, address indexed quote, address indexed base, address market);

    /// @notice         Deploys a new Engine contract and sets the `getEngine` mapping for the tokens
    /// @param  quote   quote token, the underlying token
    /// @param  base  base token, the quote token
    function deploy(address quote, address base) external returns (address engine);

    // ===== View =====

    /// @notice         Used to scale the minimum amount of liquidity to lowest precision
    /// @dev            E.g. if the lowest decimal token is 6, min liquidity w/ 18 decimals
    ///                 cannot be 1000 wei, therefore the token decimals
    ///                 divided by the min liquidity factor is the amount of minimum liquidity
    ///                 MIN_LIQUIDITY = 10 ^ (Decimals / MIN_LIQUIDITY_FACTOR)
    function MIN_LIQUIDITY_FACTOR() external pure returns (uint256);

    /// @notice                    Called within Engine constructor so Engine can set immutable
    ///                            variables without constructor args
    /// @return factory            Smart contract deploying the Engine contract
    /// @return quote              quote token
    /// @return base             base token
    /// @return scaleFactorQuote   Scale factor of the quote token, 10^(18 - quoteTokenDecimals)
    /// @return scaleFactorBase  Scale factor of the base token, 10^(18 - baseTokenDecimals)
    /// @return minLiquidity       Minimum amount of liquidity on pool creation
    function args()
        external
        view
        returns (
            address factory,
            address quote,
            address base,
            uint256 scaleFactorQuote,
            uint256 scaleFactorBase,
            uint256 minLiquidity
        );

    /// @notice         Fetches engine address of a token pair which has been deployed from this factory
    /// @param quote    quote token, the underlying token
    /// @param base   base token, the quote token
    /// @return market  market address for a quote and base token
    function getMarket(address quote, address base) external view returns (address market);

    /// @notice         Deployer does not have any access controls to wield
    /// @return         Deployer of this factory contract
    function deployer() external view returns (address);
}
