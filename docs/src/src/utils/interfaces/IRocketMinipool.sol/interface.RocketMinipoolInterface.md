# RocketMinipoolInterface
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/utils/interfaces/IRocketMinipool.sol)


## Functions
### initialise


```solidity
function initialise(address _nodeAddress, MinipoolDeposit _depositType) external;
```

### getStatus


```solidity
function getStatus() external view returns (MinipoolStatus);
```

### getFinalised


```solidity
function getFinalised() external view returns (bool);
```

### getStatusBlock


```solidity
function getStatusBlock() external view returns (uint256);
```

### getStatusTime


```solidity
function getStatusTime() external view returns (uint256);
```

### getScrubVoted


```solidity
function getScrubVoted(address _member) external view returns (bool);
```

### getDepositType


```solidity
function getDepositType() external view returns (MinipoolDeposit);
```

### getNodeAddress


```solidity
function getNodeAddress() external view returns (address);
```

### getNodeFee


```solidity
function getNodeFee() external view returns (uint256);
```

### getNodeDepositBalance


```solidity
function getNodeDepositBalance() external view returns (uint256);
```

### getNodeRefundBalance


```solidity
function getNodeRefundBalance() external view returns (uint256);
```

### getNodeDepositAssigned


```solidity
function getNodeDepositAssigned() external view returns (bool);
```

### getUserDepositBalance


```solidity
function getUserDepositBalance() external view returns (uint256);
```

### getUserDepositAssigned


```solidity
function getUserDepositAssigned() external view returns (bool);
```

### getUserDepositAssignedTime


```solidity
function getUserDepositAssignedTime() external view returns (uint256);
```

### getTotalScrubVotes


```solidity
function getTotalScrubVotes() external view returns (uint256);
```

### calculateNodeShare


```solidity
function calculateNodeShare(uint256 _balance) external view returns (uint256);
```

### calculateUserShare


```solidity
function calculateUserShare(uint256 _balance) external view returns (uint256);
```

### nodeDeposit


```solidity
function nodeDeposit(bytes calldata _validatorPubkey, bytes calldata _validatorSignature, bytes32 _depositDataRoot)
    external
    payable;
```

### userDeposit


```solidity
function userDeposit() external payable;
```

### distributeBalance


```solidity
function distributeBalance() external;
```

### distributeBalanceAndFinalise


```solidity
function distributeBalanceAndFinalise() external;
```

### refund


```solidity
function refund() external;
```

### slash


```solidity
function slash() external;
```

### finalise


```solidity
function finalise() external;
```

### canStake


```solidity
function canStake() external view returns (bool);
```

### stake


```solidity
function stake(bytes calldata _validatorSignature, bytes32 _depositDataRoot) external;
```

### setWithdrawable


```solidity
function setWithdrawable() external;
```

### dissolve


```solidity
function dissolve() external;
```

### close


```solidity
function close() external;
```

### voteScrub


```solidity
function voteScrub() external;
```

