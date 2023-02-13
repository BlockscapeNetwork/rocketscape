# EthAllocatorPubPool
[Git Source](https://mwaysolutions.com/https://repo.blockscape/playground/rocketscape/blob/888393fdf4be87a779fc168213a7be745e8f91b1/src/EthAllocatorPubPool.sol)

**Inherits:**
ERC1155Supply, ReentrancyGuard, Ownable


## State Variables
### name

```solidity
string public name = "Blockscape Pooled Staking Goerli";
```


### symbol

```solidity
string public symbol = "BLCS";
```


### initWithdrawFee

```solidity
uint256 initWithdrawFee = 20 * 1e18;
```


### curETHlimit

```solidity
uint256 curETHlimit = 16;
```


### allowPubDeposit

```solidity
bool public allowPubDeposit;
```


### tokenID

```solidity
uint256 tokenID = 0;
```


### tokenIDtoMetadata

```solidity
mapping(uint256 => Metadata[]) tokenIDtoMetadata;
```


### tokenIDtoStaker

```solidity
mapping(uint256 => address[]) tokenIDtoStaker;
```


### tokenIDtoValidator

```solidity
mapping(uint256 => string) public tokenIDtoValidator;
```


## Functions
### constructor


```solidity
constructor()
    ERC1155("https://ipfs.blockscape.network/ipns/k51qzi5uqu5dh28ftdiwjdoxnutwb6zio8prlyoayeill37mtpy67r67uywyeb/{id}.json");
```

### totalSupply


```solidity
function totalSupply() public view returns (uint256);
```

### contractURI


```solidity
function contractURI() public pure returns (string memory);
```

### changeETHLimit


```solidity
function changeETHLimit(uint256 _newLimit) public onlyOwner;
```

### openPubPool


```solidity
function openPubPool() public onlyOwner;
```

### closePubPool


```solidity
function closePubPool() public onlyOwner;
```

### openPubPoolInternal


```solidity
function openPubPoolInternal() internal;
```

### closePubPoolInternal


```solidity
function closePubPoolInternal() internal;
```

### metadataPubPoolInternal


```solidity
function metadataPubPoolInternal(uint256 _stakedETH, address _staker, uint256 _tokenID) internal;
```

### depositPubPool


```solidity
function depositPubPool() public payable nonReentrant;
```

### updateValidator


```solidity
function updateValidator(uint256 _tokenID, string memory _vali) public onlyOwner;
```

### compareValidator


```solidity
function compareValidator(bytes32[3] memory _vali) internal pure returns (bool);
```

### withdrawBatch


```solidity
function withdrawBatch() public onlyOwner returns (uint256);
```

### getTokenID


```solidity
function getTokenID() public view returns (uint256);
```

### withdraw


```solidity
function withdraw(uint256 _amount) public onlyOwner returns (bool);
```

### setWithdrawFee


```solidity
function setWithdrawFee(uint256 _amount) public onlyOwner;
```

### userRequestWithdraw


```solidity
function userRequestWithdraw(uint256 _tokenID) public returns (uint256 _amount);
```

### getBalance


```solidity
function getBalance() public view returns (uint256);
```

### getMetadata


```solidity
function getMetadata(uint256 _tokenID) public view returns (Metadata[] memory, address[] memory, string memory);
```

### compareStrings


```solidity
function compareStrings(string memory a, string memory b) internal pure returns (bool);
```

### compareAddr


```solidity
function compareAddr(address a, address b) internal pure returns (bool);
```

### stringToBytes


```solidity
function stringToBytes(string memory source) internal pure returns (bytes memory result);
```

### append


```solidity
function append(string memory a, string memory b, string memory c) internal pure returns (string memory);
```

### tokenURI


```solidity
function tokenURI(uint256 _tokenId) public pure returns (string memory);
```

## Events
### StakeBadgeCreated

```solidity
event StakeBadgeCreated(uint256 _ipfsID, uint256 _tokenID, Metadata _metadata);
```

### PermanentURI

```solidity
event PermanentURI(string _value, uint256 indexed _id);
```

### PubPoolOpend

```solidity
event PubPoolOpend(bool _value);
```

### PubPoolLimitedNearlyReached

```solidity
event PubPoolLimitedNearlyReached(uint256 _value);
```

### PubPoolClosed

```solidity
event PubPoolClosed(bool _value);
```

### UserRequestedWithdrawal

```solidity
event UserRequestedWithdrawal(uint256 _tokenID, address _user, uint256 _fee, uint256 _stakedETH);
```

## Structs
### Metadata

```solidity
struct Metadata {
    uint256 stakedETH;
    uint256 stakedTimestamp;
    bytes3 stakedType;
    bool institution;
    bytes32 institutionName;
    bool institutionVerified;
}
```

