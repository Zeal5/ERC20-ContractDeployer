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
import { UNCX } from "../src/interfaces/UNCX.sol";

contract ERC20Script is Script {
    // ERC20 args
    uint256 initialSupply = 1_000_000 * 10 ** 18;
    string _name = "BasuToken";
    string _symbol = "BSU";
    uint32 buyTaxPercentage = 2;
    uint32 sellTaxPercentage = 8;
    uint32 owner_tax_share = 80; // @Dev % share of ownerPool
    address basuFunds = 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f;
    address ownerFunds = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    BasuToken token;
    BasuFactory tokenFactory;
    IUniswapV2Router02 uniRouter;
    IUniswapV2Factory uniFactory;
    IUniswapV2Pair tokenPair;
    IWETH9 weth;
    address pairAddress;

    address uniSwapRouterAddress = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

    function setUp() external {
        console.log("Starting ...");
        uniRouter = IUniswapV2Router02(uniSwapRouterAddress);
        uniFactory = IUniswapV2Factory(uniRouter.factory());
    }

    function deployBasuToken() internal {
        vm.startBroadcast();
        tokenFactory = new BasuFactory(uniSwapRouterAddress);
        token = tokenFactory.DeployToken(
            initialSupply,
            _name,
            _symbol,
            buyTaxPercentage,
            sellTaxPercentage,
            owner_tax_share,
            ownerFunds,
            basuFunds
        );
        pairAddress = uniFactory.getPair(address(token), uniRouter.WETH());
        tokenPair = IUniswapV2Pair(pairAddress);
        weth = IWETH9(payable(uniRouter.WETH()));
    }

    function log_state() internal view {
        console.log("Basu Token Factory     ", address(tokenFactory));
        console.log("Basu Token address     ", address(token));
        console.log("token pair address     ", address(tokenPair));
        console.log("msg sender is          ", msg.sender);
        console.log("Router address         ", address(uniRouter));
        console.log("uniSwap Factory address", address(uniFactory));
				uint _bal = tokenPair.balanceOf(address(tokenFactory));
				console.log("balance of factory ", _bal);
    }

    function addLiquidity() internal {
        tokenFactory.addLiquidity{ value: 5 ether }(address(token));
    }

    function lock_liq() internal {
        uint256 ba = tokenPair.balanceOf(address(tokenFactory));
        console.log("Factory balance before token lock", ba);

        tokenFactory.lock_lp{ value: 0.03 ether }(
            address(tokenPair),
            tokenPair.balanceOf(address(tokenFactory)),
            1713294849 + 10000,
            payable(address(tokenFactory)),
            true,
            payable(address(msg.sender)),
						90
        );
        uint256 am = tokenPair.balanceOf(address(tokenFactory));
        console.log("Factory balance after token lock", am);
    }

    function run() public {
        // deploy token and create Pair
        deployBasuToken();
        // add liquidity token tokenWETH pair
        addLiquidity();
        // lock liq
        // lock_liq();
        log_state();
    }
}
