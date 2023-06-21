// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/mock/Example.sol";
import "forge-std/console2.sol";
import "src/interface/Implement.sol";

contract ExampleTest is Test {
    function setUp() public {}

    function testExample() public {
        // Deploying logical contracts will also deploy proxy contracts
        ExampleV1 v1 = new ExampleV1();

        // Calculate the proxy contract address through create2
        address proxy = getProxy(address(v1));
        ExampleV1(proxy).setNumber(10);
        assertEq(ExampleV1(proxy).number(), 10);

        // upgrade exampleV2
        ExampleV2 v2 = new ExampleV2();
        ExampleV1(proxy).upgrade(address(v2));
        ExampleV2(proxy).addNumber(10);
        assertEq(ExampleV1(proxy).number(), 20);
    }

    function getProxy(address _logic) internal view returns (address proxy) {
        bytes32 proxyBytes = keccak256(
            abi.encodePacked(
                hex"ff",
                _logic,
                bytes32(uint256(0)),
                keccak256(
                    abi.encodePacked(
                        hex"7f",
                        Implement(_logic).getImplementSlot(),
                        hex"73",
                        _logic,
                        hex"8155600a604c3d39600a5260106056602a39603a3df3363d3d373d3d3d363d7f545af43d82803e3d8282603857fd5bf3"
                    )
                )
            )
        );

        return address(uint160(uint256(proxyBytes)));
    }
}
