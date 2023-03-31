# ValidatorAlreadySet
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/BlockscapeValidatorNFT.sol)

**Author:**
Blockscape Finance AG <info@blockscape.network>

collects staking, mints NFT in return for staker and let's backend controller
transfer the stake when the pool is full (currently 16 ETH) and enough RPL are available

this implementation relies on a backend controller which is a core component
of the implementation.

error message if a validator is already set


```solidity
error ValidatorAlreadySet(address _vali);
```

