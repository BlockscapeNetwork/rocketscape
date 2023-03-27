// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/utils/Strings.sol";
import {UD60x18, sqrt, exp, ud, mul, div, intoUint256} from "@prb/math/UD60x18.sol";

import "./utils/BlockscapeAccess.sol";
import "./utils/BlockscapeShared.sol";

/** 
    @title Rocketpool Staking Allocation Contract
    @author Blockscape Finance AG <info@blockscape.network>
    @notice collects staking, mints NFT in return for stake, which can be any amount of ETH
*/
contract BlockscapeETHStakeNFT is
    ERC1155Supply,
    ReentrancyGuard,
    BlockscapeAccess,
    BlockscapeShared
{
    /// @notice tracks the ETH pool supply
    uint256 poolSupply;

    /// @notice constant used for blockexplorers to display the name of the token
    string public constant name = "Blockscape ETH Stake NFTs";

    /// @notice constant used for blockexplorers to display the symbol of the token
    string public constant symbol = "BSS";

    /** 
        @notice each pool related vault gets its separate tokenID which depicts 
        the nft for each staker
        @dev the IPNS makes sure the nfts stay reachable via this link while 
        new nfts get added to the underlying ipfs folder
     */
    constructor()
        ERC1155(
            "https://ipfs.blockscape.network/ipns/"
            "TBD/"
            "{id}.json"
        )
        BlockscapeAccess(
            msg.sender,
            BlockscapeShared.blockscapeRocketPoolNode,
            msg.sender
        )
    {}

    /**
     * @dev needed as the OZ ERC1155 && AccessControl does both implement the supportsInterface function
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    //TODO: maybe not needed
    // /**
    //     @notice withdraw the given amount to the backend, externaly triggered when the smart contract balance is eqal or above 8 ETH
    //  */
    // function withdrawForMinipool() external onlyRole(RP_BACKEND_ROLE) {
    //     if (vaultOpen)
    //         revert ErrorVaultState(vaultOpen);
    //     Address.sendValue(blockscapeRocketPoolNode, 8 ether);
    // }

    
    /// @notice used when staking eth into the contract
    /// @dev the vault must be open and equal the depositing amount

    /**
     * @notice used when staking eth into the contract
     * @dev the vault must be open and equal the depositing amount
     * @dev the staker must have enough RPL staked in the Rocketpool
     * 
     */
    function depositStakeNFT() external payable {
        if (!hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        if (!vaultOpen) revert ErrorVaultState(vaultOpen);

        if (msg.value == 0) revert();

        // create metadata for the new tokenID
        _setMetadataForStakeInternal(msg.value, tokenID);
        _mint(msg.sender, tokenID, 1, "");

        tokenID++;
        poolSupply += msg.value;

        if (address(this).balance >= 8 ether) {
            Address.sendValue(blockscapeRocketPoolNode, address(this).balance);
        }
    }

    /**
        @notice update the stake of the given tokenID, if the NFT owner decides to stake more ETH
        @dev emits the StakeUpdated event & increases the poolSupply based on the msg.value
        @param _tokenID Identifier of the vault
    */
    function updateStake(uint256 _tokenID) external payable nonReentrant {
        if (balanceOf(msg.sender, _tokenID) >= 1) {
            if (msg.value == 0) revert();

            // update ETH value of the tokenID by adding the msg.value
            tokenIDtoMetadata[_tokenID].stakedETH += msg.value;

            poolSupply += msg.value;

            // emit event
            emit StakeUpdated(
                _tokenID,
                msg.sender,
                tokenIDtoMetadata[_tokenID].stakedETH
            );
        } else {
            revert YouDontOwnThisNft(_tokenID);
        }
    }

    /**
        @notice used when user wants to u nstake
        @param _tokenID which validator NFT the staker wants to unstake; the backend will listen on the event and will unstake the validator. The ETH value with rewards is transparantly available via beacon chain explorers and will be reduced by the withdraw fee, which is fixed to 0.5% after one year.
     */
    function prepareWithdrawalProcess(uint256 _tokenID) external override {
        if (senderToTimestamp[msg.sender] <= 0) revert();

        tokenIDToExitReward[_tokenID] = calcRewards(_tokenID);

        if (balanceOf(msg.sender, _tokenID) >= 1) {
            senderToTimestamp[msg.sender] = block.timestamp;
            emit UserRequestedWithdrawalStake(
                _tokenID,
                msg.sender,
                tokenIDtoMetadata[_tokenID].stakedETH,
                calcRewards(_tokenID)
            );
        }
    }

    /**
     *  @dev the rewards are calculated by the backend controller and are then stored in the contract, this is needed to be able to calculate the rewards correctly including MEV rewards. There off-chain calculated rewards cannot be lower than the on-chain esimated rewards.
     */
    function withdrawFunds(uint256 _tokenID) external override {
        if (senderToTimestamp[msg.sender] + timelockWithdraw < block.timestamp)
            revert();

        safeTransferFrom(msg.sender, blockscapeRocketPoolNode, _tokenID, 1, "");

        Address.sendValue(
            payable(msg.sender),
            tokenIDtoMetadata[_tokenID].stakedETH +
                tokenIDToExitReward[_tokenID]
        );
    }

    // view / pure functions

    /**
     * @notice returns the current ETH supply of the pool(s)
     *
     */
    function getPoolSupply() public view returns (uint256) {
        return poolSupply;
    }

    /**
        @notice how much fees would the user has to pay if he would unstake now
        within the first year of staking the fee is starting at 20% & decreasing linearly, afterwards 0.5%
        @param _tokenID which pool the staker wants to unstake
        @return _amount how much the user would pay on fees
     */
    function calcWithdrawFee(
        uint256 _tokenID,
        address _user
    ) public view override returns (uint256 _amount) {
        uint256 curWithdrawFee = initWithdrawFee;

        if (balanceOf(_user, _tokenID) >= 1) {
            uint256 secFee = (initWithdrawFee / 365 days); // 20%
            uint256 timePassed = block.timestamp -
                (tokenIDtoMetadata[_tokenID].stakedTimestamp);

            uint256 maxTime05EthReached = 30747600;
            if (timePassed >= maxTime05EthReached) {
                curWithdrawFee = 5 * 1e17; // fixed minimum fee 0,5 %
            } else {
                curWithdrawFee = (initWithdrawFee - (secFee * timePassed));
            }
        } else {
            curWithdrawFee = 0;
        }
        return curWithdrawFee;
    }

    /**
        @notice this function is a on-chain calculation of the rocketpool ETH rewards. It does not take MEV into account & will only work correctly after the Shapella/Shanghai upgrade
        @return rewards in wei
        // TODO: Implement or abstract me -> DONE 
     */
    function calcApr() public view returns (uint256) {
        // deposit contract ETH balance
        UD60x18 balanceStaked = ud(
            address(0x00000000219ab540356cBB839Cbe05303d7705Fa).balance
        );

        // exp(((31556926 / 384) * 64) / 31622 / sqrt(balanceStaked)) - 1) * 100 - 0.5
        // 31556926 = seconds per year
        // 384 = seconds per epoch
        // 31556926 / 384 = epochs per year
        // 64 = BASE_REWARD_FACTOR
        // 31622 = sqrt(gwei per ETH)
        // 166.32368815e18 = ((31556926 / 384) * 64) / 31622
        uint256 baseAPR = (intoUint256(
            exp(div(ud(166.32368815e18), sqrt(balanceStaked)))
        ) - 1e18) *
            100 -
            5e17;
        uint256 ethreturn = (baseAPR * 16) / 100;

        uint256 mevreturn = 0.23e18; // estimated MEV return
        uint256 feereturn = 0.23e18; // estimated fee return
        uint256 commission = (15 * ethreturn) / 100; // rp commission

        uint256 totalETHReturn = ethreturn + mevreturn + feereturn + commission;

        return (totalETHReturn / 16) * 100;
    }

    function calcRewards(uint256 _tokenID) internal view returns (uint256) {
        uint256 secRewards = calcApr() / 365 days;
        uint256 secStaked = block.timestamp -
            tokenIDtoMetadata[_tokenID].stakedTimestamp;
        uint256 rewards = tokenIDtoMetadata[_tokenID].stakedETH *
            secRewards *
            secStaked;
        uint256 wFee = rewards * calcWithdrawFee(_tokenID, msg.sender);
        return (rewards - wFee);
    }

    /// @notice how many staker are there totally
    /// @return total amount of staker
    function totalSupply() external view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = 1; i <= this.getTokenID(); i++) {
            amount += this.totalSupply(i);
        }
        return amount;
    }

    /** 
        @notice stake nft metdata location
        @dev this path will never change as the contract defines a collection
        @return the fixed collection metadata path 
     */
    function contractURI() external pure returns (string memory) {
        return "https://ipfs.blockscape.network/ipfs/TBD";
    }

    /**
        @notice gets the url to the metadata of a given pool
        @param _tokenID the pool
        @return the url
     */
    function uri(
        uint256 _tokenID
    ) public pure override returns (string memory) {
        return
            string.concat(
                "https://ipfs.blockscape.network/ipns/TBD/",
                Strings.toString(_tokenID),
                ".json"
            );
    }
}
