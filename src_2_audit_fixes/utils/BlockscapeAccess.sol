pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "openzeppelin-contracts/utils/Address.sol";
import "openzeppelin-contracts/access/AccessControl.sol";

// TODO: add all natspec
contract BlockscapeAccess is AccessControl {
    /// @dev using OZs sendValue implementation
    using Address for address payable;

    /// @dev role to adjust the config of the smart contract parameters
    bytes32 public constant ADJ_CONFIG_ROLE = keccak256("ADJ_CONFIG_ROLE");

    /// @dev role for the backendController executer
    bytes32 public constant RP_BACKEND_ROLE = keccak256("RP_BACKEND_ROLE");
}
