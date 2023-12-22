# UniswapV2Migrator
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/UniswapV2Migrator.sol)

**Inherits:**
[IUniswapV2Migrator](/src/contracts/interfaces/IUniswapV2Migrator.sol/interface.IUniswapV2Migrator.md)


## State Variables
### factoryV1

```solidity
IUniswapV1Factory immutable factoryV1;
```


### router

```solidity
IUniswapV2Router01 immutable router;
```


## Functions
### constructor


```solidity
constructor(address _factoryV1, address _router) public;
```

### receive


```solidity
receive() external payable;
```

### migrate


```solidity
function migrate(address token, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline)
    external
    override;
```

