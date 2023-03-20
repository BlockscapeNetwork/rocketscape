// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
//import "openzeppelin-contracts/access/Ownable.sol"; replaced by: AccessControl
import "openzeppelin-contracts/access/AccessControl.sol";

import "openzeppelin-contracts/utils/Address.sol";

import "openzeppelin-contracts/utils/Strings.sol";
import "./utils/RocketStorageInterface.sol";
import "./utils/RocketNodeStakingInterface.sol";
import "./utils/RocketMinipoolManagerInterface.sol";

/** 
    @title Rocketpool Staking Allocation Contract
    @author Blockscape Finance AG <info@blockscape.network>
    @notice collects staking, mints NFT in return for staker and let's backend controller 
    transfer the stake when the pool is full (currently 16 ETH) and enough RPL are available
*/
contract BlockscapeValidatorNFT is
    ERC1155Supply,
    ReentrancyGuard,
    AccessControl
{
    /// @dev using OZs sendValue implementation
    using Address for address payable;

    /// @dev role to adjust the config of the smart contract parameters
    bytes32 public constant ADJ_CONFIG_ROLE = keccak256("ADJ_CONFIG_ROLE");

    /// @dev role for the backendController executer
    bytes32 public constant RP_BACKEND_ROLE = keccak256("RP_BACKEND_ROLE");

    /// @dev RocketStorageInterface of rocketpool
    RocketStorageInterface public constant ROCKET_STORAGE =
        RocketStorageInterface(0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46); // mainnet: 0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46 // goerli :0xd8Cd47263414aFEca62d6e2a3917d6600abDceB3

    /// @dev rocketpool contract interface for interactions with the rocketNodeStaking contract
    RocketNodeStakingInterface immutable rocketNodeStaking =
        RocketNodeStakingInterface(
            ROCKET_STORAGE.getAddress(
                keccak256(
                    abi.encodePacked("contract.address", "rocketNodeStaking")
                )
            )
        );

    /// @dev rocketpool contract interface for interactions with the rocketMinipoolManager contract
    RocketMinipoolManagerInterface immutable rocketMinipoolManager =
        RocketMinipoolManagerInterface(
            ROCKET_STORAGE.getAddress(
                keccak256(
                    abi.encodePacked(
                        "contract.address",
                        "rocketMinipoolManager"
                    )
                )
            )
        );

    /// @notice Blockscape Rocket Pool Node Address
    address payable public blockscapeRocketPoolNode =
        payable(0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982); //0xB467959ADFc3fA8d99470eC12F4c95aa4D9b59e5;

    /// @notice Current initial RP commission for 8 ETH minipools
    uint256 public rpComm8 = 14;

    /// @notice Current initial withdraw fee
    uint256 public initWithdrawFee = 20 * 1e18;

    /// @notice Current Rocketpool Minipool Limit
    uint256 public curETHlimit = 16 ether;

    /**
        @notice state of the Validator Vault
        @dev is `false` when validator is currently onboarding, will be reopened, as soon as 
        the backend controller withdraws the ETH batch & stakes it
    */
    bool public vaultOpen = true;

    /** 
        @notice initial tokenID for the NFTs
    */
    uint256 public tokenID = 1;

    /** 
        @notice array for storing the Validator Public Keys
        @dev the index is the tokenID of the NFT mapping to the validator public key
    */

    /// @dev Metadata struct
    struct Metadata {
        uint256 stakedETH;
        uint256 stakedTimestamp;
    }

    /// @dev Mappings of tokenID to Metadata
    mapping(uint256 => Metadata) public tokenIDtoMetadata;

    /// @dev Mappings of tokenID to Validator public key
    mapping(uint256 => address) public tokenIDtoValidator;

    /// @dev Mappings of tokenID to timestamp to track a request withdrawal
    mapping(address => uint256) public senderToTimestamp;

    /// @dev Mappings of tokenID to the final exit reward for the staker
    mapping(uint256 => uint256) public tokenIDToExitReward;

    /// @dev event for when a batch is tried to withdrawn but not enough rpl
    /// are available yet
    event RPLStakeRequired(uint256 _availRPL, uint256 _requiredRPL);

    /// @dev event for when a user requests a withdrawal
    event UserRequestedWithdrawal(
        uint256 _tokenID,
        address _user,
        uint256 _fee,
        uint256 _stakedETH,
        uint256 _rewards
    );

    /// @dev event for when the ETH limit is changed
    event ETHLimitChanged(uint256 _newLimit);

    /// @dev event for when the RocketPool Node Address is changed
    event RocketPoolNodeAddressChanged(address _newAddress);

    /// @dev more RPL stake has to be done in order to open vault
    error NotEnoughRPLStake();

    /// @dev for a token the validator can only be set once otherwise revert
    error ValidatorAlreadySet(address _vali);

    /// @dev for a token the validator can only be set once otherwise revert
    error ErrorVaultState(bool _isOpen);

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
    {
        _grantRole(ADJ_CONFIG_ROLE, msg.sender);
        _grantRole(RP_BACKEND_ROLE, blockscapeRocketPoolNode);
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

    /// @notice makes the vault stakable again after it has been closed
    /// @dev is triggered when the vault can be staked at rocketpool
    function openVault() public onlyRole(RP_BACKEND_ROLE) {
        if (!hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        if (vaultOpen) revert();

        vaultOpen = true;
    }

    /**
        @notice is triggered when the vault can be staked at rocketpool
        @dev future staking interactions are prevented afterwards
     */
    function closeVault() external onlyRole(RP_BACKEND_ROLE) {
        vaultOpen = false;
    }

    /// @notice used when staking eth into the contract
    /// @dev the vault must be open and equal the depositing amount
    function depositValidatorNFT() external payable {
        if (!hasNodeEnoughRPLStake()) revert NotEnoughRPLStake();

        if (tokenIDtoValidator[tokenID] == address(0)) revert();

        if (!vaultOpen) revert ErrorVaultState(vaultOpen);

        if (curETHlimit != msg.value) revert();

        // create metadata for the new tokenID
        _metadataValidatorNFTInternal(msg.value, tokenID);

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
        vaultOpen = true;
    }

    /**
        @notice used when user wants to unstake
        @param _tokenID which validator NFT the staker wants to unstake; the backend will listen on the event and will unstake the validator. The ETH value with rewards is transparantly available via beacon chain explorers and will be reduced by the withdraw fee, which is fixed to 0.5% after one year.
     */
    function prepareWithdrawProcess(uint256 _tokenID) external {
        if (senderToTimestamp[msg.sender] <= 0) revert();

        uint256 curWithdrawFee = calcWithdrawFee(_tokenID, msg.sender);

        if (balanceOf(msg.sender, _tokenID) >= 1) {
            // && signer == msg.sender
            senderToTimestamp[msg.sender] = block.timestamp;
            emit UserRequestedWithdrawal(
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
    function withdrawFunds(uint256 _tokenID) external {
        if (senderToTimestamp[msg.sender] + 7 days < block.timestamp) revert();
        if (estRewardsNoMEV(_tokenID) <= 0) {
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

    /**
        @notice the withdraw fee might be lowered in the future
        @param _amount the new fee in wei
     */
    function lowerWithdrawFee(
        uint256 _amount
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        if (_amount >= 20 * 1e18) revert();
        initWithdrawFee = _amount;
    }

    function lowerRPCommFee8(
        uint256 _amount
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        if (_amount >= 14) revert();
        rpComm8 = _amount;
    }

    /**
        @notice gets used if blockscape changes the address of their rp node
        @param _newBlockscapeRocketPoolNode the new address of the rocketpool node
     */
    function setBlockscapeRocketPoolNode(
        address _newBlockscapeRocketPoolNode
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        blockscapeRocketPoolNode = payable(_newBlockscapeRocketPoolNode);
        emit RocketPoolNodeAddressChanged(_newBlockscapeRocketPoolNode);
    }

    // view / pure functions

    /** 
        @notice does the vault currently allow depositing
        @dev the backend controller will reopen then vault after the stake
        have been transferred
        @return is depositing enabled
    */
    function isVaultOpen() public view returns (bool) {
        return vaultOpen;
    }

    /**
        @notice the current depositing threshold
        @return is depositing enabled
    */
    function getCurrentEthLimit() public view returns (uint256) {
        return curETHlimit;
    }

    /**
        @notice show the currently available RPL stake which is needed to create 
        a pool on rocketscape
        @return the current available RPL stake with already deducted minimum
        stake
     */
    function getAvailableRPLStake() public view returns (uint256) {
        uint256 nodeRPLStake = rocketNodeStaking.getNodeRPLStake(
            blockscapeRocketPoolNode
        );

        return nodeRPLStake;
    }

    /**
        @notice calculates the required RPL needed to stake according to 
        poolsize
        @dev if the minipoollimit is `0` then the required stake is also `0`!
        @return the RPLs needed
     */
    function getReqRPLStake() public view returns (uint256) {
        uint256 minipoolLimit = rocketNodeStaking.getNodeMinipoolLimit(
            blockscapeRocketPoolNode
        );

        uint256 minimumRPLStake = rocketNodeStaking.getNodeMinimumRPLStake(
            blockscapeRocketPoolNode
        );

        if (minipoolLimit == 0) {
            return 0;
        }

        return (minimumRPLStake / minipoolLimit);
    }

    /// @notice has the node enough RPL to stake another minipool
    function hasNodeEnoughRPLStake() public view returns (bool) {
        uint256 minipoolLimit = rocketNodeStaking.getNodeMinipoolLimit(
            blockscapeRocketPoolNode
        );
        if (minipoolLimit == 0) {
            return false;
        }

        uint256 nodeRPLStake = rocketNodeStaking.getNodeRPLStake(
            blockscapeRocketPoolNode
        );
        uint256 minimumReqRPL = getReqRPLStake();

        if (minimumReqRPL > nodeRPLStake) {
            return false;
        }
        return (nodeRPLStake - minimumReqRPL) >= 0;
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
    ) public view returns (uint256 _amount) {
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
        @notice gets the metadata of a given pool
        @param _tokenID identifies the pool
        @return a Metadata object and a dynamic bytes array
     */
    function getMetadata(
        uint256 _tokenID
    ) external view returns (Metadata memory, address) {
        return (tokenIDtoMetadata[_tokenID], tokenIDtoValidator[_tokenID]);
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

    /**
        @notice this function is a on-chain calculation of the rocketpool ETH rewards. It does not take MEV into account & will only work correctly after the Shapella upgrade
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

    // Allow contract to receive ETH without making a delegated call
    receive() external payable {}

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

    // internal functions

    /**
        @notice creates and mints metadata for a given pool and staker
        @param _stakedETH staked amount from the sender
        @param _tokenID Identifier of the vault
    */
    function _metadataValidatorNFTInternal(
        uint256 _stakedETH,
        uint256 _tokenID
    ) internal {
        Metadata memory metadata;

        metadata.stakedETH = _stakedETH;
        metadata.stakedTimestamp = block.timestamp;

        tokenIDtoMetadata[_tokenID] = metadata;

        _mint(msg.sender, _tokenID, 1, "");
    }

    /// @notice closes the vault to temporarily prevent further depositing
    function _closeVaultInternal() internal {
        vaultOpen = false;
    }

    
    function name() public pure returns (string memory) {
        return "Blockscape Validator NFTs";
    }

    /**
     * @return symbol of the ERC-1155 token
     */
    function symbol() public pure returns (string memory) {
        return "BSV";
    }
}
