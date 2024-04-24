// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract OtherProxy0 {
    // implementation must be 0.
    // When inheriting this contract, please place it in the first inheritance position.
    // example: contract xxx is Proxy0,....
    address private implementation;

    event Upgraded(address indexed implementation);

    constructor(bool _deployProxy) {
        if (_deployProxy) {
            uint256 slot;
            assembly {
                slot := implementation.slot
            }
            require(slot == 0, "implementation.slot must be zero");
            // deploy proxy contract by logic contract
            bytes memory code = abi.encodePacked(
                hex"73",
                address(this),
                hex"3d55601a60213d39601a3df3363d3d373d3d3d363d3d545af43d82803e3d8282601857fd5bf3"
            );

            assembly {
                // deploy proxy using create
                let proxy := create2(0, add(code, 0x20), mload(code), 0x0)
                if iszero(extcodesize(proxy)) {
                    revert(0, 0)
                }
            }
        }
    }
}

interface INumber {
    function getNumber() external view returns (uint256);
}

contract other1 is OtherProxy0, INumber {
    uint256 public number;

    constructor(bool _deploy) OtherProxy0(_deploy) {}

    function init(uint256 _number) public {
        number = _number;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}

contract other2 is INumber {
    uint256 public number;

    constructor(uint256 _number) {
        number = _number;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}

contract other {
    address otherNum1;
    address otherNum2;

    constructor(address _otherNum1, address _otherNum2) {
        otherNum1 = _otherNum1;
        otherNum2 = _otherNum2;
    }

    function getNumber1() public view returns (uint256) {
        return INumber(otherNum1).getNumber() * INumber(otherNum2).getNumber();
    }

    function getNumber2() public view returns (uint256) {
        return INumber(otherNum2).getNumber() * INumber(otherNum1).getNumber();
    }
}
