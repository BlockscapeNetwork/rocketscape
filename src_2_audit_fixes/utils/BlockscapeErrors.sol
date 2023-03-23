// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

abstract contract BlockscapeErrors {
    error ErrorVaultState(bool _isOpen);
    /// @dev more RPL stake has to be done in order to open vault
    error NotEnoughRPLStake();

    /// @dev Deposit value needs to align with RP poolsizes as specified in `curETHlimit`
    error IncorrectDepositValueSent();

    // TODO: @dev
    error AlreadyPreparingForWithdrawal();

    error YouDontOwnThisNft(uint256 _tokenID);
}
