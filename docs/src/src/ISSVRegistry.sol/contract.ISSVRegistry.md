# ISSVRegistry
[Git Source](https://mwaysolutions.com/ssh://git@repo.2022/blockscape/playground/rocketscape/blob/be572620dc94d5c04470da0c33e204f36cca9dfa/src/ISSVRegistry.sol)


## Functions
### initialize

*Initializes the contract*


```solidity
function initialize() external;
```

### registerOperator

*Registers a new operator.*


```solidity
function registerOperator(string calldata name, address ownerAddress, bytes calldata publicKey, uint64 fee)
    external
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|Operator's display name.|
|`ownerAddress`|`address`|Operator's ethereum address that can collect fees.|
|`publicKey`|`bytes`|Operator's public key. Will be used to encrypt secret shares of validators keys.|
|`fee`|`uint64`|The fee which the operator charges for each block.|


### removeOperator

*removes an operator.*


```solidity
function removeOperator(uint32 operatorId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator id.|


### updateOperatorFee

*Updates an operator fee.*


```solidity
function updateOperatorFee(uint32 operatorId, uint64 fee) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator id.|
|`fee`|`uint64`|New operator fee.|


### updateOperatorScore

*Updates an operator fee.*


```solidity
function updateOperatorScore(uint32 operatorId, uint32 score) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator id.|
|`score`|`uint32`|New score.|


### registerValidator

*Registers a new validator.*


```solidity
function registerValidator(
    address ownerAddress,
    bytes calldata publicKey,
    uint32[] calldata operatorIds,
    bytes[] calldata sharesPublicKeys,
    bytes[] calldata sharesEncrypted
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|The user's ethereum address that is the owner of the validator.|
|`publicKey`|`bytes`|Validator public key.|
|`operatorIds`|`uint32[]`|Operator ids.|
|`sharesPublicKeys`|`bytes[]`|Shares public keys.|
|`sharesEncrypted`|`bytes[]`|Encrypted private keys.|


### removeValidator

*removes a validator.*


```solidity
function removeValidator(bytes calldata publicKey) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`publicKey`|`bytes`|Validator's public key.|


### enableOwnerValidators


```solidity
function enableOwnerValidators(address ownerAddress) external;
```

### disableOwnerValidators


```solidity
function disableOwnerValidators(address ownerAddress) external;
```

### isLiquidated


```solidity
function isLiquidated(address ownerAddress) external view returns (bool);
```

### getOperatorById

*Gets an operator by operator id.*


```solidity
function getOperatorById(uint32 operatorId)
    external
    view
    returns (string memory, address, bytes memory, uint256, uint256, uint256, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator id.|


### getOperatorsByOwnerAddress

*Returns operators for owner.*


```solidity
function getOperatorsByOwnerAddress(address ownerAddress) external view returns (uint32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|Owner's address.|


### getOperatorsByValidator

*Gets operators list which are in use by validator.*


```solidity
function getOperatorsByValidator(bytes calldata validatorPublicKey) external view returns (uint32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`validatorPublicKey`|`bytes`|Validator's public key.|


### getOperatorOwner

*Gets operator's owner.*


```solidity
function getOperatorOwner(uint32 operatorId) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator id.|


### getOperatorFee

*Gets operator current fee.*


```solidity
function getOperatorFee(uint32 operatorId) external view returns (uint64);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator id.|


### activeValidatorCount

*Gets active validator count.*


```solidity
function activeValidatorCount() external view returns (uint32);
```

### validators

*Gets an validator by public key.*


```solidity
function validators(bytes calldata publicKey) external view returns (address, bytes memory, bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`publicKey`|`bytes`|Validator's public key.|


### getValidatorsByAddress

*Gets a validator public keys by owner's address.*


```solidity
function getValidatorsByAddress(address ownerAddress) external view returns (bytes[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|Owner's Address.|


### getValidatorOwner

*Get validator's owner.*


```solidity
function getValidatorOwner(bytes calldata publicKey) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`publicKey`|`bytes`|Validator's public key.|


### validatorsPerOperatorCount

*Get validators amount per operator.*


```solidity
function validatorsPerOperatorCount(uint32 operatorId) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator public key|


## Errors
### ExceedRegisteredOperatorsByAccountLimit
errors


```solidity
error ExceedRegisteredOperatorsByAccountLimit();
```

### OperatorDeleted

```solidity
error OperatorDeleted();
```

### ValidatorAlreadyExists

```solidity
error ValidatorAlreadyExists();
```

### ExceedValidatorLimit

```solidity
error ExceedValidatorLimit();
```

### OperatorNotFound

```solidity
error OperatorNotFound();
```

### InvalidPublicKeyLength

```solidity
error InvalidPublicKeyLength();
```

### OessDataStructureInvalid

```solidity
error OessDataStructureInvalid();
```

## Structs
### Oess

```solidity
struct Oess {
    uint32 operatorId;
    bytes sharedPublicKey;
    bytes encryptedKey;
}
```

