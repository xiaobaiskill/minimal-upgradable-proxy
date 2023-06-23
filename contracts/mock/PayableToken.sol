// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "contracts/utils/Proxy.sol";

contract PayableToken is Proxy {
    address public owner;
    uint256 public number;

    receive() external payable {
        number += 1;
    }

    fallback() external payable {
        number += 2;
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

    function setNumber(uint256 _number) external payable {
        require(msg.value >= 1 ether, "Insufficient amount");
        number = _number;
    }
}
