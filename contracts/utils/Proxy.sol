// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/interface/Implement.sol";

abstract contract Proxy is Implement {
    address private implementation;

    event Upgraded(address indexed implementation);

    function getImplementSlot() public pure returns (uint256 slot) {
        assembly {
            slot := implementation.slot
        }
    }

    function _upgrade(address _newImplementation) internal {
        implementation = _newImplementation;
        emit Upgraded(_newImplementation);
    }
}
