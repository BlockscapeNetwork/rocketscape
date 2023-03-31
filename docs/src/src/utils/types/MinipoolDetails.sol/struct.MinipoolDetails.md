# MinipoolDetails
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/utils/types/MinipoolDetails.sol)


```solidity
struct MinipoolDetails {
    bool exists;
    address minipoolAddress;
    bytes pubkey;
    MinipoolStatus status;
    uint256 statusBlock;
    uint256 statusTime;
    bool finalised;
    MinipoolDeposit depositType;
    uint256 nodeFee;
    uint256 nodeDepositBalance;
    bool nodeDepositAssigned;
    uint256 userDepositBalance;
    bool userDepositAssigned;
    uint256 userDepositAssignedTime;
    bool useLatestDelegate;
    address delegate;
    address previousDelegate;
    address effectiveDelegate;
    uint256 penaltyCount;
    uint256 penaltyRate;
}
```

