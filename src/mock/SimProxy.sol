// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/utils/Proxy.sol";
import "forge-std/console2.sol";

contract SimProxy is Proxy {
    address public owner;
    uint256 public number;

    constructor() payable {
        // deploying proxy contract by logic contract
        bytes memory code = abi.encodePacked(
            hex"7f",
            getImplementSlot(),
            hex"73",
            address(this),
            hex"8155600a604c3d39600a5260106056602a39603a3df3363d3d373d3d3d363d7f545af43d82803e3d8282603857fd5bf3"
        );
        address proxy;
        assembly {
            proxy := create2(0, add(code, 0x20), mload(code), 0x0)
            if iszero(extcodesize(proxy)) {
                revert(0, 0)
            }
        }
    }

    modifier OnlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    function init(address _owner) external {
        owner = _owner;
    }

    function upgrade(address _newImplement) external OnlyOwner {
        _upgrade(_newImplement);
    }

    function setNumber(uint256 _number) external payable {
        require(msg.value >= 1 ether, "Insufficient amount");
        number = _number;
    }
}