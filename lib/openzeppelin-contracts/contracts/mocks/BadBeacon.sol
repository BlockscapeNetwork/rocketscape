// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

contract BadBeaconNoImpl {}

contract BadBeaconNotContract {
    function implementation() external pure returns (address) {
        return address(0x1);
    }
}
