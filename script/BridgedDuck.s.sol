// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/BridgedDuck.sol";

contract DeployDuckScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new BridgedDuck(
                'name',
                'token',
                'baseUri',
                address(bytes20(uint160(uint256(keccak256('desired address')))))
        );
        vm.stopBroadcast();
    }
}
