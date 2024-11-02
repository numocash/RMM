// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "../../interfaces/IEngine.sol";
// import "../../interfaces/IERC20.sol";
// import "./Scenarios.sol";

// abstract contract TestDepositCallback is Scenarios {
//     function depositCallback(
//         uint256 delQuote,
//         uint256 delBase,
//         bytes calldata data
//     ) public {
//         data;
//         if (scenario == Scenario.FAIL) return;
//         address token0 = quote();
//         address token1 = base();
//         address from = getCaller();
//         if (scenario == Scenario.QUOTE_ONLY) {
//             IERC20(token0).transferFrom(from, msg.sender, delQuote);
//         } else if (scenario == Scenario.BASE_ONLY) {
//             IERC20(token1).transferFrom(from, msg.sender, delBase);
//         } else if (scenario == Scenario.SUCCESS) {
//             IERC20(token0).transferFrom(from, msg.sender, delQuote);
//             IERC20(token1).transferFrom(from, msg.sender, delBase);
//         } else if (scenario == Scenario.REENTRANCY) {
//             IEngine(msg.sender).deposit(address(this), delQuote, delBase, data);
//         }
//     }
// }
