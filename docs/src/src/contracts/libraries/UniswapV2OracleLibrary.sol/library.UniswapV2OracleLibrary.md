# UniswapV2OracleLibrary
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/libraries/UniswapV2OracleLibrary.sol)


## Functions
### currentBlockTimestamp


```solidity
function currentBlockTimestamp() internal view returns (uint32);
```

### currentCumulativePrices


```solidity
function currentCumulativePrices(address pair)
    internal
    view
    returns (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp);
```

