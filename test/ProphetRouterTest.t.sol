// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import {Test, console2} from 'forge-std/Test.sol';
import 'contracts/UniswapV2Router02.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

contract ProphetRouterTest is Test {
    UniswapV2Router02 public prophetRouter;

    //User Addresses
    address public alice = makeAddr('alice');
    address public bob = makeAddr('bob');
    address public owner = makeAddr('owner');

    address public usdcToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public usdtToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public wbtcToken = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public linkToken = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address public paxgToken = 0x45804880De22913dAFE09f4980848ECE6EcbAf78; //@audit - lee add the tests

    address public usdcWhale = 0xA83DCc0B6aF233E677c0Ae8d8411E60eaE14d409;
    address public usdtWhale = 0x650296c3d2FF17b6aC810d47cf7c307e98041aE7;
    address public wbtcWhale = 0x176c65F8806D10946BC6e0B8c6C31B5bEFF4f740;
    address public linkWhale = 0x3965AA8F47615650872748bC0ec840df7BfCF292;

    function setUp() public {
        vm.createSelectFork('https://rpc.ankr.com/eth', 18797800);

        vm.prank(owner);
        prophetRouter = new UniswapV2Router02();
        vm.deal(alice, 1000 ether);
        vm.deal(bob, 1000 ether);
    }

    function test_sampleTest() public {
        console2.log(address(prophetRouter));
        console2.log(prophetRouter.owner());
        assertEq(prophetRouter.owner(), owner);
    }

    function test_ProphetBuy() public {
        //## USDC token
        vm.prank(alice);
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdcToken, block.timestamp, 1000);
        uint256 balanceOfUsdc = IERC20(usdcToken).balanceOf(alice);
        assertFalse(balanceOfUsdc == 0);

        //## USDT token
        vm.prank(bob);
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdtToken, block.timestamp, 1000);
        uint256 balanceOfUsdt = IERC20(usdtToken).balanceOf(bob);
        assertFalse(balanceOfUsdt == 0);

        //## WBTC token
        vm.prank(alice);
        prophetRouter.ProphetBuy{value: 200 ether}(7.5 * 10 ** 8, wbtcToken, block.timestamp, 1000);
        uint256 balanceOfWbtc = IERC20(wbtcToken).balanceOf(alice);
        assertFalse(balanceOfWbtc == 0);

        //## LINK token
        vm.prank(bob);
        prophetRouter.ProphetBuy{value: 200 ether}(20000 ether, linkToken, block.timestamp, 1000);
        uint256 balanceOfLINK = IERC20(linkToken).balanceOf(bob);
        assertFalse(balanceOfLINK == 0);
    }

    function test_ProphetBuy_deadlineTest() public {
        //## USDC token
        vm.prank(alice);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdcToken, block.timestamp - 1, 1000);

        //## USDT token
        vm.prank(alice);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdtToken, block.timestamp - 1, 1000);

        //## WBTC token
        vm.prank(alice);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, wbtcToken, block.timestamp - 1, 1000);

        //## LINK token
        vm.prank(alice);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, linkToken, block.timestamp - 1, 1000);
    }

    function test_ProphetBuy_slippageTest() public {
        //## USDC token
        vm.prank(alice);
        vm.expectRevert('UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 100 ether}(300000 * 10 ** 6, usdcToken, block.timestamp, 1000);
        uint256 balanceOfUsdc = IERC20(usdcToken).balanceOf(alice);
        assertTrue(balanceOfUsdc == 0);

        //## USDT token
        vm.prank(bob);
        vm.expectRevert('UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 100 ether}(250000 * 10 ** 6, usdtToken, block.timestamp, 1000);
        uint256 balanceOfUsdt = IERC20(usdtToken).balanceOf(bob);
        assertTrue(balanceOfUsdt == 0);

        //## WBTC token
        vm.prank(alice);
        vm.expectRevert('UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 100 ether}(6 * 10 ** 8, wbtcToken, block.timestamp, 1000);
        uint256 balanceOfWbtc = IERC20(wbtcToken).balanceOf(alice);
        assertTrue(balanceOfWbtc == 0);

        //## LINK token
        vm.prank(bob);
        vm.expectRevert('UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 100 ether}(16000 ether, linkToken, block.timestamp, 1000);
        uint256 balanceOfLINK = IERC20(linkToken).balanceOf(bob);
        assertTrue(balanceOfLINK == 0);
    }

    function test_ProphetBuy_sanityChecks() public {
        //When msg.value == 0
        vm.prank(alice);
        vm.expectRevert('UniswapV2Router: INVALID_FEE_AMOUNT');
        prophetRouter.ProphetBuy{value: 0}(40000 * 10 ** 6, usdtToken, block.timestamp, 1000);

        //When tokenAddress == address(0)
        vm.prank(bob);
        vm.expectRevert('UniswapV2Library: ZERO_ADDRESS');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, address(0), block.timestamp, 1000);
    }

    function test_ProphetSell() public {
        vm.startPrank(usdcWhale);
        //## USDC token
        uint256 ethBalanceBefore = address(usdcWhale).balance;
        IERC20(usdcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, usdcToken, block.timestamp, 1000);
        assertGt(address(usdcWhale).balance, ethBalanceBefore + (0.75 ether * 0.9));
        vm.stopPrank();

        // //## USDT token
        // vm.startPrank(usdtWhale);
        // ethBalanceBefore = address(usdtWhale).balance;
        // TransferHelper.safeApprove(usdtToken, address(prophetRouter), 5000 * 10 ** 6);
        // prophetRouter.ProphetSell(5000 * 10 ** 6, 2 ether, usdtToken, block.timestamp, 1000);
        // assertGt(address(usdtWhale).balance, ethBalanceBefore + (2 ether * 0.9));
        // vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        ethBalanceBefore = address(wbtcWhale).balance;
        IERC20(wbtcToken).approve(address(prophetRouter), 6 * 10 ** 8);
        prophetRouter.ProphetSell(6 * 10 ** 8, 100 ether, wbtcToken, block.timestamp, 1000);
        assertGt(address(wbtcWhale).balance, ethBalanceBefore + (100 ether * 0.9));
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        ethBalanceBefore = address(linkWhale).balance;
        IERC20(linkToken).approve(address(prophetRouter), 12500 ether);
        prophetRouter.ProphetSell(12500 ether, 70 ether, linkToken, block.timestamp, 1000);
        assertGt(address(linkWhale).balance, ethBalanceBefore + (70 ether * 0.9));
        vm.stopPrank();
    }

    function test_ProphetSell_deadline() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        IERC20(usdcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, usdcToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        // //## USDT token
        vm.startPrank(usdtWhale);
        TransferHelper.safeApprove(usdtToken, address(prophetRouter), 5000 * 10 ** 6);
        vm.expectRevert("UniswapV2Router: EXPIRED");
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, usdtToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        IERC20(wbtcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, wbtcToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        IERC20(linkToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, linkToken, block.timestamp - 1, 1000);
        vm.stopPrank();
    }

    function test_ProphetSell_slippageTest() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        uint256 ethBalanceBefore = address(usdcWhale).balance;
        IERC20(usdcToken).approve(address(prophetRouter), 2000 * 10 ** 6);
        vm.expectRevert('UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 1 ether, usdcToken, block.timestamp, 1000);
        vm.stopPrank();

        //## USDT token
        vm.startPrank(usdtWhale);
        ethBalanceBefore = address(usdtWhale).balance;
        TransferHelper.safeApprove(usdtToken, address(prophetRouter), 5000 * 10 ** 6);
        vm.expectRevert("UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT");
        prophetRouter.ProphetSell(5000 * 10 ** 6, 3 ether, usdtToken, block.timestamp, 1000 );
        vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        ethBalanceBefore = address(wbtcWhale).balance;
        IERC20(wbtcToken).approve(address(prophetRouter), 6 * 10 ** 8);
        vm.expectRevert('UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetSell(6 * 10 ** 8, 200 ether, wbtcToken, block.timestamp, 1000);
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        ethBalanceBefore = address(usdcWhale).balance;
        IERC20(linkToken).approve(address(prophetRouter), 12500 ether);
        vm.expectRevert('UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetSell(12500 ether, 95 ether, linkToken, block.timestamp, 1000);
        vm.stopPrank();
    }

    function test_ProphetSell_sanityChecks() public {
        //When amountIn == 0
        vm.prank(usdcWhale);
        vm.expectRevert('UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        prophetRouter.ProphetSell(0, 1 ether, usdcToken, block.timestamp, 1000);

        //When tokenAddress == address(0)
        vm.prank(usdcWhale);
        vm.expectRevert('UniswapV2Library: ZERO_ADDRESS');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 1 ether, address(0), block.timestamp, 1000);
    }

    function test_ProphetSmartSell() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        uint256 ethBalanceBefore = address(usdcWhale).balance;
        IERC20(usdcToken).approve(address(prophetRouter), 2000 * 10 ** 6);
        prophetRouter.ProphetSmartSell(0.25 ether, 2000 * 10 ** 6, usdcToken, block.timestamp, 1000);
        assertGt(address(usdcWhale).balance, ethBalanceBefore + (0.25 ether * 0.9));
        vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        ethBalanceBefore = address(usdcWhale).balance;
        IERC20(wbtcToken).approve(address(prophetRouter), 6 * 10 ** 8);
        prophetRouter.ProphetSmartSell(6 * 10 ** 8, 100 ether, wbtcToken, block.timestamp, 1000);
        assertGt(address(wbtcWhale).balance, ethBalanceBefore + (100 ether * 0.9));
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        ethBalanceBefore = address(usdcWhale).balance;
        IERC20(linkToken).approve(address(prophetRouter), 15000 ether);
        prophetRouter.ProphetSmartSell(69 ether, 15000 ether, linkToken, block.timestamp, 1000);
        assertGt(address(linkWhale).balance, ethBalanceBefore + (69 ether * 0.9));
        vm.stopPrank();
    }

    function test_ProphetSmartSell_deadline() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        IERC20(usdcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetSmartSell(2000 * 10 ** 6, 0.75 ether, usdcToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        // //## USDT token
        vm.startPrank(usdtWhale);
        TransferHelper.safeApprove(usdtToken, address(prophetRouter), 5000 * 10 ** 6);
        vm.expectRevert("UniswapV2Router: EXPIRED");
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, usdtToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        IERC20(wbtcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetSmartSell(2000 * 10 ** 6, 0.75 ether, wbtcToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        IERC20(linkToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('UniswapV2Router: EXPIRED');
        prophetRouter.ProphetSmartSell(2000 * 10 ** 6, 0.75 ether, linkToken, block.timestamp - 1, 1000);
        vm.stopPrank();
    }

    function test_ProphetSmartSell_slippage() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        uint256 ethBalanceBefore = address(usdcWhale).balance;
        IERC20(usdcToken).approve(address(prophetRouter), 600 * 10 ** 6);
        vm.expectRevert('UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        prophetRouter.ProphetSmartSell(0.25 ether, 500 * 10 ** 6, usdcToken, block.timestamp, 1000);
        vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        ethBalanceBefore = address(usdcWhale).balance;
        IERC20(wbtcToken).approve(address(prophetRouter), 6 * 10 ** 8);
        prophetRouter.ProphetSmartSell(6 * 10 ** 8, 100 ether, wbtcToken, block.timestamp, 1000);
        assertGt(address(wbtcWhale).balance, ethBalanceBefore + (100 ether * 0.9));
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        ethBalanceBefore = address(linkWhale).balance;
        IERC20(linkToken).approve(address(prophetRouter), 12500 ether);
        vm.expectRevert('UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        prophetRouter.ProphetSmartSell(69 ether, 10000 ether, linkToken, block.timestamp, 1000);
        vm.stopPrank();
    }

    function test_FeeAfterSwap() public {
        vm.prank(alice);
        prophetRouter.ProphetBuy{value: 100 ether}(44000 * 10 ** 6, usdcToken, block.timestamp, 400);
        assertFalse(prophetRouter.totalFeeCollected() == 0);
        assertEq(address(prophetRouter).balance, 4 ether);

        vm.prank(bob);
        prophetRouter.ProphetBuy{value: 60 ether}(44000 * 10 ** 6, usdcToken, block.timestamp, 1000);
        assertEq(address(prophetRouter).balance, 10 ether);
    }

    function test_Withdrawal() public {
        test_FeeAfterSwap();
        assertFalse(prophetRouter.totalFeeCollected() == 0);
        uint totalFee = prophetRouter.totalFeeCollected();

        vm.prank(owner);
        prophetRouter.withdrawETH();
        assertEq(address(owner).balance, totalFee);
    }

    // function test_WithFeeOnTransfer() public {
    //     vm.prank(alice);
    //     // Using USDT on mainnet as its fee on transfer
    //     prophetRouter.ProphetBuy{value: 100 ether}(1, usdtToken, block.timestamp, 400);
    //     assertFalse(prophetRouter.totalFeeCollected() == 0);
    //     assertEq(prophetRouter.totalFeeCollected(), 4 ether);
    //     console2.log(address(owner).balance);
    //     assertEq(address(owner).balance, 0);

    //     vm.prank(owner);
    //     uint totalFee = prophetRouter.totalFeeCollected();
    //     prophetRouter.withdrawETH();
    //     assertEq(address(owner).balance, totalFee);
    // }
}
