# ExampleOracleSimple
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/examples/ExampleOracleSimple.sol)


## State Variables
### PERIOD

```solidity
uint256 public constant PERIOD = 24 hours;
```


### pair

```solidity
IUniswapV2Pair immutable pair;
```


### token0

```solidity
address public immutable token0;
```


### token1

```solidity
address public immutable token1;
```


### price0CumulativeLast

```solidity
uint256 public price0CumulativeLast;
```


### price1CumulativeLast

```solidity
uint256 public price1CumulativeLast;
```


### blockTimestampLast

```solidity
uint32 public blockTimestampLast;
```


### price0Average

```solidity
FixedPoint.uq112x112 public price0Average;
```


### price1Average

```solidity
FixedPoint.uq112x112 public price1Average;
```


## Functions
### constructor


```solidity
constructor(address factory, address tokenA, address tokenB) public;
```

### update


```solidity
function update() external;
```

### consult


```solidity
function consult(address token, uint256 amountIn) external view returns (uint256 amountOut);
```

