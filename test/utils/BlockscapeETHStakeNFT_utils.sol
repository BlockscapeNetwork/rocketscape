pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {BlockscapeETHStakeNFT} from "src_2_audit_fixes/BlockscapeETHStakeNFT.sol";
import "openzeppelin-contracts/access/AccessControl.sol";
import "./RocketPool.sol";

//import "src_2_audit_fixes/utils/BlockscapeShared.sol";

// //import {RocketPoolHelperContract} from "./RocketPool.sol";

contract HelperContract is Test, AccessControl, RocketPoolHelperContract {
    address foundryDeployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
    // address blockscapeRocketPoolNode =
    //     0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982;

    BlockscapeETHStakeNFT blockscapeETHStakeNFT;

    // address internal deployer;
    address internal rp_backend_role;
    address internal adj_config_role;
    address internal emergency_role;

    address internal singleStaker;
    address internal poolStaker1;
    address internal poolStaker2;

    uint256 availableRPL;
    uint256 reqRPL;
    uint256 minimumRPLStake;
    uint256 minipoolLimit;

    /// @dev role to adjust the config of the smart contract parameters
    bytes32 public constant ADJ_CONFIG_ROLE = keccak256("ADJ_CONFIG_ROLE");

    /// @dev role for the backendController executer
    bytes32 public constant RP_BACKEND_ROLE = keccak256("RP_BACKEND_ROLE");

    /// @dev role to open / close vault in cases of emergencies
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    constructor() {}

    function _setupParticipants() internal {
        vm.prank(foundryDeployer);
        blockscapeETHStakeNFT = new BlockscapeETHStakeNFT();

        adj_config_role = vm.addr(uint256(uint160(foundryDeployer)));
        emergency_role = vm.addr(uint256(uint160(foundryDeployer)));
        rp_backend_role = address(blockscapeRocketPoolNode);

        vm.deal(rp_backend_role, 1 ether);
        vm.label(rp_backend_role, "rp_backend");

        vm.deal(adj_config_role, 1 ether);
        vm.label(adj_config_role, "adj_config");

        vm.label(emergency_role, "emergency");

        singleStaker = vm.addr(0xDe0);
        vm.deal(singleStaker, 100 ether);
        vm.label(singleStaker, "singleStaker");

        poolStaker1 = vm.addr(0xDe1);
        vm.deal(poolStaker1, 100 ether);
        vm.label(poolStaker1, "poolStaker1");

        poolStaker2 = vm.addr(0xDe2);
        vm.deal(poolStaker2, 100 ether);
        vm.label(poolStaker2, "poolStaker2");
    }

    function _testAccessControl() internal {
        assertEq(
            hasRole(keccak256("DEFAULT_ADMIN_ROLE"), foundryDeployer),
            true
        );

        console.log("foundryDeployer", foundryDeployer);
        console.log("blockscapeRocketPoolNode", blockscapeRocketPoolNode);

        assertEq(hasRole(ADJ_CONFIG_ROLE, foundryDeployer), true);
        assertEq(hasRole(RP_BACKEND_ROLE, blockscapeRocketPoolNode), true);
        assertEq(hasRole(EMERGENCY_ROLE, foundryDeployer), true);
    }

    function _testClosingVault() internal {
        assertEq(blockscapeETHStakeNFT.isVaultOpen(), true);

        // only EMERGENCY_ROLE should be able to call function
        vm.expectRevert(
            "AccessControl: account 0xd3f7f429d80b7cdf98026230c1997b3e8a780dc5 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(singleStaker);
        blockscapeETHStakeNFT.closeVault();

        vm.expectRevert(
            "AccessControl: account 0xc69a22e55c2337e28a7f485be327ca2ff2533d10 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(adj_config_role);
        blockscapeETHStakeNFT.closeVault();

        vm.expectRevert(
            "AccessControl: account 0xf6132f532abc3902ea2dcae7f8d7fccdf7ba4982 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(rp_backend_role);
        blockscapeETHStakeNFT.closeVault();

        assertEq(blockscapeETHStakeNFT.isVaultOpen(), true);

        console.log("emergency_role", foundryDeployer);

        vm.prank(foundryDeployer);
        blockscapeETHStakeNFT.closeVault();

        assertEq(blockscapeETHStakeNFT.isVaultOpen(), false);
    }

    function _testOpeningVault() internal {
        assertEq(blockscapeETHStakeNFT.isVaultOpen(), false);

        // only EMERGENCY_ROLE should be able to call function
        vm.expectRevert(
            "AccessControl: account 0xd3f7f429d80b7cdf98026230c1997b3e8a780dc5 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(singleStaker);
        blockscapeETHStakeNFT.openVault();

        vm.expectRevert(
            "AccessControl: account 0xc69a22e55c2337e28a7f485be327ca2ff2533d10 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(adj_config_role);
        blockscapeETHStakeNFT.openVault();

        vm.expectRevert(
            "AccessControl: account 0xf6132f532abc3902ea2dcae7f8d7fccdf7ba4982 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(rp_backend_role);
        blockscapeETHStakeNFT.openVault();

        assertEq(blockscapeETHStakeNFT.isVaultOpen(), false);

        vm.prank(foundryDeployer);
        blockscapeETHStakeNFT.openVault();

        assertEq(blockscapeETHStakeNFT.isVaultOpen(), true);
    }
}
