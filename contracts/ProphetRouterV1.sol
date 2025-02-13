pragma solidity =0.6.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import './interfaces/IUniswapV2Router02.sol';
import './libraries/UniswapV2Library.sol';
import './libraries/SafeMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';

contract ProphetRouterV1 is IUniswapV2Router02 {
    event ProphetFee(uint256 feeAmount, address indexed user);
    event OwnershipChanged(address indexed newOwner);
    event OwnershipTransferStarted(address indexed Owner, address indexed newOwner);
    event tokenToEtherChanged(address indexed token, uint indexed value);
    event MaxRetryUpdated(uint newMaxRetry, address indexed updatedBy);
    event MaxBuyScaleUpdated(uint newMaxBuyScale, address indexed updatedBy);
    event MaxBuyEtherLimitUpdated(uint newMaxBuyEtherLimit, address indexed updatedBy);
    event ProphetFeeUpdated(uint newfee, address indexed updatedBy);

    using SafeMath for uint;

    address public constant override factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant override WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint public constant MAX_BIPS = 10_000;
    uint public constant FEE_MAX = 1000; // 10% fee

    address public owner;
    address private _pendingOwner;
    mapping(address => uint) public tokenToEther; //mapping to track the min Ether required for a token address

    uint public maxRetry = 10;
    uint public maxBuyScale = 6_900;
    uint public maxBuyEtherLimit = 0.5 ether; // should be set by owners during deployment

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

    // **** SWAP (supporting fee-on-transfer tokens) ****

    // Internal function for swapping tokens supporting fee-on-transfer tokens
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

    /**
     * @dev Swaps ERC20 tokens for a specific amount of ETH, supporting fee on transfer tokens.
     * @param amountIn The amount of input tokens to swap
     * @param amountOutMin The minimum amount of ETH to receive from the swap.
     * @param path An array of token addresses representing the swap path.
     * @param to The address to receive the swapped ETH.
     * @param deadline The deadline by which the swap must be executed.
     */
    function swapTokensSupportingFeeOnTransferTokensForExactETH(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline,
        uint feeAmount
    ) private ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint balanceOfWETHBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));

        uint balanceOfWETHAfter = IERC20(path[path.length - 1]).balanceOf(address(this));

        uint amountOut = SafeMath.sub(balanceOfWETHAfter, balanceOfWETHBefore); //The output amount of WETH after the swap

        require(amountOut >= amountOutMin, 'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');

        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, SafeMath.sub(amountOut, feeAmount));
    }

    /// @notice Executes a buy operation with a fee, swapping ETH for tokens
    /// @dev This function includes a fee mechanism and supports fee-on-transfer tokens
    /// @param amountOutMin The minimum amount of output tokens to receive
    /// @param tokenAddress The address of the output token
    /// @param deadline The time by which the transaction must be confirmed
    function ProphetBuy(
        uint amountOutMin,
        address tokenAddress,
        address to,
        uint deadline,
        uint fee
    )
        external
        payable
        virtual
        override
        ensure(deadline)
    {
        address[] memory path = getPathForTokenToToken(true, tokenAddress);
        require(fee <= FEE_MAX, 'PropherRouter: INVALID_FEE_AMOUNT');
        uint256 feeAmount = (msg.value * fee) / MAX_BIPS;        

        uint256 amountIn = SafeMath.sub(msg.value, feeAmount);
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(tokenAddress).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        emit ProphetFee(feeAmount, to);
    }

    /**
     * @notice Use the ProphetMaxBuy only when buying the tokens which have max buy limit per transaction
     * @dev Executes a ProphetMaxBuy transaction, swapping Ether for the specified token.
     * @param amountOutMin The minimum amount of the output token that must be received for the transaction not to revert.
     * @param tokenAddress The address of the token to be bought.
     * @param to The address that will receive the output tokens.
     * @param deadline The timestamp by which the transaction must be executed to prevent it from expiring.
     * @notice Ensure that the transaction is executed before the specified deadline.
     * @dev Refunds any unused Ether back to the sender in case of unsuccessful swaps.
     * @dev Handles multiple attempts to execute the ProphetBuy function in case of failure, with decreasing input Ether amounts.
     * @dev Updates the minimum Ether required for the specified token if the swap is successful.
     * @dev Emits a `tokenToEtherChanged` event on successful update.
     */
    function ProphetMaxBuy(
        uint amountOutMin,
        address tokenAddress,
        address to,
        uint deadline,
        uint fee
    )
        external
        payable
        ensure(deadline)
    {
        require(msg.value <= maxBuyEtherLimit, 'PropherRouter: EXCEEDED_ETHER_LIMIT');
        require(fee <= FEE_MAX, 'PropherRouter: INVALID_FEE_AMOUNT');
        uint amountIn = msg.value;
        bool isSwapComplete = false;

        if (tokenToEther[tokenAddress] == 0) {
            uint maxAttempts = maxRetry;
            while (isSwapComplete == false) {
                if (maxAttempts == 0) {
                    TransferHelper.safeTransferETH(to, msg.value); // adding this to refund the msg.value back to user in case of maxAttempts are over
                    break;
                }
                //fee calculation already handled as part of ProphetBuy()
                try this.ProphetBuy{value: amountIn}(amountOutMin, tokenAddress, to, deadline, fee){
                    isSwapComplete = true;
                    tokenToEther[tokenAddress] = amountIn;
                    uint amountOutETH = SafeMath.sub(msg.value, amountIn);
                    if (amountOutETH > 0) TransferHelper.safeTransferETH(to, amountOutETH); //refund the extra ether back to user
                } catch {
                    amountIn = (amountIn * maxBuyScale) / MAX_BIPS;
                    amountOutMin = (amountOutMin * maxBuyScale) / MAX_BIPS;
                    continue;
                }
                maxAttempts = maxAttempts - 1;
            }
        } else {
            // in case the tokenToEther for the current token is updated
            uint maxInputEtherAmount = tokenToEther[tokenAddress];
            if (msg.value > maxInputEtherAmount) {
                this.ProphetBuy{value: maxInputEtherAmount}(amountOutMin, tokenAddress, to, deadline, fee);
                TransferHelper.safeTransferETH(to, SafeMath.sub(msg.value, maxInputEtherAmount));
            } else if (msg.value <= maxInputEtherAmount) {
                this.ProphetBuy{value: msg.value}(amountOutMin, tokenAddress, to, deadline, fee);
            }
        }
    }

    /// @notice Executes a sell operation with a fee, swapping tokens for ETH and supporting fee-on-transfer tokens
    /// @dev This function includes a fee mechanism and supports fee-on-transfer tokens
    /// @param amountIn The amount of input tokens to sell
    /// @param amountOutMin The minimum amount of ETH to receive
    /// @param tokenAddress The address of the input token
    /// @param deadline The time by which the transaction must be confirmed
    function ProphetSell(
        uint amountIn,
        uint amountOutMin,
        address tokenAddress,
        uint deadline,
        uint fee
    )
        external
        virtual
        override
        ensure(deadline)
    {
        address[] memory path = getPathForTokenToToken(false, tokenAddress);

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
        require(fee <= FEE_MAX, 'PropherRouter: INVALID_FEE_AMOUNT');
        // Calculate and collect the fee
        uint256 feeAmount = (amountOut * fee) / MAX_BIPS;

        TransferHelper.safeTransferETH(msg.sender, SafeMath.sub(amountOut, feeAmount)); //amountOut - feeAmount
        emit ProphetFee(feeAmount, msg.sender);
    }

    /// @notice Executes a smart sell operation with a fee, swapping tokens for ETH
    /// @dev This function includes a fee mechanism and uses internal swap functions
    /// @param amountOut The amount of ETH to receive from the swap
    /// @param amountInMax The maximum amount of input tokens to sell
    /// @param tokenAddress The address of the token to sell
    /// @param deadline The time by which the transaction must be confirmed
    function ProphetSmartSell(
        uint amountOut,
        uint amountInMax,
        address tokenAddress,
        uint256 deadline,
        uint fee
    ) public {
        require(fee <= FEE_MAX, 'PropherRouter: INVALID_FEE_AMOUNT');
        uint256 feeAmount = (amountOut * fee) / MAX_BIPS;

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

    // **** MISC HELPER FUNCTIONS ****

    /**
     * @dev Gets the current balance of Ether held by the contract.
     * @return The current Ether balance of the contract.
     */
    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    /// @notice Allows the contract owner to withdraw tokens from the contract
    /// @param _token The token address to withdraw
    function withdraw(address _token) external onlyOwner {
        TransferHelper.safeTransfer(_token, owner, IERC20(_token).balanceOf(address(this)));
    }

    /// @notice Allows the contract owner to withdraw ETH from the contract
    function withdrawETH() external onlyOwner {
        TransferHelper.safeTransferETH(owner, address(this).balance);
    }

    /**
     * @dev Sets the minimum Ether required to buy a specific token address.
     * @param token The address of the token.
     * @param value The new minimum Ether required for the specified token.
     * @notice Only the owner can call this function.
     * @dev Emits a `tokenToEtherChanged` event on successful update.
     * @param token The address of the token.
     * @param value The new minimum Ether required for the specified token.
     */
    function setTokenToEther(address token, uint value) public onlyOwner {
        require(value > 0, 'PropherRouter: ZERO_VALUE');
        tokenToEther[token] = value;

        emit tokenToEtherChanged(token, value);
    }

    /// @notice Helper function to get the swap path for token to token or ETH to token swaps
    /// @param swapETH Indicates whether the swap involves ETH -> tokenAddr
    /// @param tokenAddr The address of the other token
    /// @return path The swap path as an array of addresses
    function getPathForTokenToToken(bool swapETH, address tokenAddr) public pure returns (address[] memory) {
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
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        require(pendingOwner() == msg.sender, 'PropherRouter: UNAUTHORIZED_CALLER');
        owner = pendingOwner();
        emit OwnershipChanged(owner);
    }

    /**
     * @dev Allows the owner to update the maxRetry variable.
     * @param newMaxRetry The new value for maxRetry.
     */
    function updateMaxRetry(uint newMaxRetry) external onlyOwner {
        maxRetry = newMaxRetry;
        emit MaxRetryUpdated(newMaxRetry, msg.sender);
    }

    /**
     * @dev Allows the owner to update the maxBuyScale variable.
     * @param newMaxBuyScale The new value for maxBuyScale.
     */
    function updateMaxBuyScale(uint newMaxBuyScale) external onlyOwner {
        maxBuyScale = newMaxBuyScale;
        emit MaxBuyScaleUpdated(newMaxBuyScale, msg.sender);
    }

    /**
     * @dev Sets the maximum buy ether limit.
     * @param newLimit The new maximum buy ether limit to be set.
     */
    function setMaxBuyEtherLimit(uint newLimit) external onlyOwner {
        maxBuyEtherLimit = newLimit;
        emit MaxBuyEtherLimitUpdated(newLimit, msg.sender);
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }
}
