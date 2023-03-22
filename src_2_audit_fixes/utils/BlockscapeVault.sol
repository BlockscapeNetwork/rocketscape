pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "./BlockscapeAccess.sol";
import "./RocketPoolVars.sol";

/// @dev for a token the validator can only be set once otherwise revert
error ErrorVaultState(bool _isOpen);

// TODO: add all natspec
contract BlockscapeVault is BlockscapeAccess, RocketPoolVars {
    /**
        @notice state of the Validator Vault
        @dev is `false` when validator is currently onboarding, will be reopened, as soon as 
        the backend controller withdraws the ETH batch & stakes it
    */
    bool public vaultOpen = true;

    constructor() {
        _grantRole(ADJ_CONFIG_ROLE, msg.sender);
        _grantRole(RP_BACKEND_ROLE, RocketPoolVars.blockscapeRocketPoolNode);
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
