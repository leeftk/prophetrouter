## ProphetSwap

**ProphetSwap is a router contract built to route all trade done through the bot and take a revshare fee that is withdrawable by the team**

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```
### Serve Docs

```shell
forge doc --build
forge doc --serve
```

# ProphetSwap
[Git Source](https://github.com/leeftk/prophetswap/blob/29a9e5ee69c3b763fb0bb320263e3e25a5e53d8d/src/ProphetSwap.sol)

**Inherits:**
Ownable2Step

This contract interacts with Uniswap V2 to facilitate token swaps and collects a fee on each transaction.


## State Variables
### totalFeeCollected

```solidity
uint256 public totalFeeCollected;
```


### UNISWAP_V2_ROUTER

```solidity
address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
```


### WETH

```solidity
address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
```


## Functions
### constructor


```solidity
constructor();
```

### ProphetBuy

Buys tokens on Uniswap V2 and collects a fee


```solidity
function ProphetBuy(uint256 amountOutMin, address tokenAddress, uint256 _fee) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amountOutMin`|`uint256`|Minimum amount of tokens to receive from the swap|
|`tokenAddress`|`address`|The address of the token to buy|
|`_fee`|`uint256`|The fee percentage to be collected|


### ProphetSell

Sells tokens on Uniswap V2 and collects a fee


```solidity
function ProphetSell(uint256 amountIn, uint256 amountOutMin, address tokenAddress, uint256 _fee) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amountIn`|`uint256`|Amount of tokens to sell|
|`amountOutMin`|`uint256`|Minimum amount of ETH to receive from the swap|
|`tokenAddress`|`address`|The address of the token to sell|
|`_fee`|`uint256`|The fee percentage to be collected|


### ProphetSmartSell

Sells tokens on Uniswap V2 for a specified amount of ETH, collects a fee


```solidity
function ProphetSmartSell(uint256 amountOut, uint256 amountInMax, address tokenAddress, uint256 _fee) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|The exact amount of ETH to receive from the swap|
|`amountInMax`|`uint256`|The maximum amount of tokens to sell|
|`tokenAddress`|`address`|The address of the token to sell|
|`_fee`|`uint256`|The fee percentage to be collected in BPS|


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
function withdrawETH() external;
```

### receive

Fallback function to receive ETH


```solidity
receive() external payable;
```

## Events
### ProphetFee
Event emitted after collecting a fee


```solidity
event ProphetFee(address indexed sender, uint256 amount);
```

## Errors
### InvalidAmount
*Custom Errors for the contract*


```solidity
error InvalidAmount();
```

### InvalidOutputAmount

```solidity
error InvalidOutputAmount();
```

### InvalidFeeAmount

```solidity
error InvalidFeeAmount();
```

### InvalidToken

```solidity
error InvalidToken();
```

### TransferFailed

```solidity
error TransferFailed();
```

## Security Risks

- Potential Issues with Using block.timestamp as the Deadline for AMM Swaps
- Centralizaiont risks if keys are compromised

## Deadline check

### Summary:

Frontrunning and Sandwich attacks a threat to the security of an AMMs. In the current implementation, the `block.timestamp` is used as the deadline parameter.

Since `block.timestamp` aligns with the current timestamp when included in a block by the miner, this opens an opportunity for miners game the system as the cost of a user. A malicious miner can withhold the transaction from being mined until it incurs the maximum slippage. Alternatively, they may exploit the transaction later to execute a sandwich attack.


Similar instances have been reported in auditing contests:

[Code 423n4 - 2022-11-paraspace-findings](https://github.com/code-423n4/2022-11-paraspace-findings/issues/429)

[Sherlock Audit - 2023-01-ajna-judging](https://github.com/sherlock-audit/2023-01-ajna-judging/issues/39)

### Recommendation:

It is advisable that the deadline parameter of `3600 + block.timestamp` be revised to deem if it is necessary or not. The deadline could be calculated on the frontend and sent to the contract as an argument. For example you can get the current time using the js `date()` method add 3600 to and it pass it as the `deadline` parameter. This way it cannot be manipulate by a miner. 

## Compromised Keys

### Summary:

Many core functions including `withdrawETH` and `withdrawTokens` withdraw all the funds from fees to a `revShare` address. If for whatever reason this address is compromised it could lead to loss of funds to the team. 

Currently there aren't many way to mitigate against this besides ensuring that this address is a multi sig. If one of the keys get compromised the funds will still be safe and retrievable by the owners.