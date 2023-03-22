pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "./BlockscapeAccess.sol";
import "./RocketPoolVars.sol";

/// @dev more RPL stake has to be done in order to open vault
error NotEnoughRPLStake();

/// @dev for a token the validator can only be set once otherwise revert
error ValidatorAlreadySet(address _vali);

/// @dev for a token the validator can only be set once otherwise revert
error ErrorVaultState(bool _isOpen);

// TODO: add all natspec
contract BlockscapeStaking is BlockscapeAccess, RocketPoolVars {
    /// @notice Current initial withdraw fee
    uint256 public initWithdrawFee = 20 * 1e18;

    /// @dev Mappings of tokenID to timestamp to track a request withdrawal
    mapping(address => uint256) public senderToTimestamp;

    /**
        @notice state of the Validator Vault
        @dev is `false` when validator is currently onboarding, will be reopened, as soon as 
        the backend controller withdraws the ETH batch & stakes it
    */
    bool public vaultOpen = true;

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

    constructor() {
        _grantRole(ADJ_CONFIG_ROLE, msg.sender);
        _grantRole(RP_BACKEND_ROLE, RocketPoolVars.blockscapeRocketPoolNode);
    }

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

    /// @notice makes the vault stakable again after it has been closed
    /// @dev is triggered when the vault can be staked at rocketpool
    // TODO: Is further visibility needed here?
    function openVault() public onlyRole(RP_BACKEND_ROLE) {
        if (!RocketPoolVars.hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        // TODO: revert Error()?
        if (vaultOpen) revert();

        vaultOpen = true;
    }

    /**
        @notice is triggered when the vault can be staked at rocketpool
        @dev future staking interactions are prevented afterwards
     */
    function closeVault() external onlyRole(RP_BACKEND_ROLE) {
        vaultOpen = false;
    }

    /** 
        @notice does the vault currently allow depositing
        @dev the backend controller will reopen then vault after the stake
        have been transferred
        @return is depositing enabled
    */
    function isVaultOpen() public view returns (bool) {
        return vaultOpen;
    }
}
