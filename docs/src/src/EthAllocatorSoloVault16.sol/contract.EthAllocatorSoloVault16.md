# BlockscapeValidatorNFT
[Git Source](https://mwaysolutions.com/https://repo.blockscape/playground/rocketscape/blob/888393fdf4be87a779fc168213a7be745e8f91b1/src/BlockscapeValidatorNFT.sol)

**Inherits:**
ERC1155Supply, ReentrancyGuard, Ownable

**Author:**
Florian Lüffe <florian.lueffe@mway.io>, Tobias Leinss <tobias.leinss@mway.io>

collects staking, mints NFT in return for staker and let's backend controller
transfer the stake when the pool is full (currently 16 ETH) and enough RPL are available


## State Variables
### rocketStorage
*RocketStorageInterface of rocketpool*


```solidity
RocketStorageInterface constant rocketStorage = RocketStorageInterface(0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46);
```


### name
Contract name


```solidity
string public constant name = "Blockscape Solo Vault";
```


### symbol
Contract symbol


```solidity
string public constant symbol = "BSV";
```


### blockscapeRocketPoolNode
Blockscape Rocket Pool Node Address


```solidity
address blockscapeRocketPoolNode = 0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982;
```


### initWithdrawFee
Current inital Withdraw Fee


```solidity
uint256 initWithdrawFee = 20 * 1e18;
```


### curETHlimit
Current Rocketpool Minipool Limit


```solidity
uint256 curETHlimit = 16 ether;
```


### allowPubDeposit
state of the Solo Vault Pool

*is `false` when pool is full, will be reopened, as soon as
the backend controller withdraws & transfers the stake*


```solidity
bool allowPubDeposit;
```


### tokenID
initial tokenID

*the tokenID is the same as the tokenID of the pool (poolID)*


```solidity
uint256 tokenID = 1;
```


### rocketNodeStakingAddress
*this is a given way to always retrieve the most up-to-date node address*


```solidity
address rocketNodeStakingAddress =
    rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", "rocketNodeStaking")));
```


### rocketNodeStaking
*rocketpool contract interface for interactions*


```solidity
RocketNodeStakingInterface rocketNodeStaking = RocketNodeStakingInterface(rocketNodeStakingAddress);
```


### tokenIDtoMetadata
*Mappings of tokenID to Metadata*


```solidity
mapping(uint256 => Metadata) tokenIDtoMetadata;
```


### tokenIDtoStaker
*Mappings of tokenID to Staker*


```solidity
mapping(uint256 => address) tokenIDtoStaker;
```


### tokenIDtoValidator
*Mappings of tokenID to Validator*


```solidity
mapping(uint256 => bytes) tokenIDtoValidator;
```


## Functions
### constructor

each pool related vault gets its separate tokenID which depicts
the nft for each staker

*the IPNS makes sure the nfts stay reachable via this link while
new nfts get added to the underlying ipfs folder*


```solidity
constructor()
    ERC1155(
        "https://ipfs.blockscape.network/ipns/" "k51qzi5uqu5divkfa2vxu2i71yhj3k6rm6bgvgnd4q00h4f80cb4imsg9uy29l/"
        "{id}.json"
    );
```

### openValidatorNFT

makes the vault stakable again after it has been closed

*is triggered when the vault can be staked at rocketpool*


```solidity
function openValidatorNFT() public onlyOwner;
```

### withdraw

withdraw the given amount to the deployer, triggered when the
the backend controller moves the stake to rocketpool

*the withdraw function remains public as safety measurement to
not lock-in client stakes in case of contract issues*


```solidity
function withdraw(uint256 _amount) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|the amount in wei to withdraw|


### closeValidatorNFT

is triggered when the vault can be staked at rocketpool

*future staking interactions are prevented afterwards*


```solidity
function closeValidatorNFT() external onlyOwner;
```

### depositValidatorNFT

used when staking eth into the contract

*the vault must be open and equal the depositing amount*


```solidity
function depositValidatorNFT() external payable nonReentrant;
```

### withdrawBatch

this gets triggered by the backend controller when the vault
is closed


```solidity
function withdrawBatch() external onlyOwner;
```

### updateValidator

set validator address for given token id

*works only once and emits, then reverts*


```solidity
function updateValidator(uint256 _tokenID, bytes memory _vali) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|Identifier of the vault|
|`_vali`|`bytes`|the current address of the validator|


### userRequestWithdraw

used when user wants to unstake


```solidity
function userRequestWithdraw(uint256 _tokenID) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|which pool the staker wants to unstake|


### changeETHLimit

the limit might change in the future if rocketpool supports
smaller pool sizes


```solidity
function changeETHLimit(uint256 _newLimit) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newLimit`|`uint256`|the new pool amount which has to be staked|


### setWithdrawFee

the withdraw fee might be changed in the future


```solidity
function setWithdrawFee(uint256 _amount) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|the new fee in wei|


### setBlockscapeRocketPoolNode

gets used if rocket pool changes the address of their node


```solidity
function setBlockscapeRocketPoolNode(address _newBlockscapeRocketPoolNode) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newBlockscapeRocketPoolNode`|`address`|the new address of the pool node|


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


### getCurrentEthLimit

the current depositing threshold


```solidity
function getCurrentEthLimit() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|is depositing enabled|


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

### viewUserRequestWithdraw

how much fees would the user has to pay if he would unstake now
within the first year of staking the fee is 20%, afterwards 0.5%


```solidity
function viewUserRequestWithdraw(uint256 _tokenID) public view returns (uint256 _amount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|which pool the staker wants to unstake|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|how much the user would pay on fees|


### getMetadata

gets the metadata of a given pool


```solidity
function getMetadata(uint256 _tokenID) external view returns (Metadata memory, address, bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|identifies the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Metadata`|Metadata of the pool|
|`<none>`|`address`|the staker address|
|`<none>`|`bytes`|the validator address|


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

how much balance does this vault current have


```solidity
function getBalance() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|amount in wei|


### totalSupply

how many staker are there totally


```solidity
function totalSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|total amount of staker|


### contractURI

stake nft metdata location

*this path will never change as the contract defines a collection*


```solidity
function contractURI() external pure returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|the fixed collection metadata path|


### uri

gets the url to the metadata of a given pool


```solidity
function uri(uint256 _tokenID) public pure override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|the pool|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|the url|


### _metadataValidatorNFTInternal

creates and mints metadata for a given pool and staker


```solidity
function _metadataValidatorNFTInternal(uint256 _stakedETH, address _staker, uint256 _tokenID) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakedETH`|`uint256`|staked amount from the sender|
|`_staker`|`address`|the sender|
|`_tokenID`|`uint256`|Identifier of the vault|


### _closeValidatorNFTInternal

closes the vault to temporarily prevent further depositing


```solidity
function _closeValidatorNFTInternal() internal;
```

### _compareBytes

compares two values and checks if there are equal

*hashes the stringified values and compares those hashes*


```solidity
function _compareBytes(bytes memory a, bytes memory b) internal pure returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|are the bytes equal|


## Events
### RPLStakeRequired
*event for when a batch is tried to withdrawn but not enough rpl
are available yet*


```solidity
event RPLStakeRequired(uint256 _availRPL, uint256 _requiredRPL);
```

### UserRequestedWithdrawal
*event for when a user requests a withdrawal*


```solidity
event UserRequestedWithdrawal(uint256 _tokenID, address _user, uint256 _fee, uint256 _stakedETH);
```

## Errors
### NotEnoughRPLStake
*more RPL stake has to be done in order to open vault*


```solidity
error NotEnoughRPLStake();
```

### ValidatorAlreadySet
Custom Errors for higher gas efficiency

for a token the validator can only be set once otherwise revert
with this error


```solidity
error ValidatorAlreadySet(bytes _vali);
```

## Structs
### Metadata
*Metadata struct*


```solidity
struct Metadata {
    uint256 stakedETH;
    uint256 stakedTimestamp;
    bool institution;
    bytes32 institutionName;
    bool institutionVerified;
}
```

