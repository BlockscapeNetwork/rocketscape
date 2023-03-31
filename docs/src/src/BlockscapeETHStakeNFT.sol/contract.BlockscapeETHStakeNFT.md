# BlockscapeETHStakeNFT
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/BlockscapeETHStakeNFT.sol)

**Inherits:**
ERC1155Supply, ReentrancyGuard, [BlockscapeAccess](/src/utils/BlockscapeAccess.sol/abstract.BlockscapeAccess.md), [BlockscapeShared](/src/utils/BlockscapeShared.sol/abstract.BlockscapeShared.md)

**Author:**
Blockscape Finance AG <info@blockscape.network>

collects ETH, mints NFT in return for stake, which can be any amount of ETH. The ETH is staked in the blockscape rocketpool infrastructure.


## State Variables
### poolSupply
tracks the ETH pool supply


```solidity
uint256 private poolSupply;
```


### name
constant used for blockexplorers to display the name of the token (as to be lower case as per blockexplorer standards)


```solidity
string public constant name = "Blockscape ETH Stake NFTs";
```


### symbol
constant used for blockexplorers to display the symbol of the token (as to be lower case as per blockexplorer standards)


```solidity
string public constant symbol = "BSS";
```


## Functions
### constructor

each pool related vault gets its separate tokenID which depicts
the nft for each staker

*the IPNS makes sure the nfts stay reachable via this link while
new nfts get added to the underlying ipfs folder*


```solidity
constructor()
    ERC1155("https://ipfs.blockscape.network/ipns/" "TBD/" "{id}.json")
    BlockscapeAccess(msg.sender, BlockscapeShared.blockscapeRocketPoolNode, msg.sender);
```

### supportsInterface

*needed as the OZ ERC1155 && AccessControl does both implement the supportsInterface function*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool);
```

### depositStakeNFT

used by stakers to deposit ETH into the contract

*the vault must be open and enough RPL must be staked in the rocketpool by the node*

*the msg.value must be greater than 0*

*the msg.value is added to the poolSupply*

*if contract balance is greater than 8 ETH, the ETH is sent to the rocketpool node*


```solidity
function depositStakeNFT() external payable nonReentrant;
```

### updateStake

update the stake of the given tokenID, if the NFT owner decides to stake more ETH

*emits the StakeUpdated event & increases the poolSupply based on the msg.value*


```solidity
function updateStake(uint256 _tokenID) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|Identifier of the vault|


### prepareWithdrawalProcess

Withdraw is a two step process, first the staker has to call prepareWithdrawalProcess()

*first step used by the staker when he or she wants to unstake*


```solidity
function prepareWithdrawalProcess(uint256 _tokenID) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|which ETH Stake NFT the staker wants to unstake the backend will listen on the event and will unstake the validator. The ETH value with rewards is transparantly available via beacon chain explorers and will be reduced by the withdraw fee, which is fixed to 0.5% after one year.|


### withdrawFunds

used by the staker after prepareWithdrawalProcess() & the timelock has passed to withdraw the funds

*the rewards are calculated by the backend controller and are then stored in the contract,
this is needed to be able to calculate the rewards correctly including MEV rewards.
There off-chain calculated rewards cannot be lower than the on-chain esimated rewards.*


```solidity
function withdrawFunds(uint256 _tokenID) external override nonReentrant;
```

### getPoolSupply

returns the current ETH supply of the pool


```solidity
function getPoolSupply() public view returns (uint256);
```

### calcWithdrawFee

how much fees would the user have to pay if he or she would to unstake now
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


### calcApr

this function is a on-chain calculation of the rocketpool ETH rewards.

It does take MEV (estimated) into account.

*exp(((31556926 / 384) * 64) / 31622 / sqrt(balanceStaked)) - 1) * 100 - 0.5*

*31556926 = seconds per year*

*384 = seconds per epoch*

*31556926 / 384 = epochs per year*

*64 = BASE_REWARD_FACTOR*

*31622 = sqrt(gwei per ETH)*

*166.32368815e18 = ((31556926 / 384) * 64) / 31622*

*0x00000000219ab540356cBB839Cbe05303d7705Fa = deposit contract address*


```solidity
function calcApr() internal view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|rewards annual procentage rate * 1e18|


### calcRewards

calculates the rewards for the staker based on the current APR and the time staked


```solidity
function calcRewards(uint256 _tokenID) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenID`|`uint256`|which the rewards are calculated for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|ETH rewards in wei minus the withdraw fee|


### totalSupply

how many NFTs are there totally


```solidity
function totalSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|total amount of NFTs minted|


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

gets the url to the metadata of a given NFT tokenID


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
|`<none>`|`string`|the NFT metadata url|


