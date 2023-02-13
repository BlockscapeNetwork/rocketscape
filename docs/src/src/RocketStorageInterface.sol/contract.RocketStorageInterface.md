# RocketStorageInterface
[Git Source](https://mwaysolutions.com/https://repo.blockscape/playground/rocketscape/blob/888393fdf4be87a779fc168213a7be745e8f91b1/src/RocketStorageInterface.sol)


## Functions
### getDeployedStatus


```solidity
function getDeployedStatus() external view returns (bool);
```

### getGuardian


```solidity
function getGuardian() external view returns (address);
```

### setGuardian


```solidity
function setGuardian(address _newAddress) external;
```

### confirmGuardian


```solidity
function confirmGuardian() external;
```

### getAddress


```solidity
function getAddress(bytes32 _key) external view returns (address);
```

### getUint


```solidity
function getUint(bytes32 _key) external view returns (uint256);
```

### getString


```solidity
function getString(bytes32 _key) external view returns (string memory);
```

### getBytes


```solidity
function getBytes(bytes32 _key) external view returns (bytes memory);
```

### getBool


```solidity
function getBool(bytes32 _key) external view returns (bool);
```

### getInt


```solidity
function getInt(bytes32 _key) external view returns (int256);
```

### getBytes32


```solidity
function getBytes32(bytes32 _key) external view returns (bytes32);
```

### setAddress


```solidity
function setAddress(bytes32 _key, address _value) external;
```

### setUint


```solidity
function setUint(bytes32 _key, uint256 _value) external;
```

### setString


```solidity
function setString(bytes32 _key, string calldata _value) external;
```

### setBytes


```solidity
function setBytes(bytes32 _key, bytes calldata _value) external;
```

### setBool


```solidity
function setBool(bytes32 _key, bool _value) external;
```

### setInt


```solidity
function setInt(bytes32 _key, int256 _value) external;
```

### setBytes32


```solidity
function setBytes32(bytes32 _key, bytes32 _value) external;
```

### deleteAddress


```solidity
function deleteAddress(bytes32 _key) external;
```

### deleteUint


```solidity
function deleteUint(bytes32 _key) external;
```

### deleteString


```solidity
function deleteString(bytes32 _key) external;
```

### deleteBytes


```solidity
function deleteBytes(bytes32 _key) external;
```

### deleteBool


```solidity
function deleteBool(bytes32 _key) external;
```

### deleteInt


```solidity
function deleteInt(bytes32 _key) external;
```

### deleteBytes32


```solidity
function deleteBytes32(bytes32 _key) external;
```

### addUint


```solidity
function addUint(bytes32 _key, uint256 _amount) external;
```

### subUint


```solidity
function subUint(bytes32 _key, uint256 _amount) external;
```

### getNodeWithdrawalAddress


```solidity
function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);
```

### getNodePendingWithdrawalAddress


```solidity
function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);
```

### setWithdrawalAddress


```solidity
function setWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress, bool _confirm) external;
```

### confirmWithdrawalAddress


```solidity
function confirmWithdrawalAddress(address _nodeAddress) external;
```

