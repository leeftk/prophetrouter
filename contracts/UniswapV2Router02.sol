pragma solidity =0.6.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import './interfaces/IUniswapV2Router02.sol';
import './libraries/UniswapV2Library.sol';
import './libraries/SafeMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';

contract UniswapV2Router02 is IUniswapV2Router02 {
    event ProphetFee(uint256 feeAmount, address indexed user);
    event OwnershipChanged(address indexed newOwner);

    using SafeMath for uint;

    address public constant override factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant override WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint public totalFeeCollected;
    address public owner;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PropherRouter: EXPIRED');
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'PropherRouter: NOT OWNER');
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'PropherRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == WETH, 'PropherRouter: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline,
        uint fee
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == WETH, 'PropherRouter: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        uint amountOut = amounts[amounts.length - 1];
        uint256 feeAmount = (amountOut * fee) / 10_000;
        require(feeAmount > 0, 'PropherRouter: FEE_AMOUNT');
        require(amountOut - fee >= amountOutMin, 'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amountOut);
        uint outputAfterFee = amountOut - feeAmount;
        TransferHelper.safeTransferETH(to, outputAfterFee);
    }

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path[0] == WETH, 'PropherRouter: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'PropherRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = UniswapV2Library.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1, ) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    /**
     * @dev Swaps ERC20 tokens for a specific amount of ETH, supporting fee on transfer tokens.
     * @param amountIn The amount of input tokens to swap
     * @param amountOutMin The minimum amount of ETH to receive from the swap.
     * @param path An array of token addresses representing the swap path.
     * @param to The address to receive the swapped ETH.
     * @param deadline The deadline by which the swap must be executed.
     * @param feeAmount The fee amount to subtract from the total ETH before transferring to the recipient.
     *
     */
    function swapTokensSupportingFeeOnTransferTokensForExactETH(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline,
        uint feeAmount
    ) public ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));

        require(
            IERC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore) >= amountOutMin,
            'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        uint balanceAfter = IERC20(path[path.length - 1]).balanceOf(address(this));

        uint amountOut = balanceAfter - balanceBefore; //Amount of WETH after the swap
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut - feeAmount);
    }

    /// @notice Executes a buy operation with a fee, swapping ETH for tokens
    /// @dev This function includes a fee mechanism and supports fee-on-transfer tokens
    /// @param amountOutMin The minimum amount of output tokens to receive
    /// @param tokenAddress The address of the output token
    /// @param deadline The time by which the transaction must be confirmed
    /// @param fee The fee percentage for the operation
    function ProphetBuy(
        uint amountOutMin,
        address tokenAddress,
        uint deadline,
        uint fee
    ) external payable virtual override ensure(deadline) {
        address[] memory path = getPathForTokenToToken(true, tokenAddress);
        require(path[0] == WETH, 'PropherRouter: INVALID_PATH');
        uint256 feeAmount = (msg.value * fee) / 10_000;
        require(feeAmount > 0, 'PropherRouter: INVALID_FEE_AMOUNT');
        totalFeeCollected += feeAmount;

        uint256 amountIn = msg.value - feeAmount;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(tokenAddress).balanceOf(msg.sender);
        _swapSupportingFeeOnTransferTokens(path, msg.sender);
        require(
            IERC20(path[path.length - 1]).balanceOf(msg.sender).sub(balanceBefore) >= amountOutMin,
            'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        emit ProphetFee(feeAmount, msg.sender);
    }

    /// @notice Executes a sell operation with a fee, swapping tokens for ETH and supporting fee-on-transfer tokens
    /// @dev This function includes a fee mechanism and supports fee-on-transfer tokens
    /// @param amountIn The amount of input tokens to sell
    /// @param amountOutMin The minimum amount of ETH to receive
    /// @param tokenAddress The address of the input token
    /// @param deadline The time by which the transaction must be confirmed
    /// @param fee The fee percentage for the operation
    function ProphetSell(
        uint amountIn,
        uint amountOutMin,
        address tokenAddress,
        uint deadline,
        uint fee
    ) external virtual override ensure(deadline) {
        address[] memory path = getPathForTokenToToken(false, tokenAddress);
        require(path[path.length - 1] == WETH, 'PropherRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);

        // Calculate and collect the fee
        uint256 feeAmount = (amountOut * fee) / 10_000;
        require(feeAmount > 0, 'PropherRouter: INVALID_FEE_AMOUNT');
        totalFeeCollected += feeAmount;

        TransferHelper.safeTransferETH(msg.sender, amountOut - feeAmount);
        emit ProphetFee(feeAmount, msg.sender);
    }

    /// @notice Executes a smart sell operation with a fee, swapping tokens for ETH
    /// @dev This function includes a fee mechanism and uses internal swap functions
    /// @param amountOut The amount of ETH to receive from the swap
    /// @param amountInMax The maximum amount of input tokens to sell
    /// @param tokenAddress The address of the token to sell
    /// @param deadline The time by which the transaction must be confirmed
    /// @param fee The fee percentage for the operation
    function ProphetSmartSell(
        uint amountOut,
        uint amountInMax,
        address tokenAddress,
        uint256 deadline,
        uint fee
    ) public {
        uint256 feeAmount = (amountOut * fee) / 10_000;
        require(feeAmount > 0, 'PropherRouter: FEE_AMOUNT');
        totalFeeCollected += feeAmount;

        address[] memory path = getPathForTokenToToken(false, tokenAddress);
        require(path[path.length - 1] == WETH, 'PropherRouter: INVALID_PATH');
        //Gets the amount of tokenAddress required with "amountOut + feeAmount" amount of ETH
        uint[] memory amounts = UniswapV2Library.getAmountsIn(factory, amountOut + feeAmount, path);
        require(amounts[0] <= amountInMax, 'PropherRouter: EXCESSIVE_INPUT_AMOUNT');

        swapTokensSupportingFeeOnTransferTokensForExactETH(
            amounts[0], // Amount of tokenAddress
            amountOut, // Min Amount of WETH required
            path,
            msg.sender,
            deadline,
            feeAmount
        );
        emit ProphetFee(feeAmount, msg.sender);
    }

    /// @notice Allows the contract owner to withdraw tokens from the contract
    /// @param _token The token address to withdraw
    function withdraw(address _token) external onlyOwner {
        TransferHelper.safeTransfer(_token, owner, IERC20(_token).balanceOf(address(this)));
    }

    /// @notice Allows the contract owner to withdraw ETH from the contract
    function withdrawETH() external onlyOwner {
        totalFeeCollected = 0;
        TransferHelper.safeTransferETH(owner, address(this).balance);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure virtual override returns (uint amountOut) {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) public pure virtual override returns (uint amountIn) {
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) public view virtual override returns (uint[] memory amounts) {
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) public view virtual override returns (uint[] memory amounts) {
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }

    /// @notice Helper function to get the swap path for token to token or ETH to token swaps
    /// @param swapETH Indicates whether the swap involves ETH -> tokenAddr
    /// @param tokenAddr The address of the other token
    /// @return path The swap path as an array of addresses
    function getPathForTokenToToken(bool swapETH, address tokenAddr) private pure returns (address[] memory) {
        address[] memory path = new address[](2);
        if (swapETH) {
            path[0] = WETH;
            path[1] = tokenAddr;
        } else {
            path[0] = tokenAddr;
            path[1] = WETH;
        }
        return path;
    }

    /**
     * @notice Transfers ownership of the contract to a new address.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), 'PropherRouter: ZERO_ADDRESS');
        owner = newOwner;
        emit OwnershipChanged(owner);
    }
}
