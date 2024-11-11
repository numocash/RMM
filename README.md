# Numo 🟩 

<div align="center">
  <br />
  <a href="https://optimism.io"><img alt="Numo" src="./image/numo_readme.png" width=600></a>
  <br />
</div>

### A marketplace for options on ERC-20s.

Numo enables 24/7 option markets for leverage, income, and hedging. The smart contract suite is a inspired by @primitivefinance's open source [RMM-01](https://github.com/primitivefinance/rmm) implementation and the [replicating market makers](https://arxiv.org/abs/2103.14769) paper that first proved any option strategy can be constructed using CFMMs.

> ⚠️ **WARNING:** This code has not yet been audited. Use at your own risk.

Numo deploys a `market` instance for each pair. Each `market` can handle any two arbitrary ERC-20 token and follows the standard naming conventions seen in traditional FX markets (`base`/`quote`).

## Use Cases

### Leverage

A [european-style call options](https://en.wikipedia.org/wiki/European_option) can offer any amount of leverage. For example, a trader with $10 seeking 100x leverage on ETH can purchase a far out-of-the-money (OTM) option. Suppose ETH is currently trading at $2000, and the trader buys a call option with a strike price of $3000 and a 30-day expiry for a premium of $10. ETH however is trading at $4000 at expiration, the call option is worth 100x as the profit = (4000 - 3000) - 10 = $990.

> **Importantly**, you never lose more than the premium paid (e.g. $10) and you can never get liquidated. 

### Income

Liquidity providers on Numo earn sustainable income from selling covered call options. As in traditional options markets, **sellers** earn a premium upfront. These premiums are paid by buyers who enjoy the *right but not obligation* to exercise the call option if it is in the money. To optimize the premiums earned, a batch auction can be implemented to match buyers and sellers. 

## Setup

```bash
forge install
```

## Testing

```bash
forge test -vvv
```

### Coverage

```bash
forge coverage --report lcov
```

```bash
cmd + shift + p -> Coverage Gutters: Display Coverage
```

## Deployments

| Network  | Factory Address                                       |  
| -------- | ----------------------------------------------------- | 
| Celo     | [0x82360b9a2076a09ea8abe2b3e11aed89de3a02d1](https://explorer.celo.org/mainnet/token/0x82360b9a2076a09ea8abe2b3e11aed89de3a02d1 ) |
