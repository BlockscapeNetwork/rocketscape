// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

abstract contract BlockscapeErrors {

    /// @dev The vault is in the wrong state
    error ErrorVaultState(bool _isOpen);

    /// @dev more RPL stake has to be done in order to open vault
    error NotEnoughRPLStake();

    /// @dev Deposit value needs to align with RP poolsizes as specified in `curETHlimit`
    error IncorrectDepositValueSent();

    /// @dev The vault is already preparing for withdrawal
    error AlreadyPreparingForWithdrawal();

    /// @dev user does not own the NFT
    error YouDontOwnThisNft(uint256 _tokenID);
}
