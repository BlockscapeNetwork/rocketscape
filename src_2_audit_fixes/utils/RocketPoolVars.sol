pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

import "./interfaces/IRocketStorage.sol";
import "./interfaces/IRocketNodeStaking.sol";
import "./interfaces/IRocketMinipoolManager.sol";

// TODO: add all natspec
contract RocketPoolVars {
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
}
