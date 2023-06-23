// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "contracts/utils/Proxy.sol";

contract ExampleV1 is Proxy {
    uint256 public number;

    constructor() {
        // deploy proxy contract by logic contract
        bytes memory code = abi.encodePacked(
            hex"7f",
            getImplementSlot(),
            hex"73",
            address(this),
            hex"81556009604c3d396009526010605560293960395ff3365f5f375f5f365f7f545af43d5f5f3e3d5f82603757fd5bf3"
        );
        assembly {
            let proxy := create2(0, add(code, 0x20), mload(code), 0x0)
            if iszero(extcodesize(proxy)) {
                revert(0, 0)
            }
        }
    }

    function upgrade(address _newImplementation) external {
        _upgrade(_newImplementation);
    }

    function setNumber(uint256 _number) external {
        number = _number;
    }
}

contract ExampleV2 is Proxy {
    uint256 public number;

    function upgrade(address _newImplementation) external {
        _upgrade(_newImplementation);
    }

    function setNumber(uint256 _number) external {
        number = _number;
    }

    function addNumber(uint256 _number) external {
        number += _number;
    }
}
