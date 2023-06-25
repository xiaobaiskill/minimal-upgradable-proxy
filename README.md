minimal upgradable proxy
---
## 1 create upgradable proxy contract ( 32 bytes slot)

### 1.1 evm opcode
In the following EVM code, the `PUSH0` instruction (EIP-3855) is used. As of 2023-06-23, the BSC chain does not support EIP-3855 yet.
```
# store logic address to slot of proxy contract
PUSH32 <slot>          [slot]
PUSH20 <logicAddress>  [logicAddress slot]
DUP2                   [slot logicAddress slot]
SSTORE                 [slot]          => storage(slot => logicAddress)

# return deployedCode
PUSH1 0x9              [0x9 slot]
PUSH1 0x4c             [0x4c 0x9 slot]
PUSH0                  [00 0x4c 0x9 slot]
CODECOPY               [slot]          ==> memory(0x00~0x8: 0x4c~0x54(deployedCode1stPart))
PUSH1 0x9              [0x9 slot]    
MSTORE                 []              ==> memory(0x9~0x28: slot(deployedCode2ndPart))
PUSH1 0x10             [0x10]
PUSH1 0x55             [0x55 0x10]
PUSH1 0x29             [0x29 0x55 0x10]     
CODECOPY               []              ==> memory(0x29~0x38: 0x55~0x64(deployedCode3rdPart))
PUSH1 0x39             [0x39]
PUSH0                  [00 0x39]
RETURN


# proxy contract (deployedcode)
CALLDATASIZE        [calldatasize] 
PUSH0               [00 calldatasize]
PUSH0               [00 00 calldatasize]
CALLDATACOPY        []     ==> memory(00~(calldatasize-1) => codedata)
PUSH0               [00]
PUSH0               [00 00]
CALLDATASIZE        [calldatasize 00 00]
PUSH0               [00 calldatasize 00 00]
PUSH32              [slot 00 calldatasize 00 00] 
SLOAD               [logicAddress 00 calldatasize 00 00]
GAS                 [gas logicAddress 00 calldatasize 00 00]
DELEGATECALL        [result]
RETURNDATASIZE      [returnDataSize result]
PUSH0               [00 returnDataSize result]
PUSH0               [00 00 returnDataSize result]
RETURNDATACOPY      [result] => memory(00~(RETURNDATASIZE - 1) => RETURNDATA)
RETURNDATASIZE      [returnDataSize result] 
PUSH0               [00 returnDataSize result] 
DUP3                [result 00 returnDataSize result]
PUSH1 0x37          [0x37 result 00 returnDataSize result]
JUMPI				[00 returnDataSize result]
REVERT              [result]
JUMPDEST            [00 returnDataSize result]
RETURN              [result]
```
### 1.2 evm opcode to code

* bytecode
replace `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` to a slot of 32bytes and replace `yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy` to a address of 20bytes before deploying contract 
```
7fxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx73yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy81556009604c3d396009526010605560293960395ff3365f5f375f5f365f7f545af43d5f5f3e3d5f82603757fd5bf3
```

* deployedcode 
wherein the bytes at indices 9 - 40 (inclusive) are replaced with the 32 byte slot of the master after created
```
365f5f375f5f365f7fxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx545af43d5f5f3e3d5f82603757fd5bf3
```


## 2 create upgradable proxy contract (1 byte slot)
If the slot value for storing the logic contract address is within the range of 255(inclusive), then create minimal upgradable proxy using the following code

### 2.1 evm opcode

```
# store logic address to slot of proxy contract
PUSH1 <slot>           [slot]
PUSH20 <logicAddress>  [logicAddress slot]
DUP2                   [slot logicAddress slot]
SSTORE                 [slot]          => storage(slot => logicAddress)

# return deployedCode
PUSH1 0x9              [0x9 slot]
PUSH1 0x30             [0x30 0x9 slot]
PUSH0                  [00 0x30 0x9 slot]
CODECOPY               [slot]          ==> memory(0x00~0x8: 0x30~0x54(deployedCode1stPart))
PUSH1 0xf8             [0xf8 slot]
SHL                    [slotAfterShl]
PUSH1 0x9              [0x9 slotAfterShl]    
MSTORE                 []              ==> memory(0x9: slotAfterShl(deployedCode2ndPart))
PUSH1 0x10             [0x10]
PUSH1 0x39             [0x39 0x10]
PUSH1 0xa              [0xa 0x39 0x10]     
CODECOPY               []              ==> memory(0xa~0x38: 0x39~0x64(deployedCode3rdPart))
PUSH1 0x1a             [0x1a]
PUSH0                  [00 0x1a]
RETURN


# proxy contract (deployedcode)
CALLDATASIZE        [calldatasize] 
PUSH0               [00 calldatasize]
PUSH0               [00 00 calldatasize]
CALLDATACOPY        []     ==> memory(00~(calldatasize-1) => codedata)
PUSH0               [00]
PUSH0               [00 00]
CALLDATASIZE        [calldatasize 00 00]
PUSH0               [00 calldatasize 00 00]
PUSH1               [slot 00 calldatasize 00 00] 
SLOAD               [logicAddress 00 calldatasize 00 00]
GAS                 [gas logicAddress 00 calldatasize 00 00]
DELEGATECALL        [result]
RETURNDATASIZE      [returnDataSize result]
PUSH0               [00 returnDataSize result]
PUSH0               [00 00 returnDataSize result]
RETURNDATACOPY      [result] => memory(00~(RETURNDATASIZE - 1) => RETURNDATA)
RETURNDATASIZE      [returnDataSize result] 
PUSH0               [00 returnDataSize result] 
DUP3                [result 00 returnDataSize result]
PUSH1 0x18          [0x18 result 00 returnDataSize result]
JUMPI				[00 returnDataSize result]
REVERT              [result]
JUMPDEST            [00 returnDataSize result]
RETURN              [result]
```

### 2.2 evm opcode to code

* bytecode
replace `xx` to a slot of 1byte and replace `yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy` to a address of 20bytes before deploying contract 
```
60xx73yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy8155600960305f3960f81b60095260106039600a39601a5ff3365f5f375f5f365f60545af43d5f5f3e3d5f82601857fd5bf3
```

* deployedcode 
wherein the bytes at indices 9 are replaced with the 1 byte slot of the master after created
```
365f5f375f5f365f60xx545af43d5f5f3e3d5f82601857fd5bf3
```
