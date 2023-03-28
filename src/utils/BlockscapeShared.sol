// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "openzeppelin-contracts/utils/Address.sol";

import "./BlockscapeAccess.sol";
import "./BlockscapeEvents.sol";
import "./BlockscapeErrors.sol";

import "./interfaces/IRocketStorage.sol";
import "./interfaces/IRocketNodeStaking.sol";
import "./interfaces/IRocketMinipoolManager.sol";

// TODO: add all natspec
abstract contract BlockscapeShared is
    BlockscapeAccess,
    BlockscapeErrors,
    BlockscapeEvents
{
    /// @dev using OZs sendValue implementation
    using Address for address payable;

    /// @dev the initial vault state is open
    bool public vaultOpen = true;

    /// @notice current initial RP commission for 8 ETH minipools
    uint256 public rpComm8 = 14;

    /// @notice Blockscape Rocket Pool Node Address
    address payable public blockscapeRocketPoolNode =
        payable(0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982); //0xB467959ADFc3fA8d99470eC12F4c95aa4D9b59e5;

    /** 
        @notice initial tokenID
        @dev the tokenID is used to identify the NFTs
    */
    uint256 tokenID = 1;

    /// @dev the current timelock for a withdrawal request
    uint256 timelockWithdraw = 7 days;

    /// @notice current initial withdraw fee
    uint256 public initWithdrawFee = 20 * 1e18;

    /// @dev Mapping withdrawal requester to timestamp of request to keep record
    mapping(address => uint256) public senderToTimestamp;

    /// @dev Metadata struct
    struct Metadata {
        uint256 stakedETH;
        uint256 stakedTimestamp;
    }

    /// @dev Mappings of tokenID to Metadata
    mapping(uint256 => Metadata) tokenIDtoMetadata;

    /// @dev Mappings of tokenID to the final exit reward for the staker
    mapping(uint256 => uint256) public tokenIDToExitReward;

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

    /**
     * @notice has the node enough RPL to stake another minipool
     * @return true if the node has enough RPL to stake another minipool
     */

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

        return (nodeRPLStake - minimumReqRPL) >= 0;
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

    /**
     * @notice sets the stakedETH and stakedTimestamp for a given tokenID inm the Metadata struct
     * @param _stakedETH the amount of ETH staked
     * @param _tokenID  the tokenID of the NFT
     */
    function _setMetadataForStakeInternal(
        uint256 _stakedETH,
        uint256 _tokenID
    ) internal {
        Metadata memory metadata;
        metadata.stakedETH = _stakedETH;
        metadata.stakedTimestamp = block.timestamp;
        tokenIDtoMetadata[_tokenID] = metadata;
    }

    /**
        @notice the tokenID is incremented with every pool
        @return the current tokenID 
     */
    function getTokenID() public view returns (uint256) {
        return tokenID;
    }

    /**
        @notice how much balance does this contract current have
        @return amount in wei
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
        @notice gets the metadata of a given pool
        @param _tokenID identifies the pool
        @return BlockscapeStaking.Metadata of the pool
     */
    function getMetadata(
        uint256 _tokenID
    ) external view returns (Metadata memory) {
        return (tokenIDtoMetadata[_tokenID]);
    }

    /**
     * @notice makes the vault stakable again after it has been closed
     * @dev is triggered when the vault can be staked at rocketpool
     */
    function openVault() external onlyRole(EMERGENCY_ROLE) {
        if (!BlockscapeShared.hasNodeEnoughRPLStake())
            revert NotEnoughRPLStake();

        if (vaultOpen) revert ErrorVaultState(vaultOpen);

        vaultOpen = true;
    }

    /// @notice opens the vault after the recent Validator data has been updated
    /// and is associated with the recent _tokenID
    function _openVaultInternal() internal {
        vaultOpen = true;
    }

    /**
        @notice is triggered when the vault can be staked at rocketpool
        @dev future staking interactions are prevented afterwards
     */
    function closeVault() external onlyRole(EMERGENCY_ROLE) {
        vaultOpen = false;
    }

    /// @notice closes the vault to temporarily prevent further depositing
    function _closeVaultInternal() internal {
        vaultOpen = false;
    }

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
        @notice the withdraw fee might be lowered in the future
        @dev only the user with the ADJ_CONFIG_ROLE can call this function
        @param _amount the new fee in wei
     */
    function lowerWithdrawFee(
        uint256 _amount
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        if (_amount >= 20 * 1e18) revert();
        initWithdrawFee = _amount;
    }

    /**
        @notice the timelock for withdraw might be lowered in the future
        @dev only the user with the ADJ_CONFIG_ROLE can call this function
        @param _newTimelock the new timelock period in days
     */
    function lowerTimelockWithdraw(
        uint256 _newTimelock
    ) external onlyRole(ADJ_CONFIG_ROLE) {
        if (_newTimelock > 7 days) revert();
        timelockWithdraw = _newTimelock;
    }

    /// @notice allow contract to receive ETH without making a delegated call
    receive() external payable {}

    /// @notice allow user to request a withdrawal
    function prepareWithdrawalProcess(uint256 _tokenID) external virtual {}

    /// @notice enable the user to withdraw his/her funds
    function withdrawFunds(uint256 _tokenID) external virtual {}

    /// @notice calculates the withdraw fee for a given user and tokenID
    function calcWithdrawFee(
        uint256 _tokenID,
        address _user
    ) public view virtual returns (uint256 _amount) {}
}
