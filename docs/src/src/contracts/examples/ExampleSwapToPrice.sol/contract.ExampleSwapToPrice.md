# ExampleSwapToPrice
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/examples/ExampleSwapToPrice.sol)


## State Variables
### router

```solidity
IUniswapV2Router01 public immutable router;
```


### factory

```solidity
address public immutable factory;
```


## Functions
### constructor


```solidity
constructor(address factory_, IUniswapV2Router01 router_) public;
```

### swapToPrice


```solidity
function swapToPrice(
    address tokenA,
    address tokenB,
    uint256 truePriceTokenA,
    uint256 truePriceTokenB,
    uint256 maxSpendTokenA,
    uint256 maxSpendTokenB,
    address to,
    uint256 deadline
) public;
```

