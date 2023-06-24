// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SimV1 {
    address public owner;
    uint256 public number;
    address private implementation;

    event Upgraded(address indexed implementation);

    constructor(uint256 _number) {
        number = _number;
    }

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

    function setNumber(uint256 _number) external OnlyOwner {
        number = _number;
    }
}
