# BlockscapeAccess
[Git Source](https://github.com/BlockscapeNetwork/rocketscape/blob/c46f2dd75068852009941e7857aca6a55d826b96/src/utils/BlockscapeAccess.sol)

**Inherits:**
AccessControl


## State Variables
### ADJ_CONFIG_ROLE
*role to adjust the config of the smart contract parameters*


```solidity
bytes32 internal constant ADJ_CONFIG_ROLE = keccak256("ADJ_CONFIG_ROLE");
```


### RP_BACKEND_ROLE
*role for the backendController executer*


```solidity
bytes32 internal constant RP_BACKEND_ROLE = keccak256("RP_BACKEND_ROLE");
```


### EMERGENCY_ROLE
*role to open / close vault in cases of emergencies*


```solidity
bytes32 internal constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
```


## Functions
### constructor


```solidity
constructor(address adj_config_role, address rp_backend_role, address emergency_role);
```

