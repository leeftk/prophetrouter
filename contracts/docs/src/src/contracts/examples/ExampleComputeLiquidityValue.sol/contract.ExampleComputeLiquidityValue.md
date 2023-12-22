# ExampleComputeLiquidityValue
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/examples/ExampleComputeLiquidityValue.sol)


## State Variables
### factory

```solidity
address public immutable factory;
```


## Functions
### constructor


```solidity
constructor(address factory_) public;
```

### getReservesAfterArbitrage


```solidity
function getReservesAfterArbitrage(address tokenA, address tokenB, uint256 truePriceTokenA, uint256 truePriceTokenB)
    external
    view
    returns (uint256 reserveA, uint256 reserveB);
```

### getLiquidityValue


```solidity
function getLiquidityValue(address tokenA, address tokenB, uint256 liquidityAmount)
    external
    view
    returns (uint256 tokenAAmount, uint256 tokenBAmount);
```

### getLiquidityValueAfterArbitrageToPrice


```solidity
function getLiquidityValueAfterArbitrageToPrice(
    address tokenA,
    address tokenB,
    uint256 truePriceTokenA,
    uint256 truePriceTokenB,
    uint256 liquidityAmount
) external view returns (uint256 tokenAAmount, uint256 tokenBAmount);
```

### getGasCostOfGetLiquidityValueAfterArbitrageToPrice


```solidity
function getGasCostOfGetLiquidityValueAfterArbitrageToPrice(
    address tokenA,
    address tokenB,
    uint256 truePriceTokenA,
    uint256 truePriceTokenB,
    uint256 liquidityAmount
) external view returns (uint256);
```

