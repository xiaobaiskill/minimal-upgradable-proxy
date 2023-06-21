// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/utils/Proxy.sol";

contract ExampleV1 is Proxy {
    uint256 public number;

    constructor() {
        // deploy proxy contract by logic contract
        bytes memory code = abi.encodePacked(
            hex"7f",
            getImplementSlot(),
            hex"73",
            address(this),
            hex"8155600a604c3d39600a5260106056602a39603a3df3363d3d373d3d3d363d7f545af43d82803e3d8282603857fd5bf3"
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
