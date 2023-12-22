# ExampleFlashSwap
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/examples/ExampleFlashSwap.sol)

**Inherits:**
IUniswapV2Callee


## State Variables
### factoryV1

```solidity
IUniswapV1Factory immutable factoryV1;
```


### factory

```solidity
address immutable factory;
```


### WETH

```solidity
IWETH immutable WETH;
```


## Functions
### constructor


```solidity
constructor(address _factory, address _factoryV1, address router) public;
```

### receive


```solidity
receive() external payable;
```

### uniswapV2Call


```solidity
function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override;
```

