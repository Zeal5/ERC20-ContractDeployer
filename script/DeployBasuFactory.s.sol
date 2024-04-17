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

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DeployBasuFactory is Script {
    BasuToken token;
    IUniswapV2Router02 uniRouter;
    IUniswapV2Factory uniFactory;
    // IUniswapV2Pair tokenPair;
    IWETH9 weth;
    address pairAddress;

    // Private key
    // uint256 private_key = vm.envUint("deployer");
    // address deployer = vm.addr(private_key);
    uint256 private_key;
    address uniSwapRouterAddress = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address deployer;

    function setUp() external {
        console.log("msg sender is", msg.sender);
				uniRouter = IUniswapV2Router02(uniSwapRouterAddress);
				uniFactory= IUniswapV2Factory(uniRouter.factory());
    }

    function deployBasuFactory() internal {
        vm.startBroadcast();
        BasuFactory tokenFactory = new BasuFactory(uniSwapRouterAddress);
        console.log("factory deployed   ", address(tokenFactory));
				log_state();
     }
		 		
    function log_state() internal view {
        console.log("uniswap router address ", address(uniRouter));
        console.log("uniswap factory addr   ", address(uniFactory));
    }
				
    function run() public {
        deployBasuFactory();
    }
}









