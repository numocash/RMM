pragma solidity 0.8.20;
// import "./E2E_Helper.sol";

// contract E2E_Deposit_Withdraw is E2E_Helper {
//     event DepositFailed(string reason, uint256 quote, uint256 base);
//     event DepositRevert(uint256 quote, uint256 base);

//     struct MarginHelper {
//         uint128 marginquote;
//         uint128 marginbase;
//     }

//     function populate_margin_helper(address recipient) internal returns (MarginHelper memory helper) {
//         (uint128 quote, uint128 base) = engine.margins(recipient);
//         helper.marginquote = quote;
//         helper.marginbase = base;
//     }

//     function check_deposit_withdraw_safe(uint256 quoteAmount, uint256 baseAmount) public {
//         MarginHelper memory precall = populate_margin_helper(address(this));
//         //ensures that delquote and delbase are at least 1 and not too large to overflow the deposit
//         uint256 delquote = E2E_Helper.one_to_max_uint64(quoteAmount);
//         uint256 delbase = E2E_Helper.one_to_max_uint64(baseAmount);
//         mint_tokens(delquote, delbase);
//         deposit_should_succeed(address(this), delquote, delbase);
//         withdraw_should_succeed(address(this), delquote, delbase);

//         MarginHelper memory postcall = populate_margin_helper(address(this));
//         emit DepositWithdraw("pre/post deposit-withdraw quote", precall.marginquote, postcall.marginquote, delquote);
//         emit DepositWithdraw(
//             "pre/post deposit-withdraw base",
//             precall.marginbase,
//             postcall.marginbase,
//             delbase
//         );
//         assert(precall.marginquote == postcall.marginquote);
//         assert(precall.marginbase == postcall.marginbase);
//     }

//     function deposit_with_safe_range(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) public {
//         //ensures that delquote and delbase are at least 1 and not too large to overflow the deposit
//         delquote = E2E_Helper.one_to_max_uint64(delquote);
//         delbase = E2E_Helper.one_to_max_uint64(delbase);
//         mint_tokens(delquote, delbase);
//         deposit_should_succeed(recipient, delquote, delbase);
//     }

//     function deposit_zero_zero(address recipient) public {
//         deposit_should_revert(recipient, 0, 0);
//     }

//     function deposit_should_revert(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) internal {
//         try engine.deposit(recipient, delquote, delbase, abi.encode(0)) {
//             assert(false);
//         } catch {
//             assert(true);
//         }
//     }

//     function deposit_should_succeed(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) internal {
//         MarginHelper memory precall = populate_margin_helper(recipient);
//         uint256 balanceSenderquoteBefore = quote.balanceOf(address(this));
//         uint256 balanceSenderbaseBefore = base.balanceOf(address(this));
//         uint256 balanceEnginequoteBefore = quote.balanceOf(address(engine));
//         uint256 balanceEnginebaseBefore = base.balanceOf(address(engine));

//         try engine.deposit(recipient, delquote, delbase, abi.encode(0)) {
//             // check margins
//             MarginHelper memory postcall = populate_margin_helper(recipient);
//             assert(postcall.marginquote == precall.marginquote + delquote);
//             assert(postcall.marginbase == precall.marginbase + delbase);
//             // check token balances
//             uint256 balanceSenderquoteAfter = quote.balanceOf(address(this));
//             uint256 balanceSenderbaseAfter = base.balanceOf(address(this));
//             uint256 balanceEnginequoteAfter = quote.balanceOf(address(engine));
//             uint256 balanceEnginebaseAfter = base.balanceOf(address(engine));
//             assert(balanceSenderquoteAfter == balanceSenderquoteBefore - delquote);
//             assert(balanceSenderbaseAfter == balanceSenderbaseBefore - delbase);
//             assert(balanceEnginequoteAfter == balanceEnginequoteBefore + delquote);
//             assert(balanceEnginebaseAfter == balanceEnginebaseBefore + delbase);
//         } catch {
//             uint256 balanceOfThisquote = quote.balanceOf(address(this));
//             uint256 balanceOfThisbase = base.balanceOf(address(this));
//             emit DepositRevert(balanceOfThisquote, balanceOfThisbase);
//             assert(false);
//         }
//     }

