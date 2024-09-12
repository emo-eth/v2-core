// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console2} from "forge-std/Script.sol";
import {BaseCreate2Script} from "create2-helpers-scripts/BaseCreate2Script.s.sol";

contract DeployFactory is BaseCreate2Script {
    function run() public {
        vm.createSelectFork(getChain("sepolia").rpcUrl);
        bytes memory code = vm.getCode("forge-release/UniswapV2Factory.sol/UniswapV2Factory.json");
        bytes memory deployCode = abi.encodePacked(code, abi.encode(address(0)));
        bytes memory pairCode = vm.getCode("forge-release/UniswapV2Pair.sol/UniswapV2Pair.json");

        bytes32 initCodeHash = keccak256(pairCode);
        console2.log("initCodeHash");
        console2.logBytes32(initCodeHash);
        // Ensure the init code hash is correct, since Router uses UniswapV2Library which has a hard-coded initcodeHash
        // Foundry quirks may cause this to fail if it produces different initcode
        require(
            initCodeHash == 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f, "wrong initcodehash"
        );

        _create2IfNotDeployed(deployer, keccak256(abi.encode(pairCode, address(0))), deployCode);
    }
}
