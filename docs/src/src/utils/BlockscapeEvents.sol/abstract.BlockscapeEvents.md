# BlockscapeEvents
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/utils/BlockscapeEvents.sol)


## Events
### StakeUpdated
*event for when the NFT stake is updated*


```solidity
event StakeUpdated(uint256 indexed _tokenID, address indexed _owner, uint256 _newStake);
```

### ETHLimitChanged
*event for when the ETH limit is changed*


```solidity
event ETHLimitChanged(uint256 _newLimit);
```

### UserRequestedWithdrawalVali
*event for when a user requests a withdrawal for a Validator NFT*


```solidity
event UserRequestedWithdrawalVali(
    uint256 indexed _tokenID, address indexed _user, uint256 _fee, uint256 _stakedETH, uint256 _rewards
);
```

### UserRequestedWithdrawalStake
*event for when a user requests a withdrawal for a Stake ETH NFT*


```solidity
event UserRequestedWithdrawalStake(
    uint256 indexed _tokenID, address indexed _user, uint256 _stakedETH, uint256 _rewards
);
```

### RocketPoolNodeAddressChanged
*event for when the RocketPool Node Address is changed*


```solidity
event RocketPoolNodeAddressChanged(address _newAddress);
```

### WithdrawFeeChanged
*event for when the withdraw fee is changed*


```solidity
event WithdrawFeeChanged(uint256 _newFee);
```

### TimelockWithdrawChanged
*event for when the timelock for a withdrawal is changed*


```solidity
event TimelockWithdrawChanged(uint256 _newTimelock);
```

### EmergencyVaultStateChanged
*event for when the vault is opened / closed in case of emergency*


```solidity
event EmergencyVaultStateChanged(bool _isOpen);
```

