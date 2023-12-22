# UniswapV2Library
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/libraries/UniswapV2Library.sol)


## Functions
### sortTokens


```solidity
function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1);
```

### pairFor


```solidity
function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair);
```

### getReserves


```solidity
function getReserves(address factory, address tokenA, address tokenB)
    internal
    view
    returns (uint256 reserveA, uint256 reserveB);
```

### quote


```solidity
function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB);
```

### getAmountOut


```solidity
function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
    internal
    pure
    returns (uint256 amountOut);
```

### getAmountIn


```solidity
function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
    internal
    pure
    returns (uint256 amountIn);
```

### getAmountsOut


```solidity
function getAmountsOut(address factory, uint256 amountIn, address[] memory path)
    internal
    view
    returns (uint256[] memory amounts);
```

### getAmountsIn


```solidity
function getAmountsIn(address factory, uint256 amountOut, address[] memory path)
    internal
    view
    returns (uint256[] memory amounts);
```

