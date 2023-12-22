# IUniswapV1Exchange
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/interfaces/V1/IUniswapV1Exchange.sol)


## Functions
### balanceOf


```solidity
function balanceOf(address owner) external view returns (uint256);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 value) external returns (bool);
```

### removeLiquidity


```solidity
function removeLiquidity(uint256, uint256, uint256, uint256) external returns (uint256, uint256);
```

### tokenToEthSwapInput


```solidity
function tokenToEthSwapInput(uint256, uint256, uint256) external returns (uint256);
```

### ethToTokenSwapInput


```solidity
function ethToTokenSwapInput(uint256, uint256) external payable returns (uint256);
```

