// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/utils/Strings.sol";

import "./utils/BlockscapeAccess.sol";
import "./utils/BlockscapeShared.sol";

error ValidatorAlreadySet(address _vali);

/** 
    @title Rocketpool Staking Allocation Contract
    @author Blockscape Finance AG <info@blockscape.network>
    @notice collects staking, mints NFT in return for staker and let's backend controller 
    transfer the stake when the pool is full (currently 16 ETH) and enough RPL are available
*/

contract BlockscapeValidatorNFT is
    ERC1155Supply,
    ReentrancyGuard,
    BlockscapeAccess,
    BlockscapeShared
{
    /// @notice name constant used for blockexplorers
    string public constant name = "Blockscape Validator NFTs";

    /// @notice symbol constant used for blockexplorers
    string public constant symbol = "BSV";

    /// @notice Current Rocketpool Minipool Limit
    uint256 public curETHlimit = 16 ether;

    /// @dev Mappings of tokenID to Validator public key
    mapping(uint256 => address) public tokenIDtoValidator;

    /** 
        @notice each validator related vault gets its separate tokenID which depicts 
        the nft for each staker
        @dev the IPNS makes sure the nfts stay reachable via this link while 
        new nfts get added to the underlying ipfs folder
     */
    constructor()
        ERC1155(
            "https://ipfs.blockscape.network/ipns/"
            "k51qzi5uqu5di5eo5fzr1zypdsz0zct39zpct9s4wesjustul1caeofak3zoej/"
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

    // functions
    // public & external functions

    /// @notice used when staking eth into the contract
    /// @dev the vault must be open and equal the depositing amount
    function depositValidatorNFT() external payable {
        if (!hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        // TODO: Bring back?
        // if (tokenIDtoValidator[tokenID] == address(0)) revert();

        if (!isVaultOpen()) revert ErrorVaultState(isVaultOpen());

        if (curETHlimit != msg.value) revert IncorrectDepositValueSent();

        // create metadata for the new tokenID
        _setMetadataForStakeInternal(msg.value, tokenID);

        _mint(msg.sender, tokenID, 1, "");

        tokenID++;

        // close the vault
        _closeVaultInternal();
    }

    /**
        @notice this gets triggered by the backend controller when a new token is minted
     */
    function withdrawBatch() external onlyRole(RP_BACKEND_ROLE) {
        if (vaultOpen) revert ErrorVaultState(vaultOpen);
        Address.sendValue(blockscapeRocketPoolNode, curETHlimit);
    }

    /**
        @notice update validator address for given token id only once after the NFT has been issued and the validator was created by the backend, this function will only be called by the backend
        @dev works only once for a tokenID; it will reopen the vault 
        @param _tokenID Identifier of the NFT
        @param _vali the current address of the validator
    */
    function updateValidator(
        uint256 _tokenID,
        address _vali
    ) external onlyRole(RP_BACKEND_ROLE) {
        if (address(0) != tokenIDtoValidator[_tokenID]) {
            revert ValidatorAlreadySet(tokenIDtoValidator[_tokenID]);
        }
        if (vaultOpen == true) revert ErrorVaultState(vaultOpen);

        tokenIDtoValidator[_tokenID] = _vali;

        _openVaultInternal();
    }

    /**
        @notice used when user wants to unstake
        @param _tokenID which validator NFT the staker wants to unstake; the backend will listen on the event and will unstake the validator. The ETH value with rewards is transparantly available via beacon chain explorers and will be reduced by the withdraw fee, which is fixed to 0.5% after one year.
     */
    function prepareWithdrawProcess(uint256 _tokenID) external override {
        if (senderToTimestamp[msg.sender] != 0)
            revert AlreadyPreparingForWithdrawal();

        uint256 curWithdrawFee = calcWithdrawFee(_tokenID, msg.sender);

        if (balanceOf(msg.sender, _tokenID) >= 1) {
            senderToTimestamp[msg.sender] = block.timestamp;
            emit UserRequestedWithdrawalVali(
                _tokenID,
                msg.sender,
                curWithdrawFee,
                tokenIDtoMetadata[_tokenID].stakedETH,
                estRewardsNoMEV(_tokenID)
            );
        }
    }

    /**
     *  @dev the rewards are calculated by the backend controller and are then stored in the contract, this is needed to be able to calculate the rewards correctly including MEV rewards. There off-chain calculated rewards cannot be lower than the on-chain esimated rewards.
     */
    function withdrawFunds(uint256 _tokenID) external override {
        if (senderToTimestamp[msg.sender] + timelockWithdraw < block.timestamp)
            revert();
        if (tokenIDToExitReward[_tokenID] < estRewardsNoMEV(_tokenID)) {
            tokenIDToExitReward[_tokenID] = estRewardsNoMEV(_tokenID);
        }

        safeTransferFrom(msg.sender, blockscapeRocketPoolNode, _tokenID, 1, "");

        Address.sendValue(
            payable(msg.sender),
            tokenIDtoMetadata[_tokenID].stakedETH +
                tokenIDToExitReward[_tokenID]
        );
    }

    /**
     * @notice this function is called by the backend controller when the UserRequestedWithdrawal is emited
     * @dev the rewards are calculated by the backend controller and are then stored in the contract, this is needed to be able to calculate the rewards correctly including MEV rewards. There off-chain calculated rewards cannot be lower than the on-chain estimated rewards.
     * @param _tokenID the tokenID of the validator
     * @param _calcReward the calculated rewards in wei
     *
     */
    function calcRewards(
        uint256 _tokenID,
        uint256 _calcReward
    ) public onlyRole(RP_BACKEND_ROLE) {
        tokenIDToExitReward[_tokenID] = _calcReward;
    }

    // functions for future maintainability
    // all functions below are only callable by the ADJ_CONFIG_ROLE, which is only assigned to a multi-sig wallet owned by the team

    /**
        @notice the limit might change in the future if rocketpool supports 
        smaller pool sizes (RPIP-8)
    */
    function changeETHLimit8() external onlyRole(ADJ_CONFIG_ROLE) {
        curETHlimit = 8 ether;
        emit ETHLimitChanged(8 ether);
    }

    function lowerRPCommFee8(
        uint256 _amount
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        if (_amount >= 14) revert();
        rpComm8 = _amount;
    }

    // view / pure functions

    /**
        @notice the current depositing threshold
        @return is depositing enabled
    */
    function getCurrentEthLimit() public view returns (uint256) {
        return curETHlimit;
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
        @param _tokenID tokenID of the NFT, the user wants to unstake
        @return rewards in wei
     */
    function estRewardsNoMEV(uint256 _tokenID) internal view returns (uint256) {
        uint256 balance;
        uint256 balanceComm;
        if (curETHlimit >= 16 ether) {
            balance = (address(tokenIDtoValidator[_tokenID]).balance / 2);
            balanceComm = (15 * balance) / 100;
        } else {
            balance = (address(tokenIDtoValidator[_tokenID]).balance / 4);
            balanceComm = (rpComm8 * (balance * 3)) / 100;
        }
        uint256 wfee = calcWithdrawFee(_tokenID, msg.sender) * balanceComm;
        return (balance + balanceComm - wfee);
    }

    /// @notice total amount of supply
    /// @return total amount of ERC-1155 tokens of the contract
    function totalSupply() external view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = 1; i <= getTokenID(); i++) {
            amount += totalSupply(i);
        }
        return amount;
    }

    /** 
        @notice stake nft metdata location
        @dev this path will never change as the contract defines a collection
        @return the fixed collection metadata path 
     */
    function contractURI() external pure returns (string memory) {
        return
            "https://ipfs.blockscape.network/ipfs/QmUr8P96kNuFjcZb2WBjBP4e1fiGGXwRGChfTi42pnujY7";
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
                "https://ipfs.blockscape.network/ipns/k51qzi5uqu5di5eo5fzr1zypdsz0zct39zpct9s4wesjustul1caeofak3zoej/",
                Strings.toString(_tokenID),
                ".json"
            );
    }
}
