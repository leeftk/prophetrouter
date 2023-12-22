# UniswapV2Router01
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/UniswapV2Router01.sol)

**Inherits:**
[IUniswapV2Router01](/src/contracts/interfaces/IUniswapV2Router01.sol/interface.IUniswapV2Router01.md)


## State Variables
### factory

```solidity
address public immutable override factory;
```


### WETH

```solidity
address public immutable override WETH;
```


## Functions
### ensure


```solidity
modifier ensure(uint256 deadline);
```

### constructor


```solidity
constructor(address _factory, address _WETH) public;
```

### receive


```solidity
receive() external payable;
```

### _addLiquidity


```solidity
function _addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin
) private returns (uint256 amountA, uint256 amountB);
```

### addLiquidity


```solidity
function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external override ensure(deadline) returns (uint256 amountA, uint256 amountB, uint256 liquidity);
```

### addLiquidityETH


```solidity
function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
) external payable override ensure(deadline) returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
```

### removeLiquidity


```solidity
function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) public override ensure(deadline) returns (uint256 amountA, uint256 amountB);
```

### removeLiquidityETH


```solidity
function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
) public override ensure(deadline) returns (uint256 amountToken, uint256 amountETH);
```

### removeLiquidityWithPermit


```solidity
function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
) external override returns (uint256 amountA, uint256 amountB);
```

### removeLiquidityETHWithPermit


```solidity
function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
) external override returns (uint256 amountToken, uint256 amountETH);
```

### _swap


```solidity
function _swap(uint256[] memory amounts, address[] memory path, address _to) private;
```

### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external override ensure(deadline) returns (uint256[] memory amounts);
```

### swapTokensForExactTokens


```solidity
function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
) external override ensure(deadline) returns (uint256[] memory amounts);
```

### swapExactETHForTokens


```solidity
function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
    external
    payable
    override
    ensure(deadline)
    returns (uint256[] memory amounts);
```

### swapTokensForExactETH


```solidity
function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline,
    uint256 fee
) external override ensure(deadline) returns (uint256[] memory amounts);
```

### swapExactTokensForETH


```solidity
function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline,
    uint256 fee
) external override ensure(deadline) returns (uint256[] memory amounts);
```

### swapETHForExactTokens


```solidity
function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
    external
    payable
    override
    ensure(deadline)
    returns (uint256[] memory amounts);
```

### quote


```solidity
function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) public pure override returns (uint256 amountB);
```

### getAmountOut


```solidity
function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
    public
    pure
    override
    returns (uint256 amountOut);
```

### getAmountIn


```solidity
function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
    public
    pure
    override
    returns (uint256 amountIn);
```

### getAmountsOut


```solidity
function getAmountsOut(uint256 amountIn, address[] memory path)
    public
    view
    override
    returns (uint256[] memory amounts);
```

### getAmountsIn


```solidity
function getAmountsIn(uint256 amountOut, address[] memory path)
    public
    view
    override
    returns (uint256[] memory amounts);
```

