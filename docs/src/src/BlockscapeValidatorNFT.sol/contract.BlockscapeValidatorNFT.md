# BlockscapeValidatorNFT
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/BlockscapeValidatorNFT.sol)

**Inherits:**
ERC1155Supply, ReentrancyGuard, [BlockscapeAccess](/src/utils/BlockscapeAccess.sol/abstract.BlockscapeAccess.md), [BlockscapeShared](/src/utils/BlockscapeShared.sol/abstract.BlockscapeShared.md)


## State Variables
### name
name constant used for blockexplorers (as to be lower case as per blockexplorer standards)


```solidity
string public constant name = "Blockscape Validator NFTs";
```


### symbol
symbol constant used for blockexplorers (as to be lower case as per blockexplorer standards)


```solidity
string public constant symbol = "BSV";
```


### curETHlimit
Current Rocketpool Minipool Limit


```solidity
uint256 private curETHlimit = 16 ether;
```


### tokenIDtoValidator
*mapping of tokenID to validator minipool address*


```solidity
mapping(uint256 => address) private tokenIDtoValidator;
```


## Functions
### constructor

each validator related vault gets its separate tokenID which depicts
the nft for each staker

*the IPNS makes sure the nfts stay reachable via this link while
new nfts get added to the underlying ipfs folder*


```solidity
constructor()
    ERC1155(
        "https://ipfs.blockscape.network/ipns/" "k51qzi5uqu5di5eo5fzr1zypdsz0zct39zpct9s4wesjustul1caeofak3zoej/"
        "{id}.json"
    )
    BlockscapeAccess(msg.sender, BlockscapeShared.blockscapeRocketPoolNode, msg.sender);
```

### supportsInterface

*needed as the OZ ERC1155 && AccessControl does both implement the supportsInterface function*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool);
```

### depositValidatorNFT

used by stakers to deposit ETH into the contract

*the vault must be open and equal the depositing amount*

*enought RPL must be staked in the rocketpool by the node*


```solidity
function depositValidatorNFT() external payable;
```

### withdrawBatch

this gets triggered by the backend controller when a new token is minted

*the backend controller is only able to withdraw the current ETH limit*


```solidity
function withdrawBatch() external onlyRole(RP_BACKEND_ROLE) nonReentrant;
```

### updateValidator

update validator address for given token id only once after the NFT has been issued
and the validator was created by the backend
this function will only be called by the backend

*works only once for a tokenID; it will reopen the vault*

*emits no event by design to reduce maintenance costs*


```solidity
function updateValidator(uint256 _tokenID, address _vali) external onlyRole(RP_BACKEND_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|Identifier of the NFT|
|`_vali`|`address`|the current address of the validator|


### prepareWithdrawalProcess

Withdraw is a two step process, first the staker has to call prepareWithdrawalProcess()

*fist step used by the staker when he or she wants to unstake*


```solidity
function prepareWithdrawalProcess(uint256 _tokenID) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|which validator NFT the staker wants to unstake; the backend will listen on the event and will unstake the validator. The ETH value with rewards is transparantly available via beacon chain explorers and will be reduced by the withdraw fee, which is fixed to 0.5% after one year.|


### withdrawFunds

used by the staker after prepareWithdrawalProcess() & the timelock has passed to withdraw the funds

*the rewards are calculated by the backend controller and are then stored in the contract,
this is needed to be able to calculate the rewards correctly including MEV rewards.*

*There off-chain calculated rewards cannot be lower than the on-chain estimated rewards.*


```solidity
function withdrawFunds(uint256 _tokenID) external override;
```

### calcRewards

this function is called by the backend controller when the UserRequestedWithdrawal is emited

*the rewards are calculated by the backend controller and are then stored in the contract,
this is needed to be able to calculate the rewards correctly including MEV rewards.
There off-chain calculated rewards cannot be lower than the on-chain estimated rewards.*


```solidity
function calcRewards(uint256 _tokenID, uint256 _calcReward) public onlyRole(RP_BACKEND_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|the tokenID of the validator|
|`_calcReward`|`uint256`|the calculated rewards in wei|


### changeETHLimit8

the limit might change in the future if rocketpool supports
smaller pool sizes (RPIP-8)

*this function is only callable by our multisig wallet with ADJ_CONFIG_ROLE*

*it will only allow to set the limit to 8 ETH*


```solidity
function changeETHLimit8() external onlyRole(ADJ_CONFIG_ROLE);
```

### lowerRPCommFee8

*this function is only callable by our multisig wallet with ADJ_CONFIG_ROLE*

*this will set the comission fee for 8 ETH minipools*


```solidity
function lowerRPCommFee8(uint256 _amount) external onlyRole(ADJ_CONFIG_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|the new comission|


### getCurrentEthLimit

the current depositing threshold


```solidity
function getCurrentEthLimit() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the current ETH limit in wei|


### calcWithdrawFee

how much fees would the user has to pay if he or she would unstake now
within the first year of staking the fee is starting at 20% & decreasing linearly, afterwards 0.5%


```solidity
function calcWithdrawFee(uint256 _tokenID, address _user) public view override returns (uint256 _amount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|which NFT the staker wants to unstake|
|`_user`|`address`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|how much the user would pay on fees in percent*1e18|


### getValidatorAddress

this function is used to get the validator address from the tokenID


```solidity
function getValidatorAddress(uint256 _tokenID) public view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|the tokenID of the NFT|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|the minipool address of the validator|


### estRewardsNoMEV

this function is a on-chain calculation of the rocketpool ETH rewards.
It does not take MEV into account & will only work correctly
after the Shapella/Shanghai upgrade


```solidity
function estRewardsNoMEV(uint256 _tokenID) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|tokenID of the NFT, the user wants to unstake|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|rewards in wei minus the withdraw fee|


### totalSupply

total amount of supply


```solidity
function totalSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|total amount of ERC-1155 tokens of the contract|


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


