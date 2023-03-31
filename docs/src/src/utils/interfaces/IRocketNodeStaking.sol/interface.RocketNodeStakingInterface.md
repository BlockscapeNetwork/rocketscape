# RocketNodeStakingInterface
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/utils/interfaces/IRocketNodeStaking.sol)


## Functions
### getTotalRPLStake


```solidity
function getTotalRPLStake() external view returns (uint256);
```

### getNodeRPLStake


```solidity
function getNodeRPLStake(address _nodeAddress) external view returns (uint256);
```

### getNodeRPLStakedTime


```solidity
function getNodeRPLStakedTime(address _nodeAddress) external view returns (uint256);
```

### getTotalEffectiveRPLStake


```solidity
function getTotalEffectiveRPLStake() external view returns (uint256);
```

### calculateTotalEffectiveRPLStake


```solidity
function calculateTotalEffectiveRPLStake(uint256 offset, uint256 limit, uint256 rplPrice)
    external
    view
    returns (uint256);
```

### getNodeEffectiveRPLStake


```solidity
function getNodeEffectiveRPLStake(address _nodeAddress) external view returns (uint256);
```

### getNodeMinimumRPLStake


```solidity
function getNodeMinimumRPLStake(address _nodeAddress) external view returns (uint256);
```

### getNodeMaximumRPLStake


```solidity
function getNodeMaximumRPLStake(address _nodeAddress) external view returns (uint256);
```

### getNodeMinipoolLimit


```solidity
function getNodeMinipoolLimit(address _nodeAddress) external view returns (uint256);
```

### stakeRPL


```solidity
function stakeRPL(uint256 _amount) external;
```

### stakeRPLFor


```solidity
function stakeRPLFor(address _nodeAddress, uint256 _amount) external;
```

### withdrawRPL


```solidity
function withdrawRPL(uint256 _amount) external;
```

### slashRPL


```solidity
function slashRPL(address _nodeAddress, uint256 _ethSlashAmount) external;
```

