# RocketNodeDepositInterface
[Git Source](https://mwaysolutions.com/https://repo.blockscape/playground/rocketscape/blob/888393fdf4be87a779fc168213a7be745e8f91b1/src/RocketNodeDepositInterface.sol)


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

