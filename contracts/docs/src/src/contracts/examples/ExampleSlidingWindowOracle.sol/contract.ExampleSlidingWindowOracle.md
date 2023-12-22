# ExampleSlidingWindowOracle
[Git Source](https://github.com/leeftk/prophetrouter/blob/a744328dd4441e9a4607bb5d3ed0087221d31252/src/contracts/examples/ExampleSlidingWindowOracle.sol)


## State Variables
### factory

```solidity
address public immutable factory;
```


### windowSize

```solidity
uint256 public immutable windowSize;
```


### granularity

```solidity
uint8 public immutable granularity;
```


### periodSize

```solidity
uint256 public immutable periodSize;
```


### pairObservations

```solidity
mapping(address => Observation[]) public pairObservations;
```


## Functions
### constructor


```solidity
constructor(address factory_, uint256 windowSize_, uint8 granularity_) public;
```

### observationIndexOf


```solidity
function observationIndexOf(uint256 timestamp) public view returns (uint8 index);
```

### getFirstObservationInWindow


```solidity
function getFirstObservationInWindow(address pair) private view returns (Observation storage firstObservation);
```

### update


```solidity
function update(address tokenA, address tokenB) external;
```

### computeAmountOut


```solidity
function computeAmountOut(
    uint256 priceCumulativeStart,
    uint256 priceCumulativeEnd,
    uint256 timeElapsed,
    uint256 amountIn
) private pure returns (uint256 amountOut);
```

### consult


```solidity
function consult(address tokenIn, uint256 amountIn, address tokenOut) external view returns (uint256 amountOut);
```

## Structs
### Observation

```solidity
struct Observation {
    uint256 timestamp;
    uint256 price0Cumulative;
    uint256 price1Cumulative;
}
```

