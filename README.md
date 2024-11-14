# Numo 🟩 

[![npm version](https://img.shields.io/npm/v/@numotrade/numo/latest.svg)](https://www.npmjs.com/package/@numotrade/numo/v/latest)

<div align="center">
  <br />
  <a href="https://optimism.io"><img alt="Numo" src="./image/numo_readme.png" width=600></a>
  <br />
</div>

### A cryptocurrency designed to be stable without a central bank.

> ⚠️ **WARNING:** This code has not yet been audited. Use at your own risk.

NUMO is a cryptocurrency with an exhange rate that [floats](https://en.wikipedia.org/wiki/Floating_exchange_rate) and maintains its stability from income generated selling options. The smart contract suite is inspired by the open source [Primitive RMM-01](https://github.com/primitivefinance/rmm) implementation and the [replicating market makers](https://arxiv.org/abs/2103.14769) paper that showed any option strategy can be constructed using AMMs.

## Motivation

Money was invented to serve three main functions: store value, facilitate exchange, and serve as a unit of account. Outside of a few majors, the majority of currencies have failed to deliver due to inadequate governance. NUMO serves as a solution by achieving all three promises without being subject to the poor management of any single government, central bank, or political headwind. Thus fufilling a fourth promise, the seperation between money and state.

## How it works

At the core, each NUMO is backed by a portfolio of assets managed by an algorithm. The algorithm dynamically adjusts the composition of the portfolio to an acceptable level of volatility while generating income from premiums earned via on-chain spot markets. (e.g. traders exercising out of the money options when they swap on Uniswap). 

On the contract level, a NUMO is issued calling `createNumo()`. Each `numo` is an ERC-20 token that will hold the reserves of two arbitrary ERC-20 tokens,`base` and `quote`. In the future, each `numo` will be able to suport more tokens in a weighted basket similar to other geometric mean market makers (e.g. balancer).

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
