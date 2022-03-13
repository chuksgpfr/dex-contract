# Decentralised Exchange Project

## Full trading sequence
## We have 2 traders, Khagan and Esther:

`Khagan wants to buy 1 ABC token, at a price of up to 2 Ethers`
`Esther wants to sell 1 ABC token, for whatever price`


## This is the whole trading sequence:

> Khagan sends 2 Ethers to the DEX smart contract.
> Khagan creates a buy limit order (explained later) for a limit price of 2 Ethers, amount of 1 ABC token, and send it to DEX smart contract
> Esther sends 1 ABC token to the DEX smart contract
> Esther creates a sell market order (explained later) for an amount of 1 ABC token, and send it to DEX smart contract
> The smart contract matches Khagan and Esther order, and carry out the trade. Khagan now owns 1 ABC token and Esther 2 Ethers
> Khagan withdraws his 1 ABC token from the DEX smart contract
> Esther withdraws her 2 Ethers from the DEX smart contract

## Before users can trade, they need to transfer their ERC20 tokens / Ether to the smart contract of the DEX.

### They will:

> click on a button in the frontend that it will initiate the transfer,
>> confirm the transaction with their wallet
>>> and the Ethers / tokens will be sent at the address of the smart contract

## The orderbook is the core part of the DEX. It:

> Lists all limit orders
> Matches incoming market orders against existing limit orders
> Remove limit orders that were executed

```
Orderbooks follow a price-time algorithm. 
When an incoming market order arrive, 
the orderbook will try to match it with the market order that has the best price. 
If several limit orders have the same price, 
the one that was created first get matched in priority.
```

`What if the amount of the market and limit order don't match? Actually, that's what will happen most of the time. ?`

# Basic Sample Hardhat Project

```
This project demonstrates a basic Hardhat use case. 
It comes with a sample contract, a test for that contract, 
a sample script that deploys that contract, 
and an example of a task implementation, 
which simply lists the available accounts.
```

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
