// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "../../interfaces/IEngine.sol";
// import "../../interfaces/IERC20.sol";
// import "./Scenarios.sol";

// abstract contract TestSwapCallback is Scenarios {
//     function swapCallback(
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         data;

//         if (scenario == Scenario.FAIL) return;
//         address token0 = quote();
//         address token1 = base();
//         address from = getCaller();
//         if (delQuote != 0) IERC20(token0).transferFrom(from, msg.sender, delQuote);
//         if (delBase != 0) IERC20(token1).transferFrom(from, msg.sender, delBase);
//     }
// }
