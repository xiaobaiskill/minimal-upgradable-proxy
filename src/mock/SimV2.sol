// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimV2 {
    address public owner;
    address private implement;
    uint256 public number;

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
            slot := implement.slot
        }
    }

    function upgrade(address _newImplement) external OnlyOwner {
        implement = _newImplement;
    }

    function setNumber(uint256 _number) external OnlyOwner {
        number = _number;
    }

    function addNumber(uint256 _num) external {
        number += _num;
    }
}
