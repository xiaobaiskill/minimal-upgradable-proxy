// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/mock/SimV1.sol";
import "src/mock/SimV2.sol";

// forge script -f "https://data-seed-prebsc-1-s1.binance.org:8545" script/proxy.s.sol --broadcast
contract ProxyScript is Script {
    bytes constant proxyCode =
        hex"602080604038033d39808038038139513d51553d51603a80602460403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3";

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY_TEST");
        vm.startBroadcast(privateKey);
        SimV1 v1 = new SimV1(11);
        address proxy = createProxy(v1.getImplementSlot(), address(v1));
        SimV1(proxy).init();
        SimV1(proxy).setNumber(12);

        SimV2 v2 = new SimV2(11);
        SimV1(proxy).upgrade(address(v2));
        SimV2(proxy).addNumber(2);
        vm.stopBroadcast();
    }

    function createProxy(uint256 slot, address logic)
        internal
        returns (address proxy)
    {
        bytes memory code = abi.encodePacked(
            proxyCode,
            abi.encode(slot, logic)
        );
        assembly {
            proxy := create(0, add(code, 0x20), mload(code))
        }
    }
}
