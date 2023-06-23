// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "contracts/utils/Proxy.sol";

contract SimV1 is Proxy {
    address public owner;
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

    function upgrade(address _newImplement) external OnlyOwner {
        _upgrade(_newImplement);
    }

    function setNumber(uint256 _number) external OnlyOwner {
        number = _number;
    }
}