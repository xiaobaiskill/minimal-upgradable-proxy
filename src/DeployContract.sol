// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "src/interface/Implement.sol";

contract DeployContractV2 {
    function createContract(address _logic) external returns (address proxy) {
        bytes memory code = abi.encodePacked(
            hex"7f",
            Implement(_logic).getImplementSlot(),
            hex"73",
            _logic,
            hex"8155600a604c3d39600a5260106056602a39603a3df3363d3d373d3d3d363d7f545af43d82803e3d8282603857fd5bf3"
        );
        assembly {
            proxy := create(0, add(code, 0x20), mload(code))
            if iszero(extcodesize(proxy)) {
                revert(0, 0)
            }
        }
    }
}
