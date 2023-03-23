pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "forge-std/Test.sol";

import {HelperContract} from "./BlockscapeValidatorNFT_utilsv2.sol";

abstract contract BlockscapeVaultHelperContract is Test, HelperContract {
    function _testClosingVault() internal {
        assertEq(blockscapeValidatorNFT.isVaultOpen(), true);

        // only EMERGENCY_ROLE should be able to call function
        vm.expectRevert(
            "AccessControl: account 0xd3f7f429d80b7cdf98026230c1997b3e8a780dc5 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(singleStaker);
        blockscapeValidatorNFT.closeVault();

        vm.expectRevert(
            "AccessControl: account 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(adj_config_role);
        blockscapeValidatorNFT.closeVault();

        vm.expectRevert(
            "AccessControl: account 0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(rp_backend_role);
        blockscapeValidatorNFT.closeVault();

        assertEq(blockscapeValidatorNFT.isVaultOpen(), true);

        vm.prank(emergency_role);
        blockscapeValidatorNFT.closeVault();

        assertEq(blockscapeValidatorNFT.isVaultOpen(), false);
    }

    function _testOpeningVault() internal {
        assertEq(blockscapeValidatorNFT.isVaultOpen(), false);

        // only EMERGENCY_ROLE should be able to call function
        vm.expectRevert(
            "AccessControl: account 0xd3f7f429d80b7cdf98026230c1997b3e8a780dc5 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(singleStaker);
        blockscapeValidatorNFT.openVault();

        vm.expectRevert(
            "AccessControl: account 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(adj_config_role);
        blockscapeValidatorNFT.openVault();

        vm.expectRevert(
            "AccessControl: account 0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(rp_backend_role);
        blockscapeValidatorNFT.openVault();

        assertEq(blockscapeValidatorNFT.isVaultOpen(), false);

        vm.prank(emergency_role);
        blockscapeValidatorNFT.openVault();

        assertEq(blockscapeValidatorNFT.isVaultOpen(), true);
    }
}
