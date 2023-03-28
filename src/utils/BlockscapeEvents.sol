// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

abstract contract BlockscapeEvents {
    /// @dev event for when the NFT stake is updated
    event StakeUpdated(uint256 _tokenID, address _owner, uint256 _newStake);

    /// @dev event for when the ETH limit is changed
    event ETHLimitChanged(uint256 _newLimit);

    /// @dev event for when a user requests a withdrawal for a Validator NFT
    event UserRequestedWithdrawalVali(
        uint256 _tokenID,
        address _user,
        uint256 _fee,
        uint256 _stakedETH,
        uint256 _rewards
    );

    /// @dev event for when a user requests a withdrawal for a Stake ETH NFT
    event UserRequestedWithdrawalStake(
        uint256 _tokenID,
        address _user,
        uint256 _stakedETH,
        uint256 _rewards
    );

    /// @dev event for when the RocketPool Node Address is changed
    event RocketPoolNodeAddressChanged(address _newAddress);
}
