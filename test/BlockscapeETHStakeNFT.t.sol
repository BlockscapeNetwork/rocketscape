// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {BlockscapeETHStakeNFT} from "src/BlockscapeETHStakeNFT.sol";
import {HelperContract} from "./utils/BlockscapeETHStakeNFTTestHelper.sol";

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
        _testInitStakeRPLReadyForStaking();

        vm.expectRevert();
        vm.prank(poolStaker1);
        blockscapeETHStakeNFT.depositStakeNFT();

        _testHasNodeEnoughRPLStake();

        vm.prank(poolStaker1);
        blockscapeETHStakeNFT.depositStakeNFT{value: 1 ether}();

        vm.prank(poolStaker2);
        blockscapeETHStakeNFT.depositStakeNFT{value: 4 ether}();

        vm.prank(poolStaker3);
        blockscapeETHStakeNFT.depositStakeNFT{value: 4 ether}();

        vm.prank(poolStaker4);
        blockscapeETHStakeNFT.depositStakeNFT{value: 7 ether}();

        vm.prank(poolStaker2);
        blockscapeETHStakeNFT.depositStakeNFT{value: 1.5 ether}();

        assertEq(blockscapeETHStakeNFT.isVaultOpen(), true);

        assertEq(blockscapeETHStakeNFT.getTokenID(), 6);
        assertEq(blockscapeETHStakeNFT.totalSupply(), 5);

        // check metadata
        BlockscapeETHStakeNFT.Metadata memory m = blockscapeETHStakeNFT
            .getMetadata(1);

        BlockscapeETHStakeNFT.Metadata memory shouldBeM;
        shouldBeM.stakedETH = 1 ether;
        shouldBeM.stakedTimestamp = block.timestamp;
        assertEq(
            blockscapeETHStakeNFT.contractURI(),
            "https://ipfs.blockscape.network/ipfs/TBD"
        );
        assertEq(
            blockscapeETHStakeNFT.uri(1),
            "https://ipfs.blockscape.network/ipns/TBD/1.json"
        );

        assertEq(m.stakedETH, shouldBeM.stakedETH);
        assertEq(m.stakedTimestamp, shouldBeM.stakedTimestamp);

        // only current tokenID has been changed
        m = blockscapeETHStakeNFT.getMetadata(0);
        assertEq(m.stakedETH, 0);
        assertEq(m.stakedTimestamp, 0);
        m = blockscapeETHStakeNFT.getMetadata(2);
        assertEq(m.stakedETH, 4 ether);
        assertEq(m.stakedTimestamp, shouldBeM.stakedTimestamp);
    }

    function testUpdatingStaking() public {
        _testUpdateStake(1);
    }

    function testWithdraw() public {
        // _testInitStakeRPLReadyForStaking();
        // vm.prank(singleStaker);
        // blockscapeETHStakeNFT.depositStakeNFT{value: 4 ether}();
        // // assertEq(blockscapeETHStakeNFT.balanceOf(singleStaker, 1), 1);
        // // assertEq(blockscapeETHStakeNFT.getPoolSupply(), 4 ether);

        // _testPrepareWithdrawProcess(1);

        // _testReceive();

        // // _testWithdrawFunds(1);

        // assertEq(blockscapeETHStakeNFT.balanceOf(singleStaker, 1), 1);

        // vm.expectRevert();
        // _testWithdrawFunds(2);

        _complete();
    }


    function testMiscellaneous() public {
        _testInitStakeRPLReadyForStaking();
        _testGetAvailableRPLStake();
        _testGetReqRPLStake();
        _testHasNodeEnoughRPLStake();

        _testUri();
        _testContractURI();
        _testCalcApr();

        _testCloseVault();
        _testOpenVault();
        _textIsVaultOpen();
        //_testReceive();
        payable(blockscapeETHStakeNFT).transfer(20 ether);
        _textLowerWithdrawFee(5e18);

        vm.expectRevert();
        _textLowerWithdrawFee(21e18);
    }
}
