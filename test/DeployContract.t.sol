// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/mock/SimV1.sol";
import "src/mock/SimV2.sol";
import "src/DeployContract.sol";

contract DeployContractTest is Test {
    DeployContractV2 dc;

    function setUp() public {
        dc = new DeployContractV2();
    }

    function testProxy() public {
        SimV1 v1 = new SimV1(11);
        address proxy = dc.createContract(address(v1));

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
}