//     function withdraw_with_safe_range(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) public {
//         require(recipient != address(0));
//         require(recipient != address(engine));
//         //ensures that delquote and delbase are at least 1 and not too large to overflow the deposit
//         delquote = E2E_Helper.one_to_max_uint64(delquote);
//         delbase = E2E_Helper.one_to_max_uint64(delbase);
//         MarginHelper memory senderMargins = populate_margin_helper(address(this));
//         if (senderMargins.marginquote < delquote || senderMargins.marginbase < delbase) {
//             withdraw_should_revert(recipient, delquote, delbase);
//         } else {
//             withdraw_should_succeed(recipient, delquote, delbase);
//         }
//     }
//     function withdraw_with_only_non_zero_addr(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) public {
//         require(recipient != address(0));
//         //ensures that delquote and delbase are at least 1 and not too large to overflow the deposit
//         delquote = E2E_Helper.one_to_max_uint64(delquote);
//         delbase = E2E_Helper.one_to_max_uint64(delbase);
//         MarginHelper memory senderMargins = populate_margin_helper(address(this));
//         if (senderMargins.marginquote < delquote || senderMargins.marginbase < delbase) {
//             withdraw_should_revert(recipient, delquote, delbase);
//         } else {
//             withdraw_should_succeed(recipient, delquote, delbase);
//         }
//     }

//     function withdraw_zero_zero(address recipient) public {
//         withdraw_should_revert(recipient, 0, 0);
//     }

//     function withdraw_zero_address_recipient(uint256 delquote, uint256 delbase) public {
//         delquote = E2E_Helper.one_to_max_uint64(delquote);
//         delbase = E2E_Helper.one_to_max_uint64(delbase);
//         withdraw_should_revert(address(0), 0, 0);
//     }

//     function withdraw_should_revert(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) internal {
//         try engine.withdraw(recipient, delquote, delbase) {
//             assert(false);
//         } catch {
//             assert(true);
//         }
//     }

//     event Withdraw(
//         uint128 marginquoteBefore,
//         uint128 marginbaseBefore,
//         uint256 delquote,
//         uint256 delbase,
//         address sender,
//         address originator
//     );
//     event FailureReason(string reason);

//     function withdraw_should_succeed(
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) internal {
//         MarginHelper memory precallSender = populate_margin_helper(address(this));
//         MarginHelper memory precallRecipient = populate_margin_helper(recipient);
//         uint256 balanceRecipientquoteBefore = quote.balanceOf(recipient);
//         uint256 balanceRecipientbaseBefore = base.balanceOf(recipient);
//         uint256 balanceEnginequoteBefore = quote.balanceOf(address(engine));
//         uint256 balanceEnginebaseBefore = base.balanceOf(address(engine));

//         (bool success, ) = address(engine).call(
//             abi.encodeWithSignature("withdraw(address,uint256,uint256)", recipient, delquote, delbase)
//         );
//         if (!success) {
//             assert(false);
//             return;
//         }

//         {
//             assert_post_withdrawal(precallSender, precallRecipient, recipient, delquote, delbase);
//             //check token balances
//             uint256 balanceRecipientquoteAfter = quote.balanceOf(recipient);
//             uint256 balanceRecipientbaseAfter = base.balanceOf(recipient);
//             uint256 balanceEnginequoteAfter = quote.balanceOf(address(engine));
//             uint256 balanceEnginebaseAfter = base.balanceOf(address(engine));
//             emit DepositWithdraw("balance recip quote", balanceRecipientquoteBefore, balanceRecipientquoteAfter, delquote);
//             emit DepositWithdraw("balance recip base", balanceRecipientbaseBefore, balanceRecipientbaseAfter, delbase);
//             emit DepositWithdraw("balance engine quote", balanceEnginequoteBefore, balanceEnginequoteAfter, delquote);
//             emit DepositWithdraw("balance engine base", balanceEnginebaseBefore, balanceEnginebaseAfter, delbase);
//             assert(balanceRecipientquoteAfter == balanceRecipientquoteBefore + delquote);
//             assert(balanceRecipientbaseAfter == balanceRecipientbaseBefore + delbase);
//             assert(balanceEnginequoteAfter == balanceEnginequoteBefore - delquote);
//             assert(balanceEnginebaseAfter == balanceEnginebaseBefore - delbase);
//         }
//     }

//     event DepositWithdraw(string, uint256 before, uint256 aft, uint256 delta);

//     function assert_post_withdrawal(
//         MarginHelper memory precallThis,
//         MarginHelper memory precallRecipient,
//         address recipient,
//         uint256 delquote,
//         uint256 delbase
//     ) internal {
//         // check margins on msg.sender should decrease
//         MarginHelper memory postcallThis = populate_margin_helper(address(this));

//         assert(postcallThis.marginquote == precallThis.marginquote - delquote);
//         assert(postcallThis.marginbase == precallThis.marginbase - delbase);
//         // check margins on recipient should have no change if recipient is not addr(this)
//         if (address(this) != recipient) {
//             MarginHelper memory postCallRecipient = populate_margin_helper(recipient);
//             assert(postCallRecipient.marginquote == precallRecipient.marginquote);
//             assert(postCallRecipient.marginbase == precallRecipient.marginbase);
//         }
//     }

//     function depositCallback(
//         uint256 delquote,
//         uint256 delbase,
//         bytes calldata data
//     ) external {
//         executeCallback(delquote, delbase);
//     }
// }
