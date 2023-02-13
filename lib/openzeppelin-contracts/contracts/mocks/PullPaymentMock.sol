// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../security/PullPayment.sol";

// mock class using PullPayment
contract PullPaymentMock is PullPayment {
    constructor() payable {}

    // test helper function to call asyncTransfer
    function callTransfer(address dest, uint256 amount) public {
        _asyncTransfer(dest, amount);
    }
}
