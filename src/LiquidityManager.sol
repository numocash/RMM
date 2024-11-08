// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib, ERC20} from "solmate/utils/SafeTransferLib.sol";

import {Market, Gaussian, computeTradingFunction} from "./Market.sol";
import {InvalidTokenIn, InsufficientOptionsMinted} from "./libraries/Errors.sol";

contract LiquidityManager {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

    function mint(address receiver, address tokenIn, uint256 amountTokenToDeposit, uint256 minSharesOut)
        public
        payable
        returns (uint256 amountOut)
    {
        if (msg.value > 0 && sy.isValidTokenIn(address(0))) {
            amountOut += deposit{value: msg.value}(address(this), address(0), msg.value, 0);
        }

        if (tokenIn != address(0)) {
            ERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountTokenToDeposit);
            amountOut += deposit(receiver, tokenIn, amountTokenToDeposit, 0);
        }

        if (amountOut < minSharesOut) {
            revert InsufficientOptionsMinted(amountOut, minSharesOut);
        }
    }

    struct AllocateArgs {
        address option;
        uint256 amountIn;
        uint256 minOut;
        uint256 minLiquidityDelta;
        uint256 initialGuess;
        uint256 epsilon;
    }

    function allocateFrom(AllocateArgs calldata args) external returns (uint256 liquidity) {
        Market option = Market(payable(args.option));

        uint256 rBase = option.reserveBase();
        uint256 rQuote = option.reserveQuote();

        // validate swap approximation
        (uint256 baseToSwap, uint256 quoteOut) = computeBaseToQuoteToAddLiquidity(
            ComputeArgs({
                option: args.option,
                rBase: rBase,
                rQuote: rQuote,
                maxIn: args.amountIn,
                blockTime: block.timestamp,
                initialGuess: args.initialGuess,
                epsilon: args.epsilon
            })
        );

        // Transfer tokens and perform swap
        ERC20(baseToken).safeTransferFrom(msg.sender, address(this), args.amountIn);
        ERC20(baseToken).approve(address(option), args.amountIn);

        // Swap baseToSwap for quote tokens
        (uint256 actualQuoteOut,) = option.swapBaseForQuote(baseToSwap, args.minOut, address(this));

        // Approve and allocate liquidity
        ERC20(quoteToken).approve(address(option), type(uint256).max);
        liquidity = option.allocate(
            baseToken.balanceOf(address(this)),
            quoteToken.balanceOf(address(this)),
            args.minLiquidityDelta,
            msg.sender
        );
    }

    function computeBaseToQuoteToAddLiquidity(ComputeArgs memory args) public view returns (uint256 guess, uint256 quoteOut) {
        Market option = Market(payable(args.option));
        uint256 min = 0;
        uint256 max = args.maxIn - 1;
        
        for (uint256 iter = 0; iter < 256; ++iter) {
            guess = args.initialGuess > 0 && iter == 0 ? args.initialGuess : (min + max) / 2;
            (,, quoteOut,,) = option.prepareSwapBaseIn(guess, args.blockTime);

            uint256 baseNumerator = (args.maxIn - guess) * (args.rBase + guess);
            uint256 quoteNumerator = quoteOut * (args.rQuote - quoteOut);

            if (isAApproxB(baseNumerator, quoteNumerator, args.epsilon)) {
                return (guess, quoteOut);
            }

            if (quoteNumerator <= baseNumerator) {
                min = guess + 1;
            } else {
                max = guess - 1;
            }
        }
        revert("Binary search did not converge");
    }

    struct ComputeArgs {
        address option;
        uint256 rBase;
        uint256 rQuote;
        uint256 maxIn;
        uint256 blockTime;
        uint256 initialGuess;
        uint256 epsilon;
    }

    function computePtToSyToAddLiquidity(ComputeArgs memory args) public view returns (uint256 guess, uint256 syOut) {
        uint256 min = 0;
        uint256 max = args.maxIn - 1;
        for (uint256 iter = 0; iter < 256; ++iter) {
            guess = args.initialGuess > 0 && iter == 0 ? args.initialGuess : (min + max) / 2;
            (,, syOut,,) = RMM(payable(args.rmm)).prepareSwapPtIn(guess, args.blockTime, args.index);

            uint256 syNumerator = syOut * (args.rX - syOut);
            uint256 ptNumerator = (args.maxIn - guess) * (args.rY + guess);

            if (isAApproxB(syNumerator, ptNumerator, args.epsilon)) {
                return (guess, syOut);
            }

            if (syNumerator <= ptNumerator) {
                min = guess + 1;
            } else {
                max = guess - 1;
            }
        }
    }

    function computeToAddLiquidity(ComputeArgs memory args) public view returns (uint256 guess, uint256 ptOut) {
        Market option = Market(payable(args.rmm));
        uint256 min = 0;
        uint256 max = args.maxIn - 1;
        for (uint256 iter = 0; iter < 256; ++iter) {
            guess = args.initialGuess > 0 && iter == 0 ? args.initialGuess : (min + max) / 2;
            (,, ptOut,,) = rmm.prepareSwapSyIn(guess, args.blockTime, args.index);

            uint256 syNumerator = (args.maxIn - guess) * (args.rX + guess);
            uint256 ptNumerator = ptOut * (args.rY - ptOut);

            if (isAApproxB(syNumerator, ptNumerator, args.epsilon)) {
                return (guess, ptOut);
            }

            if (ptNumerator <= syNumerator) {
                min = guess + 1;
            } else {
                max = guess - 1;
            }
        }
    }

    function isAApproxB(uint256 a, uint256 b, uint256 eps) internal pure returns (bool) {
        return b.mulWadDown(1 ether - eps) <= a && a <= b.mulWadDown(1 ether + eps);
    }

    function calcMaxPtOut(
        uint256 reserveX_,
        uint256 reserveY_,
        uint256 totalLiquidity_,
        uint256 strike_,
        uint256 sigma_,
        uint256 tau_
    ) internal pure returns (uint256) {
        int256 currentTF = computeTradingFunction(reserveX_, reserveY_, totalLiquidity_, strike_, sigma_, tau_);
        
        uint256 maxProportion = uint256(int256(1e18) - currentTF) * 1e18 / (2 * 1e18);
        
        uint256 maxPtOut = reserveY_ * maxProportion / 1e18;
        
        return (maxPtOut * 999) / 1000;
    }

}