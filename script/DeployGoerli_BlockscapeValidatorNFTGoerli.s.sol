// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import {BlockscapeValidatorNFTGoerli} from "src/BlockscapeValidatorNFTGoerli.sol";

contract EthAllocatorScript is Script {

    BlockscapeValidatorNFTGoerli blockscapeValidatorNFTGoerli;
    
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        blockscapeValidatorNFTGoerli = new BlockscapeValidatorNFTGoerli();
        blockscapeValidatorNFTGoerli.openValidatorNFT();
      //  blockscapeValidatorNFT.transferOwnership(0xf0d22Db91DE516b44e5c976F71E394c9ac97e645);
        //blockscapeValidatorNFT.depositValidatorNFT{value: 0.001 ether}();
        vm.stopBroadcast();
    }
}
