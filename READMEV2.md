minimal upgradable proxy
---

replace `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` to a slot of 32bytes and replace `yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy` to a address of 20bytes before deploying contract 

### create upgradable proxy contract
```
# store logic address to slot of proxy contract
PUSH32 <slot>          [slot]
PUSH20 <logicAddress>  [logicAddress slot]
DUP2                   [slot logicAddress slot]
SSTORE                 [slot]                  => storage(slot => logicAddress)

# return deployedCode
PUSH1 0x3a           [3a slot]
DUP1                 [3a 3a slot]
PUSH1 0x47           [27 3a 3a slot]  
PUSH1 0x40           [40 47 3a 3a slot]
CODECOPY             [3a slot]  ==> memory(0x40~0x7a: 47~3a(deployedCode))
SWAP1                [slot 3a]
PUSH1 0x4a           [4a slot 3a]               
MSTORE               [3a]      => memory(4a => slot)
PUSH1 0x40           [40 3a]
RETURN

# proxy contract (deployedcode)
CALLDATASIZE        [calldatasize] 
RETURNDATASIZE      [00 calldatasize]
RETURNDATASIZE      [00 00 calldatasize]
CALLDATACOPY        []     ==> memory(00~calldatasize => codedata)
RETURNDATASIZE      [00]
RETURNDATASIZE      [00 00]
RETURNDATASIZE      [00 00 00]
CALLDATASIZE        [calldatasize 00 00 00]
RETURNDATASIZE      [00 calldatasize 00 00 00]
PUSH32 0x0000000000000000000000000000000000000000000000000000000000000000       [slot 00 calldatasize 00 00 00] 
SLOAD               [logicAddress 00 calldatasize 00 00 00]
GAS                 [gas logicAddress 00 calldatasize 00 00 00]
DELEGATECALL        [result 00]
RETURNDATASIZE      [returnDataSize result 00]
DUP3                [00 returnDataSize result 00]
DUP1                [00 00 returnDataSize result 00]
RETURNDATACOPY      [result 00] => memory(00~RETURNDATASIZE => RETURNDATA)
RETURNDATASIZE      [returnDataSize result 00] 
DUP3                [00 returnDataSize result 00] 
DUP3                [result 00 returnDataSize result 00]
PUSH1 0x38          [38 result 00 returnDataSize result 00]
JUMPI				[00 returnDataSize result 00]
REVERT              [result 00]
JUMPDEST            [00 returnDataSize result 00]
RETURN              [result 00]
```

* bytecode
```
7fxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx73yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy8155603a80604760403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3
```

* deployedcode 
wherein the bytes at indices 10 - 41 (inclusive) are replaced with the 32 byte slot of the master after created
```
363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3
```
