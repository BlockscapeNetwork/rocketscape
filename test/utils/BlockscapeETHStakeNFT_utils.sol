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
            blockscapeETHStakeNFT.hasRole(ADJ_CONFIG_ROLE, foundryDeployer),
            true
        );

        assertEq(
            blockscapeETHStakeNFT.hasRole(
                RP_BACKEND_ROLE,
                blockscapeRocketPoolNode
            ),
            true
        );
        assertEq(
            blockscapeETHStakeNFT.hasRole(EMERGENCY_ROLE, foundryDeployer),
            true
        );
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

    function _testSetMetadata() internal {}

    function _testDepositStakeNFT(uint256 _value) internal {
        vm.prank(singleStaker);
        blockscapeETHStakeNFT.depositStakeNFT{value: _value}();
        assertEq(blockscapeETHStakeNFT.balanceOf(singleStaker, 1), 1);
        assertEq(blockscapeETHStakeNFT.getPoolSupply(), 1 ether);
    }

    function _testUpdateStake(uint256 _tokenID) internal {
        vm.expectRevert();
        blockscapeETHStakeNFT.updateStake(_tokenID);

        vm.prank(singleStaker);
        blockscapeETHStakeNFT.depositStakeNFT{value: 1 ether}();
        assertEq(blockscapeETHStakeNFT.balanceOf(singleStaker, 1), 1);
        assertEq(blockscapeETHStakeNFT.getPoolSupply(), 1 ether);

        vm.prank(singleStaker);
        blockscapeETHStakeNFT.updateStake(1);

        assertEq(blockscapeETHStakeNFT.balanceOf(singleStaker, 1), 1);
        assertEq(blockscapeETHStakeNFT.getPoolSupply(), 2 ether);
    }

    function _testPrepareWithdrawProcess(uint256 _tokenID) internal {
        blockscapeETHStakeNFT.prepareWithdrawProcess(_tokenID);
    }

    function _testWithdrawFunds(uint256 _tokenID) internal {
        blockscapeETHStakeNFT.withdrawFunds(_tokenID);
    }

    function _testGetPoolSupply() internal {
        blockscapeETHStakeNFT.getPoolSupply();
    }

    function _testCalcWithdrawFee(uint256 _tokenID) internal {
        blockscapeETHStakeNFT.calcWithdrawFee(_tokenID, msg.sender);
    }

    function _testCalcApr() internal {
        blockscapeETHStakeNFT.calcApr();
    }

    function _testTotalSupply() internal {
        blockscapeETHStakeNFT.totalSupply();
    }

    function _testContractURI() internal {
        blockscapeETHStakeNFT.contractURI();
    }

    function _testUri() internal {
        blockscapeETHStakeNFT.uri(1);
    }

    function _testGetAvailableRPLStake() internal {
        blockscapeETHStakeNFT.getAvailableRPLStake();
    }

    function _testGetReqRPLStake() internal {
        blockscapeETHStakeNFT.getReqRPLStake();
    }

    function _testHasNodeEnoughRPLStake() internal {
        blockscapeETHStakeNFT.hasNodeEnoughRPLStake();
    }

    function _testSetBlockscapeRocketPoolNode() internal {
        blockscapeETHStakeNFT.setBlockscapeRocketPoolNode(
            0x9C838949427022610ab4D4fbe6EDC9e6dD83b2D8
        );
    }

    function _testGetTokenID() internal {
        blockscapeETHStakeNFT.getTokenID();
    }

    function _testGetBalance() internal {
        blockscapeETHStakeNFT.getBalance();
    }

    function _testGetMetadata(uint256 _tokenID) internal {
        blockscapeETHStakeNFT.getMetadata(_tokenID);
    }

    function _testOpenVault() internal {
        blockscapeETHStakeNFT.openVault();
    }

    function _testCloseVault() internal {
        blockscapeETHStakeNFT.closeVault();
    }

    function _textIsVaultOpen() internal {
        blockscapeETHStakeNFT.isVaultOpen();
    }

    function _textLowerWithdrawFee(uint256 _newLimit) internal {
        blockscapeETHStakeNFT.lowerWithdrawFee(_newLimit);
    }

    function _textReceive() internal {}
}
