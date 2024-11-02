// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

// import "../../libraries/Margin.sol";

// /// @title   Margin Lib API Test
// /// @author  Primitive
// /// @dev     For testing purposes ONLY

// contract TestMargin {
//     using Margin for Margin.Data;
//     using Margin for mapping(address => Margin.Data);

//     /// @notice Mapping used for testing
//     mapping(address => Margin.Data) public margins;

//     function margin() public view returns (Margin.Data memory) {
//         return margins[msg.sender];
//     }

//     /// @notice Adds to quote and base token balances
//     /// @param  delQuote  The amount of quote tokens to add to margin
//     /// @param  delBase  The amount of base tokens to add to margin
//     /// @return The margin data storage item
//     function shouldDeposit(uint256 delQuote, uint256 delBase) public returns (Margin.Data memory) {
//         uint128 preX = margins[msg.sender].balanceQuote;
//         uint128 preY = margins[msg.sender].balanceBase;
//         margins[msg.sender].deposit(delQuote, delBase);
//         assert(preX + delQuote >= margins[msg.sender].balanceQuote);
//         assert(preY + delBase >= margins[msg.sender].balanceBase);
//         return margins[msg.sender];
//     }

//     /// @notice Removes quote and riskbaaless token balance from `msg.sender`'s internal margin account
//     /// @param  delQuote  The amount of quote tokens to add to margin
//     /// @param  delBase  The amount of base tokens to add to margin
//     /// @return The margin data storage item
//     function shouldWithdraw(uint256 delQuote, uint256 delBase) public returns (Margin.Data memory) {
//         uint128 preX = margins[msg.sender].balanceQuote;
//         uint128 preY = margins[msg.sender].balanceBase;
//         margins[msg.sender] = margins.withdraw(delQuote, delBase);
//         assert(preX - delQuote >= margins[msg.sender].balanceQuote);
//         assert(preY - delBase >= margins[msg.sender].balanceBase);
//         return margins[msg.sender];
//     }
// }
