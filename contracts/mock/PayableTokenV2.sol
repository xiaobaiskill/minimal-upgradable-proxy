// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "contracts/utils/Proxy32.sol";

contract PayableTokenV2 {
    address private implementation;
    address public owner;
    uint256 public number;

    event Upgraded(address indexed implementation);

    modifier OnlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    function init() external {
        owner = msg.sender;
    }

    function getImplementSlot() external pure returns (uint256 slot) {
        assembly {
            slot := implementation.slot
        }
    }

    function upgrade(address _newImplementation) external OnlyOwner {
        implementation = _newImplementation;
        emit Upgraded(_newImplementation);
    }

    function setNumber(uint256 _number) external payable {
        require(msg.value >= 1 ether, "Insufficient amount");
        number = _number;
    }
}
