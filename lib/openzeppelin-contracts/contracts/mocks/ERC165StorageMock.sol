// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../utils/introspection/ERC165Storage.sol";

contract ERC165StorageMock is ERC165Storage {
    function registerInterface(bytes4 interfaceId) public {
        _registerInterface(interfaceId);
    }
}
