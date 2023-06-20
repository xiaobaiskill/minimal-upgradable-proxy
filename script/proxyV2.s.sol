// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/mock/SimV1.sol";
import "src/mock/SimV2.sol";

interface implement {
    function getImplementSlot() external returns (uint256 slot);
}

// forge script -f "https://data-seed-prebsc-1-s1.binance.org:8545" script/proxy.s.sol --broadcast
// forge script -f "https://rpc.ankr.com/eth_goerli" script/proxyV2.s.sol --broadcast
// forge verify-contract  --verifier-url "https://api-goerli.etherscan.io/api" 0x35700366da1b884ddfa28cf3d5483975b029f49c src/mock/SimV2.sol:SimV2
contract ProxyScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY_TEST");
        vm.startBroadcast(privateKey);
        SimV1 v1 = new SimV1(11);
        address proxy = createProxy(address(v1));
        SimV1(proxy).init();
        SimV1(proxy).setNumber(12);

        SimV2 v2 = new SimV2(11);
        SimV1(proxy).upgrade(address(v2));
        SimV2(proxy).addNumber(2);
        vm.stopBroadcast();
    }

    function createProxy(address _logic) internal returns (address proxy) {
        bytes memory code = abi.encodePacked(
            hex"7f",
            implement(_logic).getImplementSlot(),
            hex"73",
            _logic,
            hex"8155603a80604760403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3"
        );
        assembly {
            proxy := create(0, add(code, 0x20), mload(code))
        }
    }
}
