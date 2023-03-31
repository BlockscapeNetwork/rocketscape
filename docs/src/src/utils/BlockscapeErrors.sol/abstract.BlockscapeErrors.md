# BlockscapeErrors
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/utils/BlockscapeErrors.sol)


## Errors
### ErrorVaultState
*The vault is in the wrong state*


```solidity
error ErrorVaultState(bool _isOpen);
```

### NotEnoughRPLStake
*more RPL stake has to be done in order to open vault*


```solidity
error NotEnoughRPLStake();
```

### IncorrectDepositValueSent
*Deposit value needs to align with RP poolsizes as specified in `curETHlimit`*


```solidity
error IncorrectDepositValueSent();
```

### AlreadyPreparingForWithdrawal
*The vault is already preparing for withdrawal*


```solidity
error AlreadyPreparingForWithdrawal();
```

### WithdrawalTimelockNotReached
*The withdrawal has a timelock which is not yet reached*


```solidity
error WithdrawalTimelockNotReached(uint256 unlockTimestamp);
```

### YouDontOwnThisNft
*user does not own the NFT*


```solidity
error YouDontOwnThisNft(uint256 _tokenID);
```

