# RouterEventEmitter
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/test/RouterEventEmitter.sol)


## Functions
### receive


```solidity
receive() external payable;
```

### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(
    address router,
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external;
```

### swapTokensForExactTokens


```solidity
function swapTokensForExactTokens(
    address router,
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
) external;
```

### swapExactETHForTokens


```solidity
function swapExactETHForTokens(
    address router,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external payable;
```

### swapTokensForExactETH


```solidity
function swapTokensForExactETH(
    address router,
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
) external;
```

### swapExactTokensForETH


```solidity
function swapExactTokensForETH(
    address router,
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external;
```

### swapETHForExactTokens


```solidity
function swapETHForExactTokens(address router, uint256 amountOut, address[] calldata path, address to, uint256 deadline)
    external
    payable;
```

## Events
### Amounts

```solidity
event Amounts(uint256[] amounts);
```

