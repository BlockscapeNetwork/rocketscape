# Blockscape Rocketscape

The Rocketscape smart contract allows users to stake their ETH and receive a Blockscape Validator NFT (BSV). BSV represents your Rocketpool Validator & each NFT is a 1-to-1 mapping to a Rocketpool Validator. The NFT is a proof of ownership of your validator and can be used to claim your stake once withdraws are enabled on Rocketpool.

## Live Deployment

Goerli Playground <https://stakedev.blockscape.network/pstake/ETH/solo/>

## Run test locally

```
forge test -vv --fork-url $MAINNET_RPC_URL --fork-block-number=16376809 --match-contract BlockscapeSoloVault
```

Replace `$MAINNET_RPC_URL` with your own mainnet rpc url.

## Git Clone

Please clone the repo with `--recursive` flag to clone the submodules.

```
git clone --recursive https://github.com/BlockscapeNetwork/rocketscape
```
