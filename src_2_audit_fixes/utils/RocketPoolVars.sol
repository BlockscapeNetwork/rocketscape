pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "./BlockscapeAccess.sol";

import "./interfaces/IRocketStorage.sol";
import "./interfaces/IRocketNodeStaking.sol";
import "./interfaces/IRocketMinipoolManager.sol";

/// @dev more RPL stake has to be done in order to open vault
error NotEnoughRPLStake();

// TODO: add all natspec
contract RocketPoolVars is BlockscapeAccess {
    /// @notice Current initial RP commission for 8 ETH minipools
    uint256 public rpComm8 = 14;

    /// @notice Blockscape Rocket Pool Node Address
    address payable public blockscapeRocketPoolNode =
        payable(0xF6132f532ABc3902EA2DcaE7f8D7FCCdF7Ba4982); //0xB467959ADFc3fA8d99470eC12F4c95aa4D9b59e5;

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

    /// @dev event for when the RocketPool Node Address is changed
    event RocketPoolNodeAddressChanged(address _newAddress);

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
}
