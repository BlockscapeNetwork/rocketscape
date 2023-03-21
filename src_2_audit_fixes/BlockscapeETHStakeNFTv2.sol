pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/utils/Strings.sol";

import "./utils/BlockscapeStaking.sol";
import "./utils/BlockscapeAccess.sol";
import "./utils/RocketPoolVars.sol";

/** 
    @title Rocketpool Staking Allocation Contract
    @author Blockscape Finance AG <info@blockscape.network>
    @notice collects staking, mints NFT in return for stake, which can be any amount of ETH
*/
contract BlockscapeETHStakeNFT is
    ERC1155Supply,
    ReentrancyGuard,
    BlockscapeAccess,
    BlockscapeStaking,
    RocketPoolVars
{
    /// @notice Current ETH pool supply
    uint256 poolSupply;

    /**
        @notice state of the Solo Vault Pool
        @dev is `false` when pool is full, will be reopened, as soon as 
        the backend controller withdraws & transfers the stake
    */

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
    {
        // TODO: Also _grantRoles here? -> if yes then put in BlockscapeStaking constructor
    }

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
        @notice withdraw the given amount to the backend, triggered when the acciount balance is above 16 ETH or 8 ETH (RPIP-8)
        @dev the withdraw function remains public as safety measurement to
        not lock-in client stakes in case of contract issues
        @param _amount the amount in wei to withdraw
     */
    function withdraw(uint256 _amount) external onlyRole(RP_BACKEND_ROLE) {
        Address.sendValue(
            payable(RocketPoolVars.blockscapeRocketPoolNode),
            _amount
        );
    }

    /// @notice used when staking eth into the contract
    /// @dev the vault must be open and equal the depositing amount
    function depositStakeNFT() external payable nonReentrant {
        assembly {
            // check is msg.value is higher than 0 ETH
            if lt(callvalue(), 0) {
                revert(0, 0)
            }
            if eq(callvalue(), 0) {
                revert(0, 0)
            }
        }

        // create metadata for the new tokenID
        _metadataStakeNFTInternal(msg.value, tokenID);

        assembly {
            // increase the tokenID
            let tokenID_value := sload(tokenID.slot)
            let new_tokenID_value := add(tokenID_value, 1)
            sstore(tokenID.slot, new_tokenID_value)
        }
        poolSupply += msg.value;
    }

    /**
        @notice update the stake of the given tokenID, if the NFT owner decides to stake more ETH
        @dev emits the StakeUpdated event & increases the poolSupply based on the msg.value
        @param _tokenID Identifier of the vault
    */
    function updateStake(uint256 _tokenID) external payable nonReentrant {
        if (balanceOf(msg.sender, _tokenID) >= 1) {
            assembly {
                // check is msg.value is higher than 0 ETH
                if lt(callvalue(), 0) {
                    revert(0, 0)
                }
                if eq(callvalue(), 0) {
                    revert(0, 0)
                }
            }

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
            revert("You do not own this NFT");
        }
    }

    /**
        @notice used when user wants to unstake
        @param _tokenID is the tokenID of the NFT
        @return _amount how much the user gets back
     */

    function userRequestFullWithdraw(
        uint256 _tokenID
    ) external returns (uint256 _amount) {
        uint256 curWithdrawFee = viewuserRequestFullWithdraw(_tokenID);

        if (balanceOf(msg.sender, _tokenID) >= 1) {
            poolSupply -= BlockscapeStaking
                .tokenIDtoMetadata[_tokenID]
                .stakedETH;

            emit BlockscapeStaking.UserRequestedWithdrawal(
                _tokenID,
                msg.sender,
                curWithdrawFee,
                BlockscapeStaking.tokenIDtoMetadata[_tokenID].stakedETH,
                // TODO:
                0
                // estRewardsNoMEV(_tokenID)
            );
        }

        return curWithdrawFee;
    }

    // functions for future maintainability

    /**
        @notice the withdraw fee might be changed in the future
        @param _amount the new fee in wei
     */
    function setWithdrawFee(
        uint256 _amount
    ) external onlyRole(RP_BACKEND_ROLE) {
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
    function viewuserRequestFullWithdraw(
        uint256 _tokenID
    ) public view returns (uint256 _amount) {
        uint256 curWithdrawFee = BlockscapeStaking.initWithdrawFee;

        if (balanceOf(msg.sender, _tokenID) >= 1) {
            uint256 secFee = (BlockscapeStaking.initWithdrawFee / 365 days); // 20%
            uint256 timePassed = block.timestamp -
                (BlockscapeStaking.tokenIDtoMetadata[_tokenID].stakedTimestamp);

            uint256 maxTime05EthReached = 30747600;

            if (timePassed >= maxTime05EthReached) {
                curWithdrawFee = 5 * 1e17; // fixed minimum fee 0,5 ether
            } else {
                curWithdrawFee = (BlockscapeStaking.initWithdrawFee -
                    (secFee * timePassed));
            }
        }
        return curWithdrawFee;
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
        @notice compares two values and checks if there are equal
        @dev hashes the stringified values and compares those hashes
        @return are the bytes equal
     */
    function _compareBytes(
        bytes memory a,
        bytes memory b
    ) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
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
