// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/mock/SimV1.sol";
import "src/mock/SimV2.sol";

contract ProxyV2Test is Test {
    bytes constant proxyCode =
        hex"7f00000000000000000000000000000000000000000000000000000000000000007300000000000000000000000000000000000000008155603a80604760403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3";

    function setUp() public {}

    function testProxy() public {
        SimV1 v1 = new SimV1(11);
        address proxy = create2Proxy(v1.getImplementSlot(), address(v1));
        SimV1(proxy).init();
        SimV1(proxy).setNumber(12);
        assertEq(SimV1(proxy).owner(), address(this));
        assertEq(SimV1(proxy).number(), 12);

        assertEq(
            address(
                uint160(uint256(vm.load(proxy, bytes32(v1.getImplementSlot()))))
            ),
            address(v1)
        );

        SimV2 v2 = new SimV2(22);
        SimV1(proxy).upgrade(address(v2));
        SimV2(proxy).addNumber(1);
        assertEq(SimV2(proxy).number(), 13);
        assertEq(SimV1(proxy).owner(), address(this));
        assertEq(
            address(
                uint160(uint256(vm.load(proxy, bytes32(v1.getImplementSlot()))))
            ),
            address(v2)
        );
    }

    function create2Proxy(uint256 slot, address logic)
        internal
        returns (address proxy)
    {
        bytes memory code = abi.encodePacked(
            hex"7f",
            slot,
            hex"73",
            logic,
            hex"8155603a80604760403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3"
        );
        assembly {
            proxy := create2(0, add(code, 0x20), mload(code), 0x1)
            if iszero(extcodesize(proxy)) {
                revert(0, 0)
            }
        }
    }
}
