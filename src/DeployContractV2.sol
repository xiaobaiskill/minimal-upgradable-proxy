// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface implement {
    function getImplementSlot() external returns (uint256 slot);
}

contract DeployContractV2 {
    bytes constant proxyCode =
        hex"602080604038033d39808038038139513d51553d51603a80602460403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3";

    function createContract(address _logic) external returns (address proxy) {
        bytes memory code = abi.encodePacked(
            hex"7f",
            implement(_logic).getImplementSlot(),
            hex"73",
            _logic,
            hex"8155603a80604760403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3"
        );
        assembly {
            proxy := create(0, add(code, 0x20), mload(code))
            if iszero(extcodesize(proxy)) {
                revert(0, 0)
            }
        }
    }
}
