// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import {BlockscapeValidatorNFT} from "src/BlockscapeValidatorNFT.sol";

contract EthAllocatorScript is Script {

    BlockscapeValidatorNFT blockscapeValidatorNFT;
    
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        blockscapeValidatorNFT = new BlockscapeValidatorNFT();
        blockscapeValidatorNFT.openValidatorNFT();
        blockscapeValidatorNFT.transferOwnership(0xB467959ADFc3fA8d99470eC12F4c95aa4D9b59e5);
        vm.stopBroadcast();
    }
}
