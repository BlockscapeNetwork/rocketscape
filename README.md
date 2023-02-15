# Blockscape Rocketscape

Blockscape Rocketscape is a smart contract solution that enables users to stake ETH and mint NFTs that represent their stake and rewards. Blockscape offers two types of NFTs: Blockscape Validator NFT and Blockscape ETH Stake NFT.  

A Blockscape Validator NFT is issued to a user who stakes 16 ETH with Blockscape. This NFT represents a Validator on the Blockscape platform, which is transparent and traceable on the beacon chain. The user can monitor their validator performance, rewards, and penalties through the NFT. The user can also transfer or sell their NFT at any time, or reedem the NFT for an Validator exit subject to the Ethereum 2.0 staking rules and penalties. 

The Blockscape ETH Stake NFT is issued to a user who stakes any amount of ETH with Blockscape. This NFT entitles the user to participate in a pool of stakers that are staking for them on the Blockscape platform. The user can also transfer or sell their NFT at any time, or reedem the NFT for a validator exit subject to the Ethereum staking rules and penalties.

Blockscape aims to provide a user-friendly and secure way for users to stake ETH and earn rewards, while also creating a new market for financial NFTs that have intrinsic value and utility

## Live Deployment
Goerli Playground https://stakedev.blockscape.network/pstake/ETH/solo/

## Docs
https://blockscapenetwork.github.io/rocketscape/index.html


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
