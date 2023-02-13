# EthAllocatorValidatorNFT
[Git Source](https://mwaysolutions.com/ssh://git@repo.2022/blockscape/playground/rocketscape/blob/be572620dc94d5c04470da0c33e204f36cca9dfa/src/EthAllocatorValidatorNFT.sol)

**Inherits:**
ERC1155Supply, ReentrancyGuard, Ownable


## State Variables
### name

```solidity
string public name = "Blockscape Solo Staking";
```


### symbol

```solidity
string public symbol = "BLCS SOLO";
```


### initWithdrawFee

```solidity
uint256 initWithdrawFee = 20 * 1e18;
```


### curETHlimit

```solidity
uint256 curETHlimit = 17.6 * 1e18;
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
mapping(uint256 => Metadata) tokenIDtoMetadata;
```


### tokenIDtoStaker

```solidity
mapping(uint256 => address) tokenIDtoStaker;
```


### tokenIDtoValidator

```solidity
mapping(uint256 => string) public tokenIDtoValidator;
```


## Functions
### constructor


```solidity
constructor()
    ERC1155("https://ipfs.blockscape.network/ipns/k51qzi5uqu5divkfa2vxu2i71yhj3k6rm6bgvgnd4q00h4f80cb4imsg9uy29l/{id}.json");
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

### openValidatorNFT


```solidity
function openValidatorNFT() public onlyOwner;
```

### closeValidatorNFT


```solidity
function closeValidatorNFT() public onlyOwner;
```

### openValidatorNFTInternal


```solidity
function openValidatorNFTInternal() internal;
```

### closeValidatorNFTInternal


```solidity
function closeValidatorNFTInternal() internal;
```

### metadataValidatorNFTInternal


```solidity
function metadataValidatorNFTInternal(uint256 _stakedETH, address _staker, uint256 _tokenID) internal;
```

### depositValidatorNFT


```solidity
function depositValidatorNFT() public payable nonReentrant;
```

### updateValidator


```solidity
function updateValidator(uint256 _tokenID, string memory _vali) public onlyOwner;
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
function getMetadata(uint256 _tokenID) public view returns (Metadata memory, address, string memory);
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
### PermanentURI

```solidity
event PermanentURI(string _value, uint256 indexed _id);
```

### ValidatorNFTOpend

```solidity
event ValidatorNFTOpend(bool _value);
```

### ValidatorNFTLimitedNearlyReached

```solidity
event ValidatorNFTLimitedNearlyReached(uint256 _value);
```

### ValidatorNFTClosed

```solidity
event ValidatorNFTClosed(bool _value);
```

### ValidatorSet

```solidity
event ValidatorSet(string _vali);
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
    bool institution;
    bytes32 institutionName;
    bool institutionVerified;
}
```

