# Numo

### A market maker for call options on FX pairs (e.g. USD/EUR).

The smart contract suite is forked from [@primitivefinance's](https://github.com/primitivefinance/rmm-core) open source `rmm-core` repository with modifications to how the the invariant is calculated to ensure robustness for any two arbitrary ERC-20 tokens. 

Liquidity providers on Numo are **sellers** of call options that earn premiums "theta decay" paid by call option buyers. In the context of decentralized finance, these buyers are swappers who swap on the underlying liquidity. In the future, a batch auction can be implemented to match buyers and sellers. Thus, optimizing the premiums earned for option sellers.

For each unique FX pair, an `engine` contract is deployed and follows the standard naming conventions seen in traditional FX markets (`base/quote`).

## Setup

`forge install`

## Testing

`forge test -vvv`

## Coverage

`forge coverage --report lcov`

`cmd + shift + p -> Coverage Gutters: Display Coverage`

# Security

All audits are located in the `audits/` folder.

# Deployments

