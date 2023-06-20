// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/mock/SimProxyV2.sol";
import "forge-std/console2.sol";

interface implement {
    function getImplementSlot() external view returns (uint256 slot);
}

contract ProxyTest is Test {
    function setUp() public {}

    function testProxyV2() public {
        SimProxyV2 addr = new SimProxyV2();
        address proxy = getProxy(address(addr));
        SimProxyV2(proxy).init(address(this));
        assertEq(SimProxyV2(proxy).owner(), address(this));
    }

    function getProxy(address _logic) internal view returns (address proxy) {
        bytes32 proxyBytes = keccak256(
            abi.encodePacked(
                hex"ff",
                _logic,
                bytes32(uint256(1)),
                keccak256(
                    abi.encodePacked(
                        hex"7f",
                        implement(_logic).getImplementSlot(),
                        hex"73",
                        _logic,
                        hex"8155603a80604760403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3"
                    )
                )
            )
        );

        return address(uint160(uint256(proxyBytes)));
    }
}
