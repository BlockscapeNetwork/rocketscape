pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

library Calculations {
    /**
        @notice this function is a on-chain calculation of the rocketpool ETH rewards. It does not take MEV into account & will only work correctly after the Shapella upgrade
        @param _tokenID tokenID of the NFT, the user wants to unstake
        @return rewards in wei
     */
    // function estRewardsNoMEV(uint256 _tokenID) internal view returns (uint256) {
    //     uint256 balance;
    //     uint256 balanceComm;
    //     if (curETHlimit >= 16 ether) {
    //         balance = (address(tokenIDtoValidator[_tokenID]).balance / 2);
    //         balanceComm = (15 * balance) / 100;
    //     } else {
    //         balance = (address(tokenIDtoValidator[_tokenID]).balance / 4);
    //         balanceComm = (rpComm8 * (balance * 3)) / 100;
    //     }
    //     uint256 wfee = calcWithdrawFee(_tokenID, msg.sender) * balanceComm;
    //     return (balance + balanceComm - wfee);
    // }
}
