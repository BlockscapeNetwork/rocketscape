# EthAlloc
[Git Source](https://mwaysolutions.com/ssh://git@repo.2022/blockscape/playground/rocketscape/blob/be572620dc94d5c04470da0c33e204f36cca9dfa/src/EthAllocSSV.sol)

**Inherits:**
ReentrancyGuard, Ownable


## State Variables
### quadrataContract

```solidity
address public quadrataContract = address(0);
```


### is_BUSINESS

```solidity
bytes32 public constant is_BUSINESS = keccak256("IS_BUSINESS");
```


### allowPubDeposit

```solidity
bool public allowPubDeposit;
```


### tokenID

```solidity
uint256 tokenID = 0;
```


### tokenIDtoStaker

```solidity
mapping(uint256 => address[]) tokenIDtoStaker;
```


### tokenIDtoValidator

```solidity
mapping(uint256 => address) public tokenIDtoValidator;
```


### sharesPublicKeys

```solidity
bytes[] sharesPublicKeys;
```


### sharesEncrypted

```solidity
bytes[] sharesEncrypted;
```


## Functions
### constructor


```solidity
constructor(address _quadrataContract);
```

### getOperators


```solidity
function getOperators() public pure returns (uint32[4] memory OperatorIDs);
```

### depositSSV


```solidity
function depositSSV(uint32[] memory operatorIds, uint256 amount) external;
```

### openPubPool


```solidity
function openPubPool() public onlyOwner;
```

### closePubPool


```solidity
function closePubPool() public onlyOwner;
```

### closePubPoolInternal


```solidity
function closePubPoolInternal() internal;
```

### verified


```solidity
function verified(address _sender) public view returns (bool);
```

### depositEthKYB


```solidity
function depositEthKYB() public payable nonReentrant;
```

### updateValidator


```solidity
function updateValidator(uint256 _tokenID, address _vali) public onlyOwner;
```

### withdrawBatch


```solidity
function withdrawBatch() public onlyOwner;
```

### withdrawAny


```solidity
function withdrawAny(uint256 _amount) public onlyOwner;
```

### getBalance


```solidity
function getBalance() public view returns (uint256);
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

## Events
### PubPoolLimitedNearlyReached

```solidity
event PubPoolLimitedNearlyReached(uint256 _value);
```

### PubPoolOpend

```solidity
event PubPoolOpend(bool _value);
```

### PubPoolClosed

```solidity
event PubPoolClosed(bool _value);
```

### UserRequestedWithdrawal

```solidity
event UserRequestedWithdrawal(uint256 _tokenID, address _user, uint256 _fee, uint256 _stakedETH);
```

