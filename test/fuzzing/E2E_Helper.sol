pragma solidity 0.8.20;
// import "./Addresses.sol";

// contract E2E_Helper is Addresses {
//     // requires tokens to be minted prior to reaching the callback
//     function mint_tokens(uint256 quoteAmt, uint256 baseAmt) internal {
//         mint_helper(address(this), quoteAmt, baseAmt);
//     }
//     function mint_tokens_sender(uint256 quoteAmt, uint256 baseAmt) internal {
//         mint_helper(msg.sender, quoteAmt, baseAmt);
//     }
//     function approve_tokens_sender(address recipient, uint256 quoteAmt, uint256 baseAmt) internal {
//         quote.approve(recipient, quoteAmt);
//         base.approve(recipient, baseAmt);
//     }
//     function mint_helper(address recip, uint256 quoteAmt, uint256 baseAmt) internal {
//         quote.mint(recip,quoteAmt);
//         base.mint(recip, baseAmt);
//     }

//     function executeCallback(uint256 delquote, uint256 delbase) internal {
//         if (delquote > 0) {
//             quote.transfer(address(engine), delquote);
//         }
//         if (delbase > 0) {
//             base.transfer(address(engine), delbase);
//         }
//     }

//     function one_to_max_uint64(uint256 random) internal returns (uint256) {
//         return 1 + (random % (type(uint64).max - 1));
//     }
// }
