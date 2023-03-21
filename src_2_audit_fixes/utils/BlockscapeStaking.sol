pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

/// @dev more RPL stake has to be done in order to open vault
// TODO: Do we need this also for StakeNFT? -> if yes uncomment, if no delete here
// TODO: Check also other error types in validator if can be shared
// error NotEnoughRPLStake();

// TODO: add all natspec
contract BlockscapeStaking {
    /// @notice Current initial withdraw fee
    uint256 public initWithdrawFee = 20 * 1e18;

    /// @dev Metadata struct
    struct Metadata {
        uint256 stakedETH;
        uint256 stakedTimestamp;
    }

    /// @dev event for when a batch is tried to withdrawn but not enough rpl
    /// are available yet
    // TODO: Not used??
    // event RPLStakeRequired(uint256 _availRPL, uint256 _requiredRPL);

    /// @dev event for when a user requests a withdrawal
    event UserRequestedWithdrawal(
        uint256 _tokenID,
        address _user,
        uint256 _fee,
        uint256 _stakedETH,
        uint256 _rewards
    );

    /// @dev Mappings of tokenID to Metadata
    mapping(uint256 => Metadata) tokenIDtoMetadata;

    /// @dev Mappings of tokenID to the final exit reward for the staker
    mapping(uint256 => uint256) public tokenIDToExitReward;

    /**
        @notice gets the metadata of a given pool
        @param _tokenID identifies the pool
        @return BlockscapeStaking.Metadata of the pool
     */
    function getMetadata(
        uint256 _tokenID
    ) external view returns (BlockscapeStaking.Metadata memory) {
        return (BlockscapeStaking.tokenIDtoMetadata[_tokenID]);
    }
}
