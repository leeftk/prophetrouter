pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    // function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //     uint amountIn,
    //     uint amountOutMin,
    //     address[] calldata path,
    //     address to,
    //     uint deadline
    // ) external;

    function ProphetBuy(
        // swapExactETHForTokensSupportingFeeOnTransferTokens
        uint amountOutMin,
        //address[] calldata path,
        address tokenAddress,
        address to,
        uint deadline,
        uint fee
    ) external payable; //@audit-info - ProphetBuy

    function ProphetSell(
        //swapExactTokensForETHSupportingFeeOnTransferTokens
        uint amountIn,
        uint amountOutMin,
        address tokenAddress,
        //address[] calldata path,
        //address to,
        uint deadline,
        uint fee
    ) external; //@audit-info - ProphetSell
}
