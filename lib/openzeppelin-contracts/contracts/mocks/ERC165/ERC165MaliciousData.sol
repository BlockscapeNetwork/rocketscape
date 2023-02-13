// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

contract ERC165MaliciousData {
    function supportsInterface(bytes4) public pure returns (bool) {
        assembly {
            mstore(0, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            return(0, 32)
        }
    }
}
