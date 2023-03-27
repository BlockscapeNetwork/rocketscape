// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.16;

import "forge-std/Test.sol";

import {console} from "forge-std/console.sol";

import {BlockscapeValidatorNFT} from "src_2_audit_fixes/BlockscapeValidatorNFT.sol";
import {BlockscapeValidatorNFTTestHelper} from "./utils/BlockscapeValidatorNFTTestHelper.sol";

contract BlockscapeValidatorNFTTest is Test, BlockscapeValidatorNFTTestHelper {
    // uint256 initWithdrawFee = 20 ether;

    bytes validatorBytesAddress =
        hex"a2e78385831894094502727373588fc1794ea2800b2b6e614358fea78dcf0cc4d103008a53c665f294e31af0397253e3";

    address minipoolAddr = 0x626CA3f82a4A11C2226101eeEA35Fcc25a5fE91D;

    error NotEnoughRPLStake();

    constructor() BlockscapeValidatorNFTTestHelper(blockscapeValidatorNFT) {}

    function setUp() public {
        _setupParticipants();

        _testInitContractSetup();
    }

    function testAccess() public {
        _testAccessControl();
    }

    function testVault() public {
        _testClosingVault();

        // _blockscapeStakeRPL();

        // _testOpeningVault();
    }

    // function testStaking() public {
    //     _testSetMetadata();
    // }

    //     _blockscapeStakeRPL();

    //     _testContractSetupAfterRPLStaking();

    //     // only RP_BACKEND_ROLE should be able to call function
    //     vm.expectRevert(
    //         "AccessControl: account 0xd3f7f429d80b7cdf98026230c1997b3e8a780dc5 is missing role 0xbf233dd2aafeb4d50879c4aa5c81e96d92f6e6945c906a58f9f2d1c1631b4b26"
    //     );
    //     vm.prank(singleStaker);
    //     blockscapeValidatorNFT.closeVault();

    //     assertEq(blockscapeValidatorNFT.isVaultOpen(), true);
    // }

    // function testDepositValidatorNFT() public {
    //     _blockscapeStakeRPL();

    //     assertEq(blockscapeValidatorNFT.totalSupply(), 0);

    //     // expect incorrect values of ether to revert
    //     vm.expectRevert();
    //     vm.prank(poolStaker1);
    //     blockscapeValidatorNFT.depositValidatorNFT();

    // _stakeRPL();

    //     vm.expectRevert();
    //     vm.prank(poolStaker1);
    //     blockscapeValidatorNFT.depositValidatorNFT{
    //         value: curETHlimit + 1 ether
    //     }();

    //     _depositSoloStaker();

    //     BlockscapeStaking.Metadata memory shouldBeM;
    //     shouldBeM.stakedETH = curETHlimit;
    //     shouldBeM.stakedTimestamp = block.timestamp;

    // function testDepositValidatorNFT() public {
    //     _stakeRPL();

    //     // TODO: Right test cases for other token ids that they return
    //     // default values == they are unset?

    //     assertEq(m.stakedETH, shouldBeM.stakedETH);
    //     assertEq(m.stakedTimestamp, shouldBeM.stakedTimestamp);
    //     // assertEq(staker, singleStaker);
    //     // assertEq(validator, address(0));

    //     assertEq(blockscapeValidatorNFT.isVaultOpen(), false);

    //     assertEq(blockscapeValidatorNFT.totalSupply(), 1);
    //     assertEq(blockscapeValidatorNFT.getTokenID(), 2);
    //     assertEq(
    //         blockscapeValidatorNFT.contractURI(),
    //         "https://ipfs.blockscape.network/ipfs/QmUr8P96kNuFjcZb2WBjBP4e1fiGGXwRGChfTi42pnujY7"
    //     );
    //     assertEq(
    //         blockscapeValidatorNFT.uri(1),
    //         "https://ipfs.blockscape.network/ipns/k51qzi5uqu5di5eo5fzr1zypdsz0zct39zpct9s4wesjustul1caeofak3zoej/1.json"
    //     );

    //     // vault is closed
    //     vm.expectRevert();
    //     vm.prank(poolStaker1);
    //     blockscapeValidatorNFT.depositValidatorNFT{value: curETHlimit}();
    // }

    // function testFallbacks() public {
    //     vm.expectRevert();
    //     vm.prank(poolStaker1);
    //     payable(address(blockscapeValidatorNFT)).transfer(5 ether);
    // }

    // function testWithdraw() public {
    //     _blockscapeStakeRPL();
    //     _openValidatorNFT();
    //     _depositSoloStaker();

    //     assertEq(blockscapeValidatorNFT.getBalance(), curETHlimit);

    //     // only owner should be able to call function
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     //vm.prank(singleStaker);
    //     //blockscapeValidatorNFT.withdraw(curETHlimit);

    //     uint256 deployerBalance = rp_backend.balance;

    //     // vm.prank(rp_backend);
    //     // blockscapeValidatorNFT.withdraw(curETHlimit);

    //     assertEq(rp_backend.balance - deployerBalance, curETHlimit);
    //     assertEq(blockscapeValidatorNFT.getBalance(), 0 ether);
    // }

    // function testWithdrawBatch() public {
    //     _stakeRPL();

    //     // nothing deposited yet
    //     vm.expectRevert();
    //     vm.prank(rp_backend);
    //     blockscapeValidatorNFT.withdrawBatch();

    //     assertEq(blockscapeValidatorNFT.getBalance(), 0 ether);

    //     _depositSoloStaker();

    //     assertEq(blockscapeValidatorNFT.getBalance(), curETHlimit);

    //     availableRPL = blockscapeValidatorNFT.getAvailableRPLStake();

    //     // only owner should be able to call function
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     vm.prank(singleStaker);
    //     blockscapeValidatorNFT.withdrawBatch();

    //     vm.startPrank(rp_backend);
    //     blockscapeValidatorNFT.withdrawBatch();

    //     assertEq(blockscapeValidatorNFT.isVaultOpen(), false);
    //     assertEq(blockscapeValidatorNFT.getBalance(), 0 ether);

    //     blockscapeValidatorNFT.updateValidator(1, minipoolAddr);
    //     assertEq(blockscapeValidatorNFT.isVaultOpen(), true);

    //     vm.stopPrank();

    // TODO: check that vault can't reopen if not enough RPL are there
    // use either depositRocketpool or transfer RPL away from blockscape
    // (second option would be an workaround)
    // _depositToRocketpool();

    // availableRPL = blockscapeValidatorNFT.getAvailableRPLStake();
    // console.log("availableRPL");
    // console.logUint(availableRPL);
    // }

    //     // _warpAfterStakingCooldown();
    //     // _blockscapeUnstakeRPL();
    // }

    // function testUpdateValidator() public {
    //     _blockscapeStakeRPL();
    //     _openValidatorNFT();
    //     _depositSoloStaker();

    //     bytes memory otherBytesAddr = abi.encodePacked(address(2));

    //     // only owner should be able to call function
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     vm.prank(singleStaker);
    //     blockscapeValidatorNFT.updateValidator(1, validatorBytesAddress);

    //     vm.prank(rp_backend);
    //     blockscapeValidatorNFT.updateValidator(1, validatorBytesAddress);

    //     (, bytes memory validator) = blockscapeValidatorNFT
    //         .getMetadata(1);

    //     // TODO: Right test cases for other token ids that they return
    //     // default values == they are unset?

    //    // assertEq(staker, singleStaker);
    //     assertEq(validator, validatorBytesAddress);

    //     // can only be set once
    //     vm.expectRevert();
    //     vm.prank(rp_backend);
    //     blockscapeValidatorNFT.updateValidator(1, otherBytesAddr);
    // }

    // function testUserRequestWithdraw() public {
    //     _stakeRPL();
    //     _depositSoloStaker();

    //     uint256 amount = blockscapeValidatorNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(amount, initWithdrawFee);

    //     vm.startPrank(singleStaker);
    //     amount = blockscapeValidatorNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(amount, initWithdrawFee);

    //     uint256 origTimestamp = block.timestamp;
    //     uint256 feesDropTimestamp = block.timestamp + 30747600;

    //     vm.warp(origTimestamp + 10 days);
    //     amount = blockscapeValidatorNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(
    //         amount,
    //         initWithdrawFee - (initWithdrawFee / 365 days) * 10 days
    //     );

    //     vm.warp(origTimestamp + 100 days);
    //     amount = blockscapeValidatorNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(
    //         amount,
    //         initWithdrawFee - (initWithdrawFee / 365 days) * 100 days
    //     );

    //     vm.warp(feesDropTimestamp);
    //     amount = blockscapeValidatorNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(amount, 0.5 ether);

    //     vm.warp(feesDropTimestamp + 1000 days);
    //     amount = blockscapeValidatorNFT.calcWithdrawFee(1, msg.sender);
    //     assertEq(amount, 0.5 ether);

    //     vm.stopPrank();
    // }

    // function testChangeETHLimit() public {
    //     uint256 ethLimit = blockscapeValidatorNFT.getCurrentEthLimit();
    //     assertEq(ethLimit, curETHlimit);

    //     vm.expectRevert(
    //         "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0xd10a1ed6b8db63dab91ea7216f374c2aa39f78fdaf594b4a6da95d2846ad0fa5"
    //     );
    //     blockscapeValidatorNFT.changeETHLimit8();

    //     vm.prank(rp_backend);
    //     blockscapeValidatorNFT.changeETHLimit8();

    //     ethLimit = blockscapeValidatorNFT.getCurrentEthLimit();
    //     assertEq(ethLimit, 8 ether);
    // }

    // function testSetWithdrawFee() public {
    //     vm.expectRevert(
    //         "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0xd10a1ed6b8db63dab91ea7216f374c2aa39f78fdaf594b4a6da95d2846ad0fa5"
    //     );
    //     blockscapeValidatorNFT.lowerWithdrawFee(1 ether);

    //     vm.prank(rp_backend);
    //     blockscapeValidatorNFT.lowerWithdrawFee(1 ether);
    // }

    // function testSetBlockscapeRocketPoolNode() public {
    //     vm.expectRevert(
    //         "AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0xd10a1ed6b8db63dab91ea7216f374c2aa39f78fdaf594b4a6da95d2846ad0fa5"
    //     );
    //     blockscapeValidatorNFT.setBlockscapeRocketPoolNode(address(0x1));

    //     vm.prank(rp_backend);
    //     blockscapeValidatorNFT.setBlockscapeRocketPoolNode(address(0x1));
    // }

    // function testDepositWithdrawalMulti() public {
    //     _stakeRPL();
    //     _depositSoloStaker();

    //     vm.prank(rp_backend);
    //     blockscapeValidatorNFT.withdrawBatch();

    //     // can't deposit before updateValidator function has been run
    //     // and vault is opened
    //     vm.expectRevert();
    //     vm.prank(poolStaker1);
    //     blockscapeValidatorNFT.depositValidatorNFT{value: curETHlimit}();

    //     vm.prank(poolStaker1);
    //     blockscapeValidatorNFT.depositValidatorNFT{value: curETHlimit}();

    //     // can't deposit before stake has been withdrawn
    //     vm.expectRevert();
    //     vm.prank(poolStaker2);
    //     blockscapeValidatorNFT.depositValidatorNFT{value: curETHlimit}();

    //     vm.prank(rp_backend);
    //     blockscapeValidatorNFT.withdrawBatch();

    //     assertEq(blockscapeValidatorNFT.isVaultOpen(), false);
    //     assertEq(blockscapeValidatorNFT.getBalance(), 0 ether);

    //     assertEq(blockscapeValidatorNFT.isVaultOpen(), true);

    //     vm.prank(poolStaker2);
    //     blockscapeValidatorNFT.depositValidatorNFT{value: curETHlimit}();

    //     assertEq(blockscapeValidatorNFT.getBalance(), curETHlimit);

    //     vm.startPrank(rp_backend);
    //     blockscapeValidatorNFT.withdrawBatch();

    //     //     console.log(blockscapeValidatorNFT.getAvailableRPLStake());
    //     //     _warpAfterStakingCooldown();
    //     //     _blockscapeUnstakeRPL();
    //     //     console.log(blockscapeValidatorNFT.getAvailableRPLStake());
    //     //     console.log(blockscapeValidatorNFT.getReqRPLStake());

    //     // updateValidator doesn't open vault as not enough RPL are present
    //     assertEq(blockscapeValidatorNFT.isVaultOpen(), false);

    //     assertEq(blockscapeValidatorNFT.totalSupply(), 3);
    //     assertEq(blockscapeValidatorNFT.getTokenID(), 4);

    //     vm.stopPrank();
    // }
}
// }
