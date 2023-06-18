最小可升级合约
---

### 创建可升级代理合约的 汇编代码
```
# store logic address to logic slot
PUSH1 0x20           [20]
DUP1                 [20 20]
PUSH1 0x40           [40 20 20]
CODESIZE             [codesize 40 20 20]
SUB                  [slotOffset 20 20]
RETURNDATASIZE       [00 slotOffset 20 20]
CODECOPY             [20]                  => memory(0~0x20: slot)
DUP1                 [20 20]
DUP1                 [20 20 20]
CODESIZE             [codesize 20 20 20]
SUB                  [logicAddressOffset 20 20]
DUP2                 [20 logicAddressOffset 20 20]
CODECOPY             [20]                  => memory(0x20~0x40: logicAddress)
MLOAD                [logicAddress]
RETURNDATASIZE       [00 logicAddress]
MLOAD                [slot logicAddress]
SSTORE               []              ==> storage(slot => logicAddress)

# return deployedCode
RETURNDATASIZE       [00]
MLOAD                [slot]
PUSH1 0x3a           [3a slot]
DUP1                 [3a 3a slot]
PUSH1 0x24           [24 3a 3a slot]  
PUSH1 0x40           [40 24 3a 3a slot]
CODECOPY             [3a slot]  ==> memory(0x40~0x7a: 24~3a(deployedCode))
SWAP1                [slot 3a]
PUSH1 0x4a           [4a slot 3a]               
MSTORE               [3a]      => memory(4a => slot)
PUSH1 0x40           [40 3a]
RETURN

# proxy contract
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
602080604038033d39808038038139513d51553d51603a80602460403990604a526040f3363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3
```

* 代理合约创建后的合约code 
```
363d3d373d3d3d363d7f0000000000000000000000000000000000000000000000000000000000000000545af43d82803e3d8282603857fd5bf3
```

* 说明
```
0000000000000000000000000000000000000000000000000000000000000000 : 表示为 存储 逻辑合约的 slot 值
```