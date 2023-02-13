// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../utils/introspection/ERC1820Implementer.sol";

contract ERC1820ImplementerMock is ERC1820Implementer {
    function registerInterfaceForAddress(bytes32 interfaceHash, address account) public {
        _registerInterfaceForAddress(interfaceHash, account);
    }
}
