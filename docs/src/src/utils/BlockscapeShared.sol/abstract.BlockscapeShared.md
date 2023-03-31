# BlockscapeShared
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/utils/BlockscapeShared.sol)

**Inherits:**
[BlockscapeAccess](/src/utils/BlockscapeAccess.sol/abstract.BlockscapeAccess.md), [BlockscapeErrors](/src/utils/BlockscapeErrors.sol/abstract.BlockscapeErrors.md), [BlockscapeEvents](/src/utils/BlockscapeEvents.sol/abstract.BlockscapeEvents.md)


## State Variables
### vaultOpen
*using OZs sendValue implementation*

*the initial vault state is open*


```solidity
bool internal vaultOpen = true;
```


### rpComm8
current initial RP commission for 8 ETH minipools, public for transparency


```solidity
uint256 public rpComm8 = 14;
```


### blockscapeRocketPoolNode
Blockscape Rocket Pool Node Address, public for transparency


```solidity
address payable public blockscapeRocketPoolNode = payable(0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982);
```


### tokenID
initial tokenID

*the tokenID is used to identify the NFTs*


```solidity
uint256 internal tokenID = 1;
```


### timelockWithdraw
*the current timelock for a withdrawal request, public for transparency*


```solidity
uint256 public timelockWithdraw = 7 days;
```


### initWithdrawFee
current initial withdraw fee, public for transparency


```solidity
uint256 public initWithdrawFee = 20 * 1e18;
```


### senderToTimestamp
*Mapping withdrawal requester to timestamp of request to keep record, public for use in UI*


```solidity
mapping(address => uint256) public senderToTimestamp;
```


### tokenIDtoMetadata
*Mappings of tokenID to Metadata*


```solidity
mapping(uint256 => Metadata) internal tokenIDtoMetadata;
```


### tokenIDToExitReward
*Mappings of tokenID to the final exit reward for the staker*


```solidity
mapping(uint256 => uint256) public tokenIDToExitReward;
```


### ROCKET_STORAGE
*RocketStorageInterface of rocketpool*


```solidity
RocketStorageInterface internal constant ROCKET_STORAGE =
    RocketStorageInterface(0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46);
```


## Functions
### getAvailableRPLStake

show the currently available RPL stake which is needed to create
a pool on rocketscape


```solidity
function getAvailableRPLStake() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the current available RPL stake with already deducted minimum stake|


### getLatestRocketNodeStaking

*rocketpool contract interface for interactions with the rocketNodeStaking contract*


```solidity
function getLatestRocketNodeStaking() internal view returns (RocketNodeStakingInterface);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`RocketNodeStakingInterface`|the rocketNodeStaking contract interface|


### getReqRPLStake

calculates the required RPL needed to stake according to
poolsize

*if the minipoollimit is `0` then the required stake is also `0`!*


```solidity
function getReqRPLStake() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the RPLs needed|


### hasNodeEnoughRPLStake

has the node enough RPL to stake another minipool


```solidity
function hasNodeEnoughRPLStake() public view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if the node has enough RPL to stake another minipool|


### setBlockscapeRocketPoolNode

gets used if blockscape changes the address of their rp node


```solidity
function setBlockscapeRocketPoolNode(address _newBlockscapeRocketPoolNode) external onlyRole(ADJ_CONFIG_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newBlockscapeRocketPoolNode`|`address`|the new address of the rocketpool node|


### _setMetadataForStakeInternal

sets the stakedETH and stakedTimestamp for a given tokenID inm the Metadata struct


```solidity
function _setMetadataForStakeInternal(uint256 _stakedETH, uint256 _tokenID) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakedETH`|`uint256`|the amount of ETH staked|
|`_tokenID`|`uint256`| the tokenID of the NFT|


### getTokenID

the tokenID is incremented with every pool


```solidity
function getTokenID() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the current tokenID|


### getBalance

how much balance does this contract current have


```solidity
function getBalance() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|amount in wei|


### getMetadata

gets the metadata of a given pool


```solidity
function getMetadata(uint256 _tokenID) external view returns (Metadata memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|identifies the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Metadata`|BlockscapeStaking.Metadata of the pool|


### openVault

makes the vault stakable again after it has been closed

*is triggered when the vault can be staked at rocketpool*


```solidity
function openVault() external onlyRole(EMERGENCY_ROLE);
```

### _openVaultInternal

opens the vault after the recent Validator data has been updated
and is associated with the recent _tokenID


```solidity
function _openVaultInternal() internal;
```

### closeVault

is triggered when the vault can be staked at rocketpool

*future staking interactions are prevented afterwards*


```solidity
function closeVault() external onlyRole(EMERGENCY_ROLE);
```

### _closeVaultInternal

closes the vault to temporarily prevent further depositing


```solidity
function _closeVaultInternal() internal;
```

### isVaultOpen

does the vault currently allow depositing

*the backend controller will reopen then vault after the stake
have been transferred*


```solidity
function isVaultOpen() public view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|is depositing enabled|


### changeWithdrawFee

the withdraw fee might be changed in the future, but cannot be higher than 20%

*only the user with the ADJ_CONFIG_ROLE can call this function*


```solidity
function changeWithdrawFee(uint256 _amount) external onlyRole(ADJ_CONFIG_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|the new fee in wei|


### changeTimelockWithdraw

the timelock for withdraw might be changed in the future, but cannot be higher than 7 days

*only the user with the ADJ_CONFIG_ROLE can call this function*


```solidity
function changeTimelockWithdraw(uint256 _newTimelock) external onlyRole(ADJ_CONFIG_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newTimelock`|`uint256`|the new timelock period in days|


### receive

allow contract to receive ETH without making a delegated call


```solidity
receive() external payable;
```

### prepareWithdrawalProcess

allow user to request a withdrawal


```solidity
function prepareWithdrawalProcess(uint256 _tokenID) external virtual;
```

### withdrawFunds

enable the user to withdraw his/her funds


```solidity
function withdrawFunds(uint256 _tokenID) external virtual;
```

### calcWithdrawFee

calculates the withdraw fee for a given user and tokenID


```solidity
function calcWithdrawFee(uint256 _tokenID, address _user) public view virtual returns (uint256 _amount);
```

## Structs
### Metadata
*Metadata struct*


```solidity
struct Metadata {
    uint256 stakedETH;
    uint256 stakedTimestamp;
}
```

