# Blockscape Rocketscape

The Rocketscape smart contract allows users to stake their ETH and receive a Blockscape Validator NFT (BSV). Each NFT is a 1-to-1 mapping to a Rocketpool Validator as the BSV delegates funds to Rocketpool.  
Therefore, a NFT is a proof of ownership and can be used to claim stake once withdraws are enabled on Rocketpool.

## Live Deployment

Goerli Playground https://stakedev.blockscape.network/pstake/ETH/solo/

## Docs

https://blockscapenetwork.github.io/rocketscape/index.html

## Run test locally

```
forge test -vv --fork-url $MAINNET_RPC_URL --fork-block-number=16376809 --match-contract BlockscapeSoloVault
```

Replace `$MAINNET_RPC_URL` with your own mainnet rpc url.

Please see [the Makefile](./Makefile) for further available commands.

## Git Clone

Please clone the repo with `--recursive` flag to clone the submodules.

```
git clone --recursive https://github.com/BlockscapeNetwork/rocketscape
```
