pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/utils/Strings.sol";

import "./utils/BlockscapeStaking.sol";
import "./utils/BlockscapeVault.sol";

/// @dev you first need to depositStakeNFT before you can updateStake
error YouDontOwnThisNft(uint256 tokenID);

/** 
    @title Rocketpool Staking Allocation Contract
    @author Blockscape Finance AG <info@blockscape.network>
    @notice collects staking, mints NFT in return for stake, which can be any amount of ETH
*/
contract BlockscapeETHStakeNFT is
    ERC1155Supply,
    ReentrancyGuard,
    BlockscapeVault,
    BlockscapeStaking
{
    /// @notice Current ETH pool supply
    uint256 poolSupply;

    /** 
        @notice initial tokenID
        @dev the tokenID is used to identify the ETh Stake NFTs
    */
    uint256 tokenID = 1;

    /// @dev event for when the NFT stake is updated
    event StakeUpdated(uint256 _tokenID, address _owner, uint256 _newStake);

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
        BlockscapeStaking()
    {}

    /**
     * @dev needed as the OZ ERC1155 && AccessControl does both implement the supportsInterface function
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // functions

    // public & external functions

    /**
        @notice withdraw the given amount to the backend, triggered when the account balance is above 16 ETH or 8 ETH (RPIP-8)
        @dev the withdraw function remains public as safety measurement to
        not lock-in client stakes in case of contract issues
        param _amount the amount in wei to withdraw
        // TODO: does it use _amount?
     */
    function withdrawForMinipool() external onlyRole(RP_BACKEND_ROLE) {
        if (BlockscapeVault.vaultOpen)
            revert ErrorVaultState(BlockscapeVault.vaultOpen);
        Address.sendValue(blockscapeRocketPoolNode, 8 ether);
    }

    function internalWithdrawForMinipools() internal {
        Address.sendValue(blockscapeRocketPoolNode, address(this).balance);
    }

    /// @notice used when staking eth into the contract
    /// @dev the vault must be open and equal the depositing amount
    function depositStakeNFT() external payable {
        if (!hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        if (!vaultOpen) revert ErrorVaultState(vaultOpen);

        if (msg.value == 0) revert();

        // create metadata for the new tokenID
        _metadataStakeNFTInternal(msg.value, tokenID);

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
            BlockscapeStaking.tokenIDtoMetadata[_tokenID].stakedETH += msg
                .value;

            poolSupply += msg.value;

            // emit event
            emit StakeUpdated(
                _tokenID,
                msg.sender,
                BlockscapeStaking.tokenIDtoMetadata[_tokenID].stakedETH
            );
        } else {
            revert YouDontOwnThisNft(_tokenID);
        }
    }

    /**
        @notice used when user wants to unstake
        @param _tokenID which validator NFT the staker wants to unstake; the backend will listen on the event and will unstake the validator. The ETH value with rewards is transparantly available via beacon chain explorers and will be reduced by the withdraw fee, which is fixed to 0.5% after one year.
     */
    function prepareWithdrawProcess(uint256 _tokenID) external {
        if (senderToTimestamp[msg.sender] <= 0) revert();

        uint256 curWithdrawFee = calcWithdrawFee(_tokenID, msg.sender);

        if (balanceOf(msg.sender, _tokenID) >= 1) {
            senderToTimestamp[msg.sender] = block.timestamp;
            emit BlockscapeStaking.UserRequestedWithdrawal(
                _tokenID,
                msg.sender,
                curWithdrawFee,
                BlockscapeStaking.tokenIDtoMetadata[_tokenID].stakedETH,
                estRewardsNoMEV(_tokenID) // TODO: here is another function needed to get the correct rewards on-chain
            );
        }
    }

    /**
     *  @dev the rewards are calculated by the backend controller and are then stored in the contract, this is needed to be able to calculate the rewards correctly including MEV rewards. There off-chain calculated rewards cannot be lower than the on-chain esimated rewards.
     */
    function withdrawFunds(uint256 _tokenID) external {
        if (senderToTimestamp[msg.sender] + 7 days < block.timestamp) revert();
        if (
            BlockscapeStaking.tokenIDToExitReward[_tokenID] <
            estRewardsNoMEV(_tokenID)
        ) {
            BlockscapeStaking.tokenIDToExitReward[_tokenID] = estRewardsNoMEV(
                _tokenID
            );
        }

        safeTransferFrom(msg.sender, blockscapeRocketPoolNode, _tokenID, 1, "");

        Address.sendValue(
            payable(msg.sender),
            BlockscapeStaking.tokenIDtoMetadata[_tokenID].stakedETH +
                BlockscapeStaking.tokenIDToExitReward[_tokenID]
        );
    }

    // functions for future maintainability

    /**
        @notice the withdraw fee might be changed in the future
        @param _amount the new fee in wei
     */
    function lowerWithdrawFee(
        uint256 _amount
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        if (_amount >= 20 * 1e18) revert();
        BlockscapeStaking.initWithdrawFee = _amount;
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
        // TODO: dispite the same name, we might need to change the func (&name, like calcWithdrawFeePool ) for the pool staking to be abple to calc the ETh rewards complety only on-chain... TBD
        uint256 _tokenID,
        address _user
    ) public view returns (uint256 _amount) {
        uint256 curWithdrawFee = BlockscapeStaking.initWithdrawFee;

        if (balanceOf(_user, _tokenID) >= 1) {
            uint256 secFee = (BlockscapeStaking.initWithdrawFee / 365 days); // 20%
            uint256 timePassed = block.timestamp -
                (BlockscapeStaking.tokenIDtoMetadata[_tokenID].stakedTimestamp);

            uint256 maxTime05EthReached = 30747600;
            if (timePassed >= maxTime05EthReached) {
                curWithdrawFee = 5 * 1e17; // fixed minimum fee 0,5 %
            } else {
                curWithdrawFee = (BlockscapeStaking.initWithdrawFee -
                    (secFee * timePassed));
            }
        } else {
            curWithdrawFee = 0;
        }
        return curWithdrawFee;
    }

    /**
        @notice this function is a on-chain calculation of the rocketpool ETH rewards. It does not take MEV into account & will only work correctly after the Shapella/Shanghai upgrade
        @param _tokenID tokenID of the NFT, the user wants to unstake
        @return rewards in wei
        // TODO: Implement or abstract me
     */
    function estRewardsNoMEV(uint256 _tokenID) internal view returns (uint256) {
        uint256 wfee = calcWithdrawFee(_tokenID, msg.sender) * 0;
        return (0 - wfee);
    }

    /**
        @notice the tokenID is incremented with every pool
        @return the current tokenID 
     */
    function getTokenID() public view returns (uint256) {
        return tokenID;
    }

    /**
        @notice how much balance does this vault current have
        @return amount in wei
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
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

    // internal functions

    /**
        @notice creates and mints metadata for a given NFT tokenID
        @param _stakedETH staked amount from the sender
        @param _tokenID Identifier of the vault
    */
    function _metadataStakeNFTInternal(
        uint256 _stakedETH,
        uint256 _tokenID
    ) internal {
        BlockscapeStaking.Metadata memory metadata;

        metadata.stakedETH = _stakedETH;
        metadata.stakedTimestamp = block.timestamp;

        BlockscapeStaking.tokenIDtoMetadata[_tokenID] = metadata;

        _mint(msg.sender, _tokenID, 1, "");
    }

    /**
     * @return name of the ERC-1155 token
     */
    function name() public pure returns (string memory) {
        return "Blockscape ETH Stake NFTs";
    }

    /**
     * @return symbol of the ERC-1155 token
     */
    function symbol() public pure returns (string memory) {
        return "BSS";
    }
}
