// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../utils/Base64.sol";

contract Base64Mock {
    function encode(bytes memory value) external pure returns (string memory) {
        return Base64.encode(value);
    }
}
