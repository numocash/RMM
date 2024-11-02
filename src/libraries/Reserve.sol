// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import "./SafeCast.sol";

/// @title   Reserves Library
/// @author  Primitive
/// @dev     Data structure library for an Engine's Reserves
library Reserve {
    using SafeCast for uint256;

    /// @notice                Stores global state of a pool
    /// @param reserveQuote    quote token reserve
    /// @param reserveBase   base token reserve
    /// @param liquidity       Total supply of liquidity
    /// @param blockTimestamp  Last timestamp of which updated the accumulators
    /// @param cumulativeQuote Cumulative sum of the quote reserves
    /// @param cumulativeBase Cumulative sum of base reserves
    /// @param cumulativeLiquidity Cumulative sum of total liquidity supply
    struct Data {
        uint128 reserveQuote;
        uint128 reserveBase;
        uint128 liquidity;
        uint32 blockTimestamp;
        uint256 cumulativeQuote;
        uint256 cumulativeBase;
        uint256 cumulativeLiquidity;
    }

    /// @notice                 Adds to the cumulative reserves
    /// @dev                    Overflow is desired on the cumulative values
    /// @param  res             Reserve storage to update
    /// @param  blockTimestamp  Checkpoint timestamp of update
    function update(Data storage res, uint32 blockTimestamp) internal {
        uint32 deltaTime = blockTimestamp - res.blockTimestamp;
        // overflow is desired
        if (deltaTime != 0) {
            unchecked {
                res.cumulativeQuote += uint256(res.reserveQuote) * deltaTime;
                res.cumulativeBase += uint256(res.reserveBase) * deltaTime;
                res.cumulativeLiquidity += uint256(res.liquidity) * deltaTime;
            }
            res.blockTimestamp = blockTimestamp;
        }
    }

    /// @notice                 Increases one reserve value and decreases the other
    /// @param  reserve         Reserve state to update
    /// @param  quoteForBase  Direction of swap
    /// @param  deltaIn         Amount of tokens paid, increases one reserve by
    /// @param  deltaOut        Amount of tokens sent out, decreases the other reserve by
    /// @param  blockTimestamp  Timestamp used to update cumulative reserves
    function swap(
        Data storage reserve,
        bool quoteForBase,
        uint256 deltaIn,
        uint256 deltaOut,
        uint32 blockTimestamp
    ) internal {
        update(reserve, blockTimestamp);
        if (quoteForBase) {
            reserve.reserveQuote += deltaIn.toUint128();
            reserve.reserveBase -= deltaOut.toUint128();
        } else {
            reserve.reserveQuote -= deltaOut.toUint128();
            reserve.reserveBase += deltaIn.toUint128();
        }
    }

    /// @notice                 Add to both reserves and total supply of liquidity
    /// @param  reserve         Reserve storage to manipulate
    /// @param  delQuote        Amount of quote tokens to add to the reserve
    /// @param  delBase       Amount of base tokens to add to the reserve
    /// @param  delLiquidity    Amount of liquidity created with the provided tokens
    /// @param  blockTimestamp  Timestamp used to update cumulative reserves
    function allocate(
        Data storage reserve,
        uint256 delQuote,
        uint256 delBase,
        uint256 delLiquidity,
        uint32 blockTimestamp
    ) internal {
        update(reserve, blockTimestamp);
        reserve.reserveQuote += delQuote.toUint128();
        reserve.reserveBase += delBase.toUint128();
        reserve.liquidity += delLiquidity.toUint128();
    }

    /// @notice                 Remove from both reserves and total supply of liquidity
    /// @param  reserve         Reserve storage to manipulate
    /// @param  delQuote        Amount of quote tokens to remove to the reserve
    /// @param  delBase       Amount of base tokens to remove to the reserve
    /// @param  delLiquidity    Amount of liquidity removed from total supply
    /// @param  blockTimestamp  Timestamp used to update cumulative reserves
    function remove(
        Data storage reserve,
        uint256 delQuote,
        uint256 delBase,
        uint256 delLiquidity,
        uint32 blockTimestamp
    ) internal {
        update(reserve, blockTimestamp);
        reserve.reserveQuote -= delQuote.toUint128();
        reserve.reserveBase -= delBase.toUint128();
        reserve.liquidity -= delLiquidity.toUint128();
    }

    /// @notice                 Calculates quote and base token amounts of `delLiquidity`
    /// @param reserve          Reserve in memory to use reserves and liquidity of
    /// @param delLiquidity     Amount of liquidity to fetch underlying tokens of
    /// @return delQuote        Amount of quote tokens controlled by `delLiquidity`
    /// @return delBase       Amount of base tokens controlled by `delLiquidity`
    function getAmounts(Data memory reserve, uint256 delLiquidity)
        internal
        pure
        returns (uint256 delQuote, uint256 delBase)
    {
        uint256 liq = uint256(reserve.liquidity);
        delQuote = (delLiquidity * uint256(reserve.reserveQuote)) / liq;
        delBase = (delLiquidity * uint256(reserve.reserveBase)) / liq;
    }
}
