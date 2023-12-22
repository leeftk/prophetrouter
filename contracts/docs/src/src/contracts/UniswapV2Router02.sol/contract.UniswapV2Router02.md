# UniswapV2Router02
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/UniswapV2Router02.sol)

**Inherits:**
[IUniswapV2Router02](/src/contracts/interfaces/IUniswapV2Router02.sol/interface.IUniswapV2Router02.md)


## State Variables
### factory

```solidity
address public constant override factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
```


### WETH

```solidity
address public constant override WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
```


### totalFeeCollected

```solidity
uint256 public totalFeeCollected;
```


### owner

```solidity
address public owner;
```


## Functions
### ensure


```solidity
modifier ensure(uint256 deadline);
```

### onlyOwner


```solidity
modifier onlyOwner();
```

### constructor


```solidity
constructor() public;
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
) internal virtual returns (uint256 amountA, uint256 amountB);
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
) external virtual override ensure(deadline) returns (uint256 amountA, uint256 amountB, uint256 liquidity);
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
)
    external
    payable
    virtual
    override
    ensure(deadline)
    returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
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
) public virtual override ensure(deadline) returns (uint256 amountA, uint256 amountB);
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
) public virtual override ensure(deadline) returns (uint256 amountToken, uint256 amountETH);
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
) external virtual override returns (uint256 amountA, uint256 amountB);
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
) external virtual override returns (uint256 amountToken, uint256 amountETH);
```

### removeLiquidityETHSupportingFeeOnTransferTokens


```solidity
function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
) public virtual override ensure(deadline) returns (uint256 amountETH);
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
) external virtual override returns (uint256 amountETH);
```

### _swap


```solidity
function _swap(uint256[] memory amounts, address[] memory path, address _to) internal virtual;
```

### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external virtual override ensure(deadline) returns (uint256[] memory amounts);
```

### swapTokensForExactTokens


```solidity
function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
) external virtual override ensure(deadline) returns (uint256[] memory amounts);
```

### swapExactETHForTokens


```solidity
function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
    external
    payable
    virtual
    override
    ensure(deadline)
    returns (uint256[] memory amounts);
```

### swapTokensForExactETH


```solidity
function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address tokenAddress,
    address to,
    uint256 deadline,
    uint256 feeAmount
) external virtual override ensure(deadline) returns (uint256[] memory amounts);
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
) external virtual override ensure(deadline) returns (uint256[] memory amounts);
```

### swapETHForExactTokens


```solidity
function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
    external
    payable
    virtual
    override
    ensure(deadline)
    returns (uint256[] memory amounts);
```

### _swapSupportingFeeOnTransferTokens


```solidity
function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual;
```

### swapExactTokensForTokensSupportingFeeOnTransferTokens


```solidity
function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external virtual override ensure(deadline);
```

### ProphetSmartSell

Executes a smart sell operation with a fee, swapping tokens for ETH

*This function includes a fee mechanism and uses internal swap functions*


```solidity
function ProphetSmartSell(uint256 amountOut, uint256 amountInMax, address tokenAddress, uint256 deadline, uint256 fee)
    public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|The amount of ETH to receive from the swap|
|`amountInMax`|`uint256`|The maximum amount of input tokens to sell|
|`tokenAddress`|`address`|The address of the token to sell|
|`deadline`|`uint256`|The time by which the transaction must be confirmed|
|`fee`|`uint256`|The fee percentage for the operation|


### ProphetBuy

Executes a buy operation with a fee, swapping ETH for tokens

*This function includes a fee mechanism and supports fee-on-transfer tokens*


```solidity
function ProphetBuy(uint256 amountOutMin, address tokenAddress, uint256 deadline, uint256 fee)
    external
    payable
    virtual
    override
    ensure(deadline);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amountOutMin`|`uint256`|The minimum amount of output tokens to receive|
|`tokenAddress`|`address`|The address of the output token|
|`deadline`|`uint256`|The time by which the transaction must be confirmed|
|`fee`|`uint256`|The fee percentage for the operation|


### ProphetSell

Executes a sell operation with a fee, swapping tokens for ETH and supporting fee-on-transfer tokens

*This function includes a fee mechanism and supports fee-on-transfer tokens*


```solidity
function ProphetSell(uint256 amountIn, uint256 amountOutMin, address tokenAddress, uint256 deadline, uint256 fee)
    external
    virtual
    override
    ensure(deadline);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amountIn`|`uint256`|The amount of input tokens to sell|
|`amountOutMin`|`uint256`|The minimum amount of ETH to receive|
|`tokenAddress`|`address`|The address of the input token|
|`deadline`|`uint256`|The time by which the transaction must be confirmed|
|`fee`|`uint256`|The fee percentage for the operation|


### withdraw

Allows the contract owner to withdraw tokens from the contract


```solidity
function withdraw(address _token) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|The token address to withdraw|


### withdrawETH

Allows the contract owner to withdraw ETH from the contract


```solidity
function withdrawETH() external onlyOwner;
```

### quote


```solidity
function quote(uint256 amountA, uint256 reserveA, uint256 reserveB)
    public
    pure
    virtual
    override
    returns (uint256 amountB);
```

### getAmountOut


```solidity
function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
    public
    pure
    virtual
    override
    returns (uint256 amountOut);
```

### getAmountIn


```solidity
function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
    public
    pure
    virtual
    override
    returns (uint256 amountIn);
```

### getAmountsOut


```solidity
function getAmountsOut(uint256 amountIn, address[] memory path)
    public
    view
    virtual
    override
    returns (uint256[] memory amounts);
```

### getAmountsIn


```solidity
function getAmountsIn(uint256 amountOut, address[] memory path)
    public
    view
    virtual
    override
    returns (uint256[] memory amounts);
```

### getPathForTokenToToken

Helper function to get the swap path for token to token or ETH to token swaps


```solidity
function getPathForTokenToToken(bool swapETH, address _tokenOut) private pure returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`swapETH`|`bool`|Indicates whether the swap involves ETH|
|`_tokenOut`|`address`|The address of the output token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|path The swap path as an array of addresses|


### setOwnership


```solidity
function setOwnership(address user) public onlyOwner;
```

