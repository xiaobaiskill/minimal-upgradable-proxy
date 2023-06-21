// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/mock/PayableToken.sol";
import "src/mock/PayableTokenV2.sol";

contract PayableTokenTest is Test {
    bytes constant proxyCode =
        hex"602080604038033d39808038038139513d51553d51603a80602460403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3";

    function setUp() public {
        vm.deal(address(this), 100 ether);
    }

    function testProxy() public {
        PayableToken v1 = new PayableToken();

        address proxy = create2Proxy(v1.getImplementSlot(), address(v1));
        PayableToken(payable(proxy)).init();
        assertEq(PayableToken(payable(proxy)).owner(), address(this));

        PayableToken(payable(proxy)).setNumber{value: 1 ether}(11);
        assertEq(payable(proxy).balance, 1 ether);

        (bool success, ) = proxy.call{value: 10 ether}("");
        assertEq(success, true);
        assertEq(payable(proxy).balance, 11 ether);

        (success, ) = proxy.call{value: 1 ether}(
            abi.encodeWithSignature("transfer(address)", address(this))
        );
        assertEq(success, true);
        assertEq(payable(proxy).balance, 12 ether);
        assertEq(PayableToken(payable(proxy)).number(), 14);

        PayableTokenV2 v2 = new PayableTokenV2();
        PayableToken(payable(proxy)).upgrade(address(v2));

        (success, ) = proxy.call{value: 10 ether}("");
        assertEq(success, false);

        (success, ) = proxy.call{value: 1 ether}(
            abi.encodeWithSignature("transfer(address)", address(this))
        );
        assertEq(success, false);

        assertEq(PayableToken(payable(proxy)).owner(), address(this));
        PayableToken(payable(proxy)).setNumber{value: 1 ether}(12);
        assertEq(payable(proxy).balance, 13 ether);
    }

    function create2Proxy(uint256 slot, address logic)
        internal
        returns (address proxy)
    {
        bytes memory code = abi.encodePacked(
            proxyCode,
            abi.encode(slot, logic)
        );
        assembly {
            proxy := create2(0, add(code, 0x20), mload(code), 0x0)
            if iszero(extcodesize(proxy)) {
                revert(0, 0)
            }
        }
    }
}
