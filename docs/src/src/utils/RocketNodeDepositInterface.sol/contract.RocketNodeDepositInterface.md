# RocketNodeDepositInterface
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/HEAD/src/utils/RocketNodeDepositInterface.sol)


## Functions
### deposit


```solidity
function deposit(
    uint256 _minimumNodeFee,
    bytes calldata _validatorPubkey,
    bytes calldata _validatorSignature,
    bytes32 _depositDataRoot,
    uint256 _salt,
    address _expectedMinipoolAddress
) external payable;
```

### getDepositType


```solidity
function getDepositType(uint256 _amount) external view returns (MinipoolDeposit);
```

