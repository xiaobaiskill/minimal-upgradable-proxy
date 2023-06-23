// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "contracts/interface/Implement.sol";

contract DeployContract {
    function createContract(address _logic) external returns (address proxy) {
        bytes memory code = abi.encodePacked(
            hex"7f",
            Implement(_logic).getImplementSlot(),
            hex"73",
            _logic,
            hex"81556009604c3d396009526010605560293960395ff3365f5f375f5f365f7f545af43d5f5f3e3d5f82603757fd5bf3"
        );
        assembly {
            proxy := create2(0, add(code, 0x20), mload(code), 0x0)
            if iszero(extcodesize(proxy)) {
                revert(0, 0)
            }
        }
    }

    function precomputeContract(address _logic)
        external
        view
        returns (address)
    {
        bytes memory code = abi.encodePacked(
            hex"7f",
            Implement(_logic).getImplementSlot(),
            hex"73",
            _logic,
            hex"81556009604c3d396009526010605560293960395ff3365f5f375f5f365f7f545af43d5f5f3e3d5f82603757fd5bf3"
        );
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                uint256(0),
                                keccak256(code)
                            )
                        )
                    )
                )
            );
    }
}
