# IUniswapV2Router02
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/interfaces/IUniswapV2Router02.sol)

**Inherits:**
[IUniswapV2Router01](/src/contracts/interfaces/IUniswapV2Router01.sol/interface.IUniswapV2Router01.md)


## Functions
### removeLiquidityETHSupportingFeeOnTransferTokens


```solidity
function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
) external returns (uint256 amountETH);
```

### removeLiquidityETHWithPermitSupportingFeeOnTransferTokens


```solidity
function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
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
) external returns (uint256 amountETH);
```

### swapExactTokensForTokensSupportingFeeOnTransferTokens


```solidity
function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external;
```

### ProphetBuy


```solidity
function ProphetBuy(uint256 amountOutMin, address tokenAddress, uint256 deadline, uint256 fee) external payable;
```

### ProphetSell


```solidity
function ProphetSell(uint256 amountIn, uint256 amountOutMin, address tokenAddress, uint256 deadline, uint256 fee)
    external;
```

