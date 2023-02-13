// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

contract EtherReceiverMock {
    bool private _acceptEther;

    function setAcceptEther(bool acceptEther) public {
        _acceptEther = acceptEther;
    }

    receive() external payable {
        if (!_acceptEther) {
            revert();
        }
    }
}
