// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/mock/SimV1.sol";
import "src/mock/SimProxyV2.sol";
import "forge-std/console2.sol";

interface implement {
    function getImplementSlot() external view returns (uint256 slot);
}

// forge script -f "https://data-seed-prebsc-1-s1.binance.org:8545" script/SimProxyV2.s.sol --broadcast
// forge script -f "https://rpc.ankr.com/eth_goerli" script/SimProxyV2.s.sol --broadcast
// forge verify-contract  --verifier-url "https://api-goerli.etherscan.io/api" 0x35700366da1b884ddfa28cf3d5483975b029f49c src/mock/SimProxyV2.sol:SimProxyV2
contract SimProxyV2Script is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY_TEST");
        vm.startBroadcast(privateKey);
        SimProxyV2 addr = new SimProxyV2();
        address proxy = getProxy(address(addr));
        SimProxyV2(proxy).init(0x20cD8eB93c50BDAc35d6A526f499c0104958e3F6);
        vm.stopBroadcast();
    }

    function getProxy(address _logic) internal view returns (address proxy) {
        bytes32 proxyBytes = keccak256(
            abi.encodePacked(
                hex"ff",
                _logic,
                bytes32(0),
                keccak256(
                    abi.encodePacked(
                        hex"7f",
                        implement(_logic).getImplementSlot(),
                        hex"73",
                        _logic,
                        hex"8155600a604c3d39600a5260106056602a39603a3df3363d3d373d3d3d363d7f545af43d82803e3d8282603857fd5bf3"
                    )
                )
            )
        );

        return address(uint160(uint256(proxyBytes)));
    }
}
