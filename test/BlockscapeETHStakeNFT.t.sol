// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {BlockscapeETHStakeNFT} from "src_2_audit_fixes/BlockscapeETHStakeNFT.sol";
import {HelperContract} from "./utils/BlockscapeETHStakeNFT_utils.sol";

contract BlockscapeETHStakeNFTTest is Test, HelperContract {
    bytes validatorBytesAddress =
        hex"a2e78385831894094502727373588fc1794ea2800b2b6e614358fea78dcf0cc4d103008a53c665f294e31af0397253e3";

    address minipoolAddr = 0x626CA3f82a4A11C2226101eeEA35Fcc25a5fE91D;

    function setUp() public {
        _setupParticipants();
    }

    function testAccess() public {
        _testAccessControl();
    }

    function testVault() public {
        _testClosingVault();
        _blockscapeStakeRPL();
        _testOpeningVault();
    }

    function testStaking() public {
        _testSetMetadata();

        _blockscapeStakeRPL();
        //_testContractSetupAfterRPLStaking();
        // only RP_BACKEND_ROLE should be able to call function
        vm.expectRevert(
            "AccessControl: account 0xd3f7f429d80b7cdf98026230c1997b3e8a780dc5 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
        );
        vm.prank(singleStaker);
        blockscapeETHStakeNFT.closeVault();
        assertEq(blockscapeETHStakeNFT.isVaultOpen(), true);
    }

    function testDeposit() public {
        _testDepositStakeNFT(1);
    }

    // function testCloseVault() public {
    //     _testInitContractSetup();
    //     _testInitRocketPoolSetup();
    //     // only owner should be able to call function
    //     vm.expectRevert(
    //         "AccessControl: account 0xd3f7f429d80b7cdf98026230c1997b3e8a780dc5 is missing role 0xd543757584911476a8af46cc6d4e1f21c04dfb6c2270b4c853cd66ba1cdf876e"
    //     );
    //     vm.prank(singleStaker);
    //     blockscapeETHStakeNFT.closeVault();
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.closeVault();
    //     assertEq(blockscapeETHStakeNFT.isVaultOpen(), false);
    //     _blockscapeStakeRPL();
    //     // assertEq(blockscapeETHStakeNFT.isVaultOpen(), true);
    //     // only owner should be able to call function
    //     vm.expectRevert(
    //         "AccessControl: account 0xd3f7f429d80b7cdf98026230c1997b3e8a780dc5 is missing role 0xd543757584911476a8af46cc6d4e1f21c04dfb6c2270b4c853cd66ba1cdf876e"
    //     );
    //     vm.prank(singleStaker);
    //     blockscapeETHStakeNFT.closeVault();
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.closeVault();
    //     assertEq(blockscapeETHStakeNFT.isVaultOpen(), false);
    // }

    // function testDepositETHStakeNFT() public {
    //     blockscapeETHStakeNFT.depositStakeNFT();
    // }

    // function testFallbacks() public {
    //     vm.expectRevert();
    //     vm.prank(poolStaker1);
    //     payable(address(blockscapeETHStakeNFT)).transfer(5 ether);
    // }

    // function testWithdraw() public {
    //     _blockscapeStakeRPL();
    //     _openETHStakeNFT();
    //     _depositSoloStaker();
    //     assertEq(blockscapeETHStakeNFT.getBalance(), curETHlimit);
    //     // only owner should be able to call function
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     //vm.prank(singleStaker);
    //     //blockscapeETHStakeNFT.withdraw(curETHlimit);
    //     uint256 deployerBalance = rp_backend.balance;
    //     // vm.prank(rp_backend);
    //     // blockscapeETHStakeNFT.withdraw(curETHlimit);
    //     assertEq(rp_backend.balance - deployerBalance, curETHlimit);
    //     assertEq(blockscapeETHStakeNFT.getBalance(), 0 ether);
    // }

    // function testWithdrawBatch() public {
    //     _stakeRPL();
    //     // nothing deposited yet
    //     vm.expectRevert();
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.withdrawBatch();
    //     assertEq(blockscapeETHStakeNFT.getBalance(), 0 ether);
    //     _depositSoloStaker();
    //     assertEq(blockscapeETHStakeNFT.getBalance(), curETHlimit);
    //     availableRPL = blockscapeETHStakeNFT.getAvailableRPLStake();
    //     // only owner should be able to call function
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     vm.prank(singleStaker);
    //     blockscapeETHStakeNFT.withdrawBatch();
    //     vm.startPrank(rp_backend);
    //     blockscapeETHStakeNFT.withdrawBatch();
    //     assertEq(blockscapeETHStakeNFT.isVaultOpen(), false);
    //     assertEq(blockscapeETHStakeNFT.getBalance(), 0 ether);
    //     blockscapeETHStakeNFT.updateValidator(1, minipoolAddr);
    //     assertEq(blockscapeETHStakeNFT.isVaultOpen(), true);
    //     vm.stopPrank();
    //     // TODO: check that vault can't reopen if not enough RPL are there
    //     // use either depositRocketpool or transfer RPL away from blockscape
    //     // (second option would be an workaround)
    //     _depositToRocketpool();
    //     availableRPL = blockscapeETHStakeNFT.getAvailableRPLStake();
    //     console.log("availableRPL");
    //     console.logUint(availableRPL);

    //     // _warpAfterStakingCooldown();
    //     // _blockscapeUnstakeRPL();
    // }

    // function testUpdateValidator() public {
    //     _blockscapeStakeRPL();
    //     _openETHStakeNFT();
    //     _depositSoloStaker();
    //     bytes memory otherBytesAddr = abi.encodePacked(address(2));
    //     // only owner should be able to call function
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     vm.prank(singleStaker);
    //     blockscapeETHStakeNFT.updateValidator(1, validatorBytesAddress);
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.updateValidator(1, validatorBytesAddress);
    //     (, bytes memory validator) = blockscapeETHStakeNFT.getMetadata(1);
    //     // TODO: Right test cases for other token ids that they return
    //     // default values == they are unset?
    //     // assertEq(staker, singleStaker);
    //     assertEq(validator, validatorBytesAddress);
    //     // can only be set once
    //     vm.expectRevert();
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.updateValidator(1, otherBytesAddr);
    // }

    // function testUserRequestWithdraw() public {
    //     _stakeRPL();
    //     _depositSoloStaker();
    //     uint256 amount = blockscapeETHStakeNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(amount, initWithdrawFee);
    //     vm.startPrank(singleStaker);
    //     amount = blockscapeETHStakeNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(amount, initWithdrawFee);
    //     uint256 origTimestamp = block.timestamp;
    //     uint256 feesDropTimestamp = block.timestamp + 30747600;
    //     vm.warp(origTimestamp + 10 days);
    //     amount = blockscapeETHStakeNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(
    //         amount,
    //         initWithdrawFee - (initWithdrawFee / 365 days) * 10 days
    //     );
    //     vm.warp(origTimestamp + 100 days);
    //     amount = blockscapeETHStakeNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(
    //         amount,
    //         initWithdrawFee - (initWithdrawFee / 365 days) * 100 days
    //     );
    //     vm.warp(feesDropTimestamp);
    //     amount = blockscapeETHStakeNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(amount, 0.5 ether);
    //     vm.warp(feesDropTimestamp + 1000 days);
    //     amount = blockscapeETHStakeNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(amount, 0.5 ether);
    //     vm.stopPrank();
    // }

    // function testChangeETHLimit() public {
    //     uint256 ethLimit = blockscapeETHStakeNFT.getCurrentEthLimit();
    //     assertEq(ethLimit, curETHlimit);
    //     vm.expectRevert(
    //         "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0xd10a1ed6b8db63dab91ea7216f374c2aa39f78fdaf594b4a6da95d2846ad0fa5"
    //     );
    //     blockscapeETHStakeNFT.changeETHLimit8();
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.changeETHLimit8();
    //     ethLimit = blockscapeETHStakeNFT.getCurrentEthLimit();
    //     assertEq(ethLimit, 8 ether);
    // }

    // function testSetWithdrawFee() public {
    //     vm.expectRevert(
    //         "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0xd10a1ed6b8db63dab91ea7216f374c2aa39f78fdaf594b4a6da95d2846ad0fa5"
    //     );
    //     blockscapeETHStakeNFT.lowerWithdrawFee(1 ether);
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.lowerWithdrawFee(1 ether);
    // }

    // function testSetBlockscapeRocketPoolNode() public {
    //     vm.expectRevert(
    //         "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0xd10a1ed6b8db63dab91ea7216f374c2aa39f78fdaf594b4a6da95d2846ad0fa5"
    //     );
    //     blockscapeETHStakeNFT.setBlockscapeRocketPoolNode(address(0x1));
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.setBlockscapeRocketPoolNode(address(0x1));
    // }

    // function testDepositWithdrawalMulti() public {
    //     _stakeRPL();
    //     _depositSoloStaker();
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.withdrawBatch();
    //     // can't deposit before updateValidator function has been run
    //     // and vault is opened
    //     vm.expectRevert();
    //     vm.prank(poolStaker1);
    //     blockscapeETHStakeNFT.depositETHStakeNFT{value: curETHlimit}();
    //     vm.prank(poolStaker1);
    //     blockscapeETHStakeNFT.depositETHStakeNFT{value: curETHlimit}();
    //     // can't deposit before stake has been withdrawn
    //     vm.expectRevert();
    //     vm.prank(poolStaker2);
    //     blockscapeETHStakeNFT.depositETHStakeNFT{value: curETHlimit}();
    //     vm.prank(rp_backend);
    //     blockscapeETHStakeNFT.withdrawBatch();
    //     assertEq(blockscapeETHStakeNFT.isVaultOpen(), false);
    //     assertEq(blockscapeETHStakeNFT.getBalance(), 0 ether);
    //     assertEq(blockscapeETHStakeNFT.isVaultOpen(), true);
    //     vm.prank(poolStaker2);
    //     blockscapeETHStakeNFT.depositETHStakeNFT{value: curETHlimit}();
    //     assertEq(blockscapeETHStakeNFT.getBalance(), curETHlimit);
    //     vm.startPrank(rp_backend);
    //     blockscapeETHStakeNFT.withdrawBatch();
    //     //     console.log(blockscapeETHStakeNFT.getAvailableRPLStake());
    //     //     _warpAfterStakingCooldown();
    //     //     _blockscapeUnstakeRPL();
    //     //     console.log(blockscapeETHStakeNFT.getAvailableRPLStake());
    //     //     console.log(blockscapeETHStakeNFT.getReqRPLStake());
    //     // updateValidator doesn't open vault as not enough RPL are present
    //     assertEq(blockscapeETHStakeNFT.isVaultOpen(), false);
    //     assertEq(blockscapeETHStakeNFT.totalSupply(), 3);
    //     assertEq(blockscapeETHStakeNFT.getTokenID(), 4);
    //     vm.stopPrank();
    // }
}
