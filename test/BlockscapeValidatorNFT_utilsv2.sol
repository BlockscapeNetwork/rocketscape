pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {BlockscapeValidatorNFT} from "src_2_audit_fixes/BlockscapeValidatorNFTv2.sol";
import {RocketPoolHelperContract} from "./RocketPool.sol";

abstract contract HelperContract is Test, RocketPoolHelperContract {
    address foundryDeployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    uint256 immutable curETHlimit = 16 ether;

    BlockscapeValidatorNFT blockscapeValidatorNFT;

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

    constructor() {}

    function _setupParticipants() internal {
        vm.prank(foundryDeployer);
        blockscapeValidatorNFT = new BlockscapeValidatorNFT();

        blockscapeValidatorNFT.getCurrentEthLimit();

        adj_config_role = foundryDeployer; //vm.addr(uint256(uint160(foundryDeployer)));
        emergency_role = vm.addr(uint256(uint160(foundryDeployer)));
        // deployer = vm.addr(0xDe);

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

    function _openVaultDepositAndTestInitSetup() internal {
        _testInitContractSetup();

        _depositSoloStaker();

        assertEq(blockscapeValidatorNFT.isVaultOpen(), false);
        assertEq(blockscapeValidatorNFT.getBalance(), curETHlimit);
    }

    function _testInitContractSetup() internal {
        assertEq(blockscapeValidatorNFT.name(), "Blockscape Validator NFTs");
        assertEq(blockscapeValidatorNFT.symbol(), "BSV");
        assertEq(blockscapeValidatorNFT.getCurrentEthLimit(), curETHlimit);

        _testInitRocketPoolSetup();
        _testInitBlockscapeVaultSetup();
        _testInitBlockscapeStakingSetup();
    }

    function _testInitRocketPoolSetup() internal {
        assertEq(blockscapeValidatorNFT.getAvailableRPLStake(), 0);
        assertEq(blockscapeValidatorNFT.getReqRPLStake(), 0);
        assertEq(
            rocketNodeStaking.getNodeMinimumRPLStake(blockscapeRocketPoolNode),
            0
        );
        assertEq(
            rocketNodeStaking.getNodeMinipoolLimit(blockscapeRocketPoolNode),
            0
        );
        assertEq(blockscapeValidatorNFT.rpComm8(), 14);
    }

    function _testInitBlockscapeVaultSetup() internal {
        assertEq(blockscapeValidatorNFT.isVaultOpen(), true);
    }

    function _testInitBlockscapeStakingSetup() internal {
        assertEq(blockscapeValidatorNFT.initWithdrawFee(), 20 * 1e18);
        assertEq(blockscapeValidatorNFT.getTokenID(), 1);
        assertEq(blockscapeValidatorNFT.getBalance(), 0 ether);

        assertEq(blockscapeValidatorNFT.getMetadata(0).stakedETH, 0 ether);
        assertEq(blockscapeValidatorNFT.getMetadata(0).stakedTimestamp, 0);
    }

    function _testContractSetupAfterRPLStaking() internal {
        assertEq(blockscapeValidatorNFT.getBalance(), 0 ether);
        assertEq(blockscapeValidatorNFT.getCurrentEthLimit(), curETHlimit);

        // RocketPool
        assertEq(
            blockscapeValidatorNFT.getAvailableRPLStake(),
            rplStakeAsPerTx
        );
        assertEq(blockscapeValidatorNFT.getReqRPLStake(), 0);
        assertEq(
            rocketNodeStaking.getNodeMinimumRPLStake(blockscapeRocketPoolNode),
            0
        );
        assertEq(
            rocketNodeStaking.getNodeMinipoolLimit(blockscapeRocketPoolNode),
            1
        );
        assertEq(blockscapeValidatorNFT.rpComm8(), 14);
    }

    function _depositSoloStaker() internal {
        vm.prank(singleStaker);
        blockscapeValidatorNFT.depositValidatorNFT{value: 16 ether}();
    }
}
