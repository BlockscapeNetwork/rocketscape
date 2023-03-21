pragma solidity 0.8.16;

// SPDX-License-Identifier: BUSL-1.1

// TODO: add all natspec
contract BlockscapeStaking {
    /// @dev Metadata struct
    struct Metadata {
        uint256 stakedETH;
        uint256 stakedTimestamp;
    }

    /// @dev Mappings of tokenID to Metadata
    mapping(uint256 => Metadata) tokenIDtoMetadata;
}
