// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import {Test, console2} from 'forge-std/Test.sol';
import 'contracts/ProphetRouterV1.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

contract ProphetRouterTest is Test {
    event ProphetFee(uint256 amount, address indexed to);
    ProphetRouterV1 public prophetRouter;

    // User Addresses
    address public alice = makeAddr('alice');
    address public bob = makeAddr('bob');
    address public owner = makeAddr('owner');

    // Token Addresses
    address public usdcToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // ERC20 stable coin
    address public usdtToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // ERC20 stable coin
    address public wbtcToken = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; // ERC20 token with 8 decimals
    address public linkToken = 0x514910771AF9Ca656af840dff83E8264EcF986CA; // ERC677 Token
    address public paxgToken = 0x45804880De22913dAFE09f4980848ECE6EcbAf78; // Fee-on-Transfer ERC20 token
    address public mdtToken = 0xF97F0c51cE6c62A6AcC6431cF69C6b535e2440E4; // ERC20 with Fixed Max buy per tx

    // Whale Addresses
    address public usdcWhale = 0xA83DCc0B6aF233E677c0Ae8d8411E60eaE14d409;
    address public usdtWhale = 0x650296c3d2FF17b6aC810d47cf7c307e98041aE7;
    address public wbtcWhale = 0x176c65F8806D10946BC6e0B8c6C31B5bEFF4f740;
    address public linkWhale = 0x3965AA8F47615650872748bC0ec840df7BfCF292;
    address public paxgWhale = 0x2EAEd2891349F6448848a36bCa86Da0ae3e3670F;

    function setUp() public {
        vm.createSelectFork('https://rpc.ankr.com/eth', 18797800);

        vm.prank(owner);
        prophetRouter = new ProphetRouterV1();
        vm.deal(alice, 1000 ether);
        vm.deal(bob, 1000 ether);
    }

    // MAIN: Buy Functions
    function test_ProphetBuy() public {
        //## USDC token
        vm.prank(alice);
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdcToken, alice, block.timestamp, 1000);
        uint256 balanceOfUsdc = IERC20(usdcToken).balanceOf(alice);
        assertFalse(balanceOfUsdc == 0);

        //## USDT token
        vm.prank(bob);
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdtToken, bob, block.timestamp, 1000);
        uint256 balanceOfUsdt = IERC20(usdtToken).balanceOf(bob);
        assertFalse(balanceOfUsdt == 0);

        //## WBTC token
        vm.prank(alice);
        prophetRouter.ProphetBuy{value: 200 ether}(7.5 * 10 ** 8, wbtcToken, alice, block.timestamp, 1000);
        uint256 balanceOfWbtc = IERC20(wbtcToken).balanceOf(alice);
        assertFalse(balanceOfWbtc == 0);

        //## LINK token
        vm.prank(bob);
        prophetRouter.ProphetBuy{value: 200 ether}(20000 ether, linkToken, bob, block.timestamp, 1000);
        uint256 balanceOfLINK = IERC20(linkToken).balanceOf(bob);
        assertFalse(balanceOfLINK == 0);

        //## PAXG token
        vm.prank(alice);
        prophetRouter.ProphetBuy{value: 200 ether}(180 ether, paxgToken, alice, block.timestamp, 1000);
        uint256 balanceOfPAXG = IERC20(paxgToken).balanceOf(alice);
        assertFalse(balanceOfPAXG == 0);
    }

    function test_ProphetBuy_deadlineTest() public {
        //## USDC token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdcToken, alice, block.timestamp - 1, 1000);

        //## USDT token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdtToken, alice, block.timestamp - 1, 1000);

        //## WBTC token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, wbtcToken, alice, block.timestamp - 1, 1000);

        //## LINK token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, linkToken, alice, block.timestamp - 1, 1000);

        //## PAXG token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetBuy{value: 200 ether}(180 ether, paxgToken, alice, block.timestamp - 1, 1000);
    }

    function test_ProphetBuy_slippageTest() public {
        //## USDC token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 100 ether}(300000 * 10 ** 6, usdcToken, alice, block.timestamp, 1000);
        uint256 balanceOfUsdc = IERC20(usdcToken).balanceOf(alice);
        assertTrue(balanceOfUsdc == 0);

        //## USDT token
        vm.prank(bob);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 100 ether}(250000 * 10 ** 6, usdtToken, alice, block.timestamp, 1000);
        uint256 balanceOfUsdt = IERC20(usdtToken).balanceOf(bob);
        assertTrue(balanceOfUsdt == 0);

        //## WBTC token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 100 ether}(6 * 10 ** 8, wbtcToken, alice, block.timestamp, 1000);
        uint256 balanceOfWbtc = IERC20(wbtcToken).balanceOf(alice);
        assertTrue(balanceOfWbtc == 0);

        //## LINK token
        vm.prank(bob);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 100 ether}(16000 ether, linkToken, alice, block.timestamp, 1000);
        uint256 balanceOfLINK = IERC20(linkToken).balanceOf(bob);
        assertTrue(balanceOfLINK == 0);

        //## PAXG token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetBuy{value: 200 ether}(200 ether, paxgToken, alice, block.timestamp, 1000);
        uint256 balanceOfPAXG = IERC20(paxgToken).balanceOf(alice);
        assertTrue(balanceOfPAXG == 0);
    }

    function test_ProphetBuy_sanityChecks() public {
        //When msg.value == 0
        vm.prank(alice);
        vm.expectRevert('PropherRouter: INVALID_FEE_AMOUNT');
        prophetRouter.ProphetBuy{value: 0}(40000 * 10 ** 6, usdtToken, alice, block.timestamp, 1000);

        //When tokenAddress == address(0)
        vm.prank(bob);
        vm.expectRevert('UniswapV2Library: ZERO_ADDRESS');
        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, address(0), alice, block.timestamp, 1000);
    }

    // MAIN: Sell Functions
    function test_ProphetSell() public {
        vm.startPrank(usdcWhale);
        //## USDC token
        uint256 ethBalanceBefore = address(usdcWhale).balance;
        IERC20(usdcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, usdcToken, block.timestamp, 1000);
        assertGt(address(usdcWhale).balance, ethBalanceBefore + (0.75 ether * 0.9));
        vm.stopPrank();

        //## USDT token
        vm.startPrank(usdtWhale);
        ethBalanceBefore = address(usdtWhale).balance;
        TransferHelper.safeApprove(usdtToken, address(prophetRouter), 5000 * 10 ** 6);
        prophetRouter.ProphetSell(5000 * 10 ** 6, 2 ether, usdtToken, block.timestamp, 1000);
        assertGt(address(usdtWhale).balance, ethBalanceBefore + (2 ether * 0.9));
        vm.stopPrank();

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

        //## PAXG token
        vm.startPrank(paxgWhale);
        ethBalanceBefore = address(paxgWhale).balance;
        IERC20(paxgToken).approve(address(prophetRouter), 100 ether);
        prophetRouter.ProphetSell(100 ether, 75 ether, paxgToken, block.timestamp, 1000);
        assertGt(address(paxgWhale).balance, ethBalanceBefore + (75 ether * 0.9));
        vm.stopPrank();
    }

    function test_ProphetSell_deadline() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        IERC20(usdcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, usdcToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        // //## USDT token
        vm.startPrank(usdtWhale);
        TransferHelper.safeApprove(usdtToken, address(prophetRouter), 5000 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, usdtToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        IERC20(wbtcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, wbtcToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        IERC20(linkToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, linkToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## PAXG token
        vm.startPrank(paxgWhale);
        IERC20(paxgToken).approve(address(prophetRouter), 100 ether);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSell(100 ether, 75 ether, paxgToken, block.timestamp - 1, 1000);
        vm.stopPrank();
    }

    function test_ProphetSell_slippageTest() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        uint256 ethBalanceBefore = address(usdcWhale).balance;
        IERC20(usdcToken).approve(address(prophetRouter), 2000 * 10 ** 6);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 1 ether, usdcToken, block.timestamp, 1000);
        vm.stopPrank();

        //## USDT token
        vm.startPrank(usdtWhale);
        ethBalanceBefore = address(usdtWhale).balance;
        TransferHelper.safeApprove(usdtToken, address(prophetRouter), 5000 * 10 ** 6);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetSell(5000 * 10 ** 6, 3 ether, usdtToken, block.timestamp, 1000);
        vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        ethBalanceBefore = address(wbtcWhale).balance;
        IERC20(wbtcToken).approve(address(prophetRouter), 6 * 10 ** 8);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetSell(6 * 10 ** 8, 200 ether, wbtcToken, block.timestamp, 1000);
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        ethBalanceBefore = address(usdcWhale).balance;
        IERC20(linkToken).approve(address(prophetRouter), 12500 ether);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetSell(12500 ether, 95 ether, linkToken, block.timestamp, 1000);
        vm.stopPrank();

        //## PAXG token
        vm.startPrank(paxgWhale);
        ethBalanceBefore = address(paxgWhale).balance;
        IERC20(paxgToken).approve(address(prophetRouter), 100 ether);
        vm.expectRevert('PropherRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        prophetRouter.ProphetSell(100 ether, 99 ether, paxgToken, block.timestamp, 1000);
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

    // MAIN: SmartSell Functions
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

        //@audit-ok -> ProphetSmartSell not supported for Fee-On-Transfer Tokens, ERROR == [FAIL. Reason: revert: UniswapV2: K] test_ProphetSmartSell() (gas: 615414)
        //## PAXG token
        vm.startPrank(paxgWhale);
        ethBalanceBefore = address(paxgWhale).balance;
        IERC20(paxgToken).approve(address(prophetRouter), 15 ether);
        prophetRouter.ProphetSmartSell(10 ether, 15 ether, paxgToken, block.timestamp, 1000);
        assertGt(address(paxgWhale).balance, ethBalanceBefore + (10 ether * 0.9));
        vm.stopPrank();
    }

    function test_ProphetSmartSell_deadline() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        IERC20(usdcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSmartSell(2000 * 10 ** 6, 0.75 ether, usdcToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        // //## USDT token
        vm.startPrank(usdtWhale);
        TransferHelper.safeApprove(usdtToken, address(prophetRouter), 5000 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSell(2000 * 10 ** 6, 0.75 ether, usdtToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## WBTC token
        vm.startPrank(wbtcWhale);
        IERC20(wbtcToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSmartSell(2000 * 10 ** 6, 0.75 ether, wbtcToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## LINK token
        vm.startPrank(linkWhale);
        IERC20(linkToken).approve(address(prophetRouter), 2500 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSmartSell(2000 * 10 ** 6, 0.75 ether, linkToken, block.timestamp - 1, 1000);
        vm.stopPrank();

        //## PAXG token
        vm.startPrank(paxgWhale);
        IERC20(paxgToken).approve(address(prophetRouter), 15 ether);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetSmartSell(10 ether, 15 ether, paxgToken, block.timestamp - 1, 1000);
        vm.stopPrank();
    }

    function test_ProphetSmartSell_slippage() public {
        //## USDC token
        vm.startPrank(usdcWhale);
        uint256 ethBalanceBefore = address(usdcWhale).balance;
        IERC20(usdcToken).approve(address(prophetRouter), 600 * 10 ** 6);
        vm.expectRevert('PropherRouter: EXCESSIVE_INPUT_AMOUNT');
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
        vm.expectRevert('PropherRouter: EXCESSIVE_INPUT_AMOUNT');
        prophetRouter.ProphetSmartSell(69 ether, 10000 ether, linkToken, block.timestamp, 1000);
        vm.stopPrank();

        //## PAXG token
        vm.startPrank(paxgWhale);
        ethBalanceBefore = address(paxgWhale).balance;
        IERC20(paxgToken).approve(address(prophetRouter), 15 ether);
        vm.expectRevert('PropherRouter: EXCESSIVE_INPUT_AMOUNT');
        prophetRouter.ProphetSmartSell(10 ether, 10 ether, paxgToken, block.timestamp, 1000);
        vm.stopPrank();
    }

    // MAIN: MaxBuy Functions
    function test_ProphetMaxBuy() public {
        //## MDT token
        vm.prank(alice);
        prophetRouter.ProphetMaxBuy{value: 0.05 ether}(1 ether, mdtToken, alice, block.timestamp, 1000);
        uint256 balanceOfMDT = IERC20(mdtToken).balanceOf(address(alice));
        assertFalse(balanceOfMDT == 0);

        vm.rollFork(block.number + 10); // mine 10 blocks

        vm.prank(bob);
        vm.deal(bob, 1 ether);
        prophetRouter.ProphetMaxBuy{value: 0.1 ether}(1 ether, mdtToken, bob, block.timestamp, 1000);
        uint256 balanceOfMDTOne = IERC20(mdtToken).balanceOf(address(alice));
        assertFalse(balanceOfMDTOne == 0);
    }

    function test_ProphetMaxBuy_deadline() public {
        //## MDT token
        vm.prank(alice);
        vm.expectRevert('PropherRouter: EXPIRED');
        prophetRouter.ProphetMaxBuy{value: 0.05 ether}(1 ether, mdtToken, alice, block.timestamp - 1, 1000);
    }

    // function test_ProphetMaxBuy_slippageTest() public {
    //     //## MDT token
    //     vm.prank(alice);
    //     console2.log("alice ETH: before", address(alice).balance);
    //     prophetRouter.ProphetMaxBuy{value: 0.01 ether}(7599999 ether, mdtToken, alice, block.timestamp, 1000);
    //     console2.log("alice ETH: after", address(alice).balance);
    // }

    // MAIN: Other Functions
    function test_transferOwnership() public {
        //transferOwnership passes
        address newOwner = makeAddr('newOwner');
        vm.prank(prophetRouter.owner());
        prophetRouter.transferOwnership(newOwner);
        assertEq(prophetRouter.owner(), newOwner);

        //transferOwnership fails due to unauthorized user calling
        vm.prank(alice);
        vm.expectRevert('PropherRouter: NOT OWNER');
        prophetRouter.transferOwnership(newOwner);
    }

    function test_FeeAfterSwap() public {
        vm.prank(alice);
        prophetRouter.ProphetBuy{value: 100 ether}(44000 * 10 ** 6, usdcToken, alice, block.timestamp, 400);
        assertFalse(prophetRouter.getContractBalance() == 0);
        assertEq(address(prophetRouter).balance, 4 ether);

        vm.prank(bob);
        prophetRouter.ProphetBuy{value: 60 ether}(44000 * 10 ** 6, usdcToken, alice, block.timestamp, 1000);
        assertEq(address(prophetRouter).balance, 10 ether);
    }

    function test_Withdrawal() public {
        test_FeeAfterSwap();
        assertFalse(prophetRouter.getContractBalance() == 0);
        uint totalFee = prophetRouter.getContractBalance();

        vm.prank(owner);
        prophetRouter.withdrawETH();
        assertEq(address(owner).balance, totalFee);
    }

    function test_Withdrawal_sanityChecks() public {
        vm.prank(bob);
        vm.expectRevert('PropherRouter: NOT OWNER');
        prophetRouter.withdrawETH();
    }

    function testMyFunctionEmitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(false, true, false, false);

        emit ProphetFee(1000, alice);

        prophetRouter.ProphetBuy{value: 200 ether}(40000 * 10 ** 6, usdcToken, alice, block.timestamp, 1000);
        uint256 balanceOfUsdc = IERC20(usdcToken).balanceOf(alice);
        assertFalse(balanceOfUsdc == 0);
    }
}
