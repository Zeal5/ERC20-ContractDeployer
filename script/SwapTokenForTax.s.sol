// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import { BasuFactory } from "../src/BasuFactory.sol";
import { BasuToken } from "../src/basuToken.sol";
import { Script, console } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "../src/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Router02 } from "../src/interfaces/IUniswapV2Router02.sol";
import { IWETH9 } from "../src/interfaces/IWETH9.sol";

contract ERC20Script is Script {
    BasuToken token;
    IUniswapV2Router02 uniRouter;
    IUniswapV2Factory uniFactory;
    IUniswapV2Pair tokenPair;
    IWETH9 weth;
    address pairAddress;
    address basu_address = 0x68B1D87F95878fE05B998F19b66F4baba5De1aed; //add addres here after deployment;

    address uniSwapRouterAddress = 0x6BDED42c6DA8FBf0d2bA55B2fa120C5e0c8D7891;

    address dev = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address user = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
    address basuFunds = 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f;
    address ownerFunds = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    function setUp() external {
        console.log("msg sender is", msg.sender);
        console.log("Starting ...");
        token = BasuToken(basu_address);
        uniRouter = IUniswapV2Router02(uniSwapRouterAddress);
        uniFactory = IUniswapV2Factory(uniRouter.factory());
        pairAddress = uniFactory.getPair(address(token), uniRouter.WETH());
        tokenPair = IUniswapV2Pair(pairAddress);
        weth = IWETH9(payable(uniRouter.WETH()));
    }

    function log_state() internal view {
        console.log("Dev token wallet balance :", token.balanceOf(dev));
        console.log("user token wallet balance :", token.balanceOf(user));
        console.log(
            "basuFunds token wallet balance :", token.balanceOf(basuFunds)
        );
        console.log(
            "ownerFunds token wallet balance :", token.balanceOf(ownerFunds)
        );
        console.log("-------------------------------------------------------");
    }

    function run() public {
        log_state();
        vm.startBroadcast();
        // buy_tokens(0.1 ether);
				increase_allowance(10_000 ether);
				sell_tokens(10_000 ether);
        log_state();
    }

    function buy_tokens(uint256 _amount_weth) internal {
        uint256[] memory _amount_out = new uint256[](2);
        _amount_out = get_amounts_out(_amount_weth);

        address[] memory path = new address[](2);
        path[0] = address(address(weth));
        path[1] = address(token);

        console.log("Buying");
        uniRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: 0.1 ether
        }(
           0,
            path,
            msg.sender,
            block.timestamp + 200
        );
    }

    function sell_tokens(uint256 _amount_tokens) internal {
        uint256[] memory _amount_out = new uint256[](2);
        _amount_out = get_amounts_out(_amount_tokens);

        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = address(address(weth));

        console.log("Buying");
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
           8_900 ether,
           0,
            path,
            msg.sender,
            block.timestamp + 200
        );
    }
    // used in buy tokens

    function get_amounts_out(uint256 _amnt)
        internal
        view
        returns (uint256[] memory)
    {
        address[] memory _path = new address[](2);
        // weth is at 0 index since getAmountsOut return how much of 2nd index
        // token we receive for 1st [1st IN, 2nd OUT]
        _path[0] = address(weth);
        _path[1] = address(token);
        uint256[] memory _amount_out = uniRouter.getAmountsOut(_amnt, _path);
        return _amount_out;
    }

    function increase_allowance(uint256 _amount) internal {
        weth.approve(address(uniRouter), _amount);
        token.approve(address(uniRouter), _amount);
        (uint256 w_a, uint256 t_a) = check_allowance();
        console.log("allowance for router", w_a);
        console.log("allowance for router", t_a);
    }

    function check_allowance() internal view returns (uint256, uint256) {
        uint256 w_a = weth.allowance(msg.sender, address(uniRouter));
        uint256 t_a = token.allowance(msg.sender, address(uniRouter));
        return (w_a, t_a);
    }
}
