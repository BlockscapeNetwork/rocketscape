pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "./BlockscapeAccess.sol";
import "./RocketPoolVars.sol";

/// @dev for a token the vault can be set only once otherwise revert
error ErrorVaultState(bool _isOpen);

// TODO: add all natspec
abstract contract BlockscapeVault is BlockscapeAccess, RocketPoolVars {
    /**
        @notice state of the Validator Vault
        @dev is `false` when validator is currently onboarding, will be reopened, as soon as 
        the backend controller withdraws the ETH batch & stakes it
    */
    bool public vaultOpen = true;

    constructor(
        address adj_config_role,
        address rp_backend_role,
        address emergency_role
    ) {
        _grantRole(ADJ_CONFIG_ROLE, adj_config_role);
        _grantRole(RP_BACKEND_ROLE, rp_backend_role);
        _grantRole(EMERGENCY_ROLE, emergency_role);
    }

    /// @notice makes the vault stakable again after it has been closed
    /// @dev is triggered when the vault can be staked at rocketpool
    // TODO: Is further visibility needed here?
    function openVault() public onlyRole(EMERGENCY_ROLE) {
        if (!RocketPoolVars.hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        // TODO: revert Error()?
        if (vaultOpen) revert();

        vaultOpen = true;
    }

    /// @notice opens the vault after the recent Validator data has been updated
    /// and is associated with the recent _tokenID
    function _openVaultInternal() internal {
        vaultOpen = true;
    }

    /**
        @notice is triggered when the vault can be staked at rocketpool
        @dev future staking interactions are prevented afterwards
     */
    function closeVault() external onlyRole(EMERGENCY_ROLE) {
        vaultOpen = false;
    }

    /// @notice closes the vault to temporarily prevent further depositing
    function _closeVaultInternal() internal {
        BlockscapeVault.vaultOpen = false;
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
