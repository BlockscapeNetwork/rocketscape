# ISSVNetwork
[Git Source](https://mwaysolutions.com/ssh://git@repo.2022/blockscape/playground/rocketscape/blob/be572620dc94d5c04470da0c33e204f36cca9dfa/src/ISSVNetwork.sol)


## Functions
### initialize

*Initializes the contract.*


```solidity
function initialize(
    ISSVRegistry registryAddress_,
    IERC20 token_,
    uint64 minimumBlocksBeforeLiquidation_,
    uint64 operatorMaxFeeIncrease_,
    uint64 declareOperatorFeePeriod_,
    uint64 executeOperatorFeePeriod_
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`registryAddress_`|`ISSVRegistry`|The registry address.|
|`token_`|`IERC20`|The network token.|
|`minimumBlocksBeforeLiquidation_`|`uint64`|The minimum blocks before liquidation.|
|`operatorMaxFeeIncrease_`|`uint64`||
|`declareOperatorFeePeriod_`|`uint64`|The period an operator needs to wait before they can approve their fee.|
|`executeOperatorFeePeriod_`|`uint64`|The length of the period in which an operator can approve their fee.|


### registerOperator

*Registers a new operator.*


```solidity
function registerOperator(string calldata name, bytes calldata publicKey, uint256 fee) external returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|Operator's display name.|
|`publicKey`|`bytes`|Operator's public key. Used to encrypt secret shares of validators keys.|
|`fee`|`uint256`||


### removeOperator

*Removes an operator.*


```solidity
function removeOperator(uint32 operatorId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator's id.|


### declareOperatorFee

*Set operator's fee change request by public key.*


```solidity
function declareOperatorFee(uint32 operatorId, uint256 operatorFee) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator's id.|
|`operatorFee`|`uint256`|The operator's updated fee.|


### cancelDeclaredOperatorFee


```solidity
function cancelDeclaredOperatorFee(uint32 operatorId) external;
```

### executeOperatorFee


```solidity
function executeOperatorFee(uint32 operatorId) external;
```

### updateOperatorScore

*Updates operator's score by public key.*


```solidity
function updateOperatorScore(uint32 operatorId, uint32 score) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator's id.|
|`score`|`uint32`|The operators's updated score.|


### registerValidator

*Registers a new validator.*


```solidity
function registerValidator(
    bytes calldata publicKey,
    uint32[] calldata operatorIds,
    bytes[] calldata sharesPublicKeys,
    bytes[] calldata sharesEncrypted,
    uint256 amount
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`publicKey`|`bytes`|Validator public key.|
|`operatorIds`|`uint32[]`|Operator public keys.|
|`sharesPublicKeys`|`bytes[]`|Shares public keys.|
|`sharesEncrypted`|`bytes[]`|Encrypted private keys.|
|`amount`|`uint256`|Amount of tokens to deposit.|


### updateValidator

*Updates a validator.*


```solidity
function updateValidator(
    bytes calldata publicKey,
    uint32[] calldata operatorIds,
    bytes[] calldata sharesPublicKeys,
    bytes[] calldata sharesEncrypted,
    uint256 amount
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`publicKey`|`bytes`|Validator public key.|
|`operatorIds`|`uint32[]`|Operator public keys.|
|`sharesPublicKeys`|`bytes[]`|Shares public keys.|
|`sharesEncrypted`|`bytes[]`|Encrypted private keys.|
|`amount`|`uint256`|Amount of tokens to deposit.|


### removeValidator

*Removes a validator.*


```solidity
function removeValidator(bytes calldata publicKey) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`publicKey`|`bytes`|Validator's public key.|


### deposit

*Deposits tokens for the sender.*


```solidity
function deposit(address ownerAddress, uint256 tokenAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|Owners' addresses.|
|`tokenAmount`|`uint256`|Tokens amount.|


### withdraw

*Withdraw tokens for the sender.*


```solidity
function withdraw(uint256 tokenAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenAmount`|`uint256`|Tokens amount.|


### withdrawAll

*Withdraw total balance to the sender, deactivating their validators if necessary.*


```solidity
function withdrawAll() external;
```

### liquidate

*Liquidates multiple owners.*


```solidity
function liquidate(address[] calldata ownerAddresses) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddresses`|`address[]`|Owners' addresses.|


### reactivateAccount

*Enables msg.sender account.*


```solidity
function reactivateAccount(uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Tokens amount.|


### updateLiquidationThresholdPeriod

*Updates the number of blocks left for an owner before they can be liquidated.*


```solidity
function updateLiquidationThresholdPeriod(uint64 blocks) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`blocks`|`uint64`|The new value.|


### updateOperatorFeeIncreaseLimit

*Updates the maximum fee increase in pecentage.*


```solidity
function updateOperatorFeeIncreaseLimit(uint64 newOperatorMaxFeeIncrease) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOperatorMaxFeeIncrease`|`uint64`|The new value.|


### updateDeclareOperatorFeePeriod


```solidity
function updateDeclareOperatorFeePeriod(uint64 newDeclareOperatorFeePeriod) external;
```

### updateExecuteOperatorFeePeriod


```solidity
function updateExecuteOperatorFeePeriod(uint64 newExecuteOperatorFeePeriod) external;
```

### updateNetworkFee

*Updates the network fee.*


```solidity
function updateNetworkFee(uint256 fee) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`fee`|`uint256`|the new fee|


### withdrawNetworkEarnings

*Withdraws network fees.*


```solidity
function withdrawNetworkEarnings(uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount to withdraw|


### getAddressBalance

*Gets total balance for an owner.*


```solidity
function getAddressBalance(address ownerAddress) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|Owner's address.|


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
|`operatorId`|`uint32`|Operator's id.|


### getValidatorsByOwnerAddress

*Gets a validator public keys by owner's address.*


```solidity
function getValidatorsByOwnerAddress(address ownerAddress) external view returns (bytes[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|Owner's Address.|


### getOperatorsByValidator

*Gets operators list which are in use by validator.*


```solidity
function getOperatorsByValidator(bytes calldata validatorPublicKey) external view returns (uint32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`validatorPublicKey`|`bytes`|Validator's public key.|


### getOperatorDeclaredFee


```solidity
function getOperatorDeclaredFee(uint32 operatorId) external view returns (uint256, uint256, uint256);
```

### getOperatorFee

*Gets operator current fee.*


```solidity
function getOperatorFee(uint32 operatorId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operatorId`|`uint32`|Operator's id.|


### addressNetworkFee

*Gets the network fee for an address.*


```solidity
function addressNetworkFee(address ownerAddress) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|Owner's address.|


### getAddressBurnRate

*Returns the burn rate of an owner, returns 0 if negative.*


```solidity
function getAddressBurnRate(address ownerAddress) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|Owner's address.|


### isLiquidatable

*Check if an owner is liquidatable.*


```solidity
function isLiquidatable(address ownerAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ownerAddress`|`address`|Owner's address.|


### getNetworkFee

*Returns the network fee.*


```solidity
function getNetworkFee() external view returns (uint256);
```

### getNetworkEarnings

*Gets the available network earnings*


```solidity
function getNetworkEarnings() external view returns (uint256);
```

### getLiquidationThresholdPeriod

*Returns the number of blocks left for an owner before they can be liquidated.*


```solidity
function getLiquidationThresholdPeriod() external view returns (uint256);
```

### getOperatorFeeIncreaseLimit

*Returns the maximum fee increase in pecentage*


```solidity
function getOperatorFeeIncreaseLimit() external view returns (uint256);
```

### getExecuteOperatorFeePeriod


```solidity
function getExecuteOperatorFeePeriod() external view returns (uint256);
```

### getDeclaredOperatorFeePeriod


```solidity
function getDeclaredOperatorFeePeriod() external view returns (uint256);
```

### validatorsPerOperatorCount


```solidity
function validatorsPerOperatorCount(uint32 operatorId) external view returns (uint32);
```

## Events
### AccountEnable
*Emitted when the account has been enabled.*


```solidity
event AccountEnable(address indexed ownerAddress);
```

### AccountLiquidation
*Emitted when the account has been liquidated.*


```solidity
event AccountLiquidation(address indexed ownerAddress);
```

### OperatorRegistration
*Emitted when the operator has been added.*


```solidity
event OperatorRegistration(uint32 indexed id, string name, address indexed ownerAddress, bytes publicKey, uint256 fee);
```

### OperatorRemoval
*Emitted when the operator has been removed.*


```solidity
event OperatorRemoval(uint32 operatorId, address indexed ownerAddress);
```

### OperatorFeeDeclaration

```solidity
event OperatorFeeDeclaration(address indexed ownerAddress, uint32 operatorId, uint256 blockNumber, uint256 fee);
```

### DeclaredOperatorFeeCancelation

```solidity
event DeclaredOperatorFeeCancelation(address indexed ownerAddress, uint32 operatorId);
```

### OperatorFeeExecution
*Emitted when an operator's fee is updated.*


```solidity
event OperatorFeeExecution(address indexed ownerAddress, uint32 operatorId, uint256 blockNumber, uint256 fee);
```

### OperatorScoreUpdate
*Emitted when an operator's score is updated.*


```solidity
event OperatorScoreUpdate(uint32 operatorId, address indexed ownerAddress, uint256 blockNumber, uint256 score);
```

### ValidatorRegistration
*Emitted when the validator has been added.*


```solidity
event ValidatorRegistration(
    address indexed ownerAddress, bytes publicKey, uint32[] operatorIds, bytes[] sharesPublicKeys, bytes[] encryptedKeys
);
```

### ValidatorRemoval
*Emitted when the validator is removed.*


```solidity
event ValidatorRemoval(address indexed ownerAddress, bytes publicKey);
```

### FundsDeposit
*Emitted when an owner deposits funds.*


```solidity
event FundsDeposit(uint256 value, address indexed ownerAddress, address indexed senderAddress);
```

### FundsWithdrawal
*Emitted when an owner withdraws funds.*


```solidity
event FundsWithdrawal(uint256 value, address indexed ownerAddress);
```

### NetworkFeeUpdate
*Emitted when the network fee is updated.*


```solidity
event NetworkFeeUpdate(uint256 oldFee, uint256 newFee);
```

### NetworkFeesWithdrawal
*Emitted when transfer fees are withdrawn.*


```solidity
event NetworkFeesWithdrawal(uint256 value, address recipient);
```

### DeclareOperatorFeePeriodUpdate

```solidity
event DeclareOperatorFeePeriodUpdate(uint256 value);
```

### ExecuteOperatorFeePeriodUpdate

```solidity
event ExecuteOperatorFeePeriodUpdate(uint256 value);
```

### LiquidationThresholdPeriodUpdate

```solidity
event LiquidationThresholdPeriodUpdate(uint256 value);
```

### OperatorFeeIncreaseLimitUpdate

```solidity
event OperatorFeeIncreaseLimitUpdate(uint256 value);
```

### ValidatorsPerOperatorLimitUpdate

```solidity
event ValidatorsPerOperatorLimitUpdate(uint256 value);
```

### RegisteredOperatorsPerAccountLimitUpdate

```solidity
event RegisteredOperatorsPerAccountLimitUpdate(uint256 value);
```

### MinimumBlocksBeforeLiquidationUpdate

```solidity
event MinimumBlocksBeforeLiquidationUpdate(uint256 value);
```

### OperatorMaxFeeIncreaseUpdate

```solidity
event OperatorMaxFeeIncreaseUpdate(uint256 value);
```

## Errors
### ValidatorWithPublicKeyNotExist
errors


```solidity
error ValidatorWithPublicKeyNotExist();
```

### CallerNotValidatorOwner

```solidity
error CallerNotValidatorOwner();
```

### OperatorWithPublicKeyNotExist

```solidity
error OperatorWithPublicKeyNotExist();
```

### CallerNotOperatorOwner

```solidity
error CallerNotOperatorOwner();
```

### FeeTooLow

```solidity
error FeeTooLow();
```

### FeeExceedsIncreaseLimit

```solidity
error FeeExceedsIncreaseLimit();
```

### NoPendingFeeChangeRequest

```solidity
error NoPendingFeeChangeRequest();
```

### ApprovalNotWithinTimeframe

```solidity
error ApprovalNotWithinTimeframe();
```

### NotEnoughBalance

```solidity
error NotEnoughBalance();
```

### BurnRatePositive

```solidity
error BurnRatePositive();
```

### AccountAlreadyEnabled

```solidity
error AccountAlreadyEnabled();
```

### NegativeBalance

```solidity
error NegativeBalance();
```

### BelowMinimumBlockPeriod

```solidity
error BelowMinimumBlockPeriod();
```

### ExceedManagingOperatorsPerAccountLimit

```solidity
error ExceedManagingOperatorsPerAccountLimit();
```

