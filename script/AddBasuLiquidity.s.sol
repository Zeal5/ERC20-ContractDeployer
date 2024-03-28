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
    address ownerIs = 0x976EA74026E726554dB657fA54763abd0C3a0aa9; // owner is the end user
    uint32 buyTaxPercentage = 3;
    uint32 sellTaxPercentage = 3;
    uint32 owner_tax_share = 50; // @Dev % share of ownerPool

    BasuToken token;
    IUniswapV2Router02 uniRouter;
    IUniswapV2Factory uniFactory;
    IUniswapV2Pair tokenPair;
    IWETH9 weth;
    address pairAddress;
    address basu_address = 0x68B1D87F95878fE05B998F19b66F4baba5De1aed; //add addres here after deployment;

    // Private key
    // uint256 private_key = vm.envUint("deployer");
    // address deployer = vm.addr(private_key);

    address uniSwapRouterAddress = 0x6BDED42c6DA8FBf0d2bA55B2fa120C5e0c8D7891;

    function setUp() external {
        console.log("msg sender is", msg.sender);
        console.log("Starting ...");
        token = BasuToken(basu_address);
        uniRouter = IUniswapV2Router02(uniSwapRouterAddress);
        uniFactory = IUniswapV2Factory(uniRouter.factory());
        pairAddress = uniFactory.getPair(address(token), uniRouter.WETH());
        tokenPair = IUniswapV2Pair(pairAddress);
        weth = IWETH9(payable(uniRouter.WETH()));
        log_state();
    }

    function log_state() internal view {
        console.log("uniswap router address ", address(uniRouter));
        console.log("Basu Token address     ", address(token));
        console.log("uniswap factory addr   ", address(uniFactory));
        console.log("token pair address     ", address(tokenPair));
        console.log("weth address           ", address(weth));
    }

    function run() public {
        vm.startBroadcast();
        create_uniswap_create_pool();
    }

    function create_uniswap_create_pool() public {
        // t0 is weth @Dev amount of tokens to add to pool
        uint256 weth_r = 0.5 ether;
        uint256 token_r = 100_000 ether;
        //get weth
        weth.deposit{ value: 7 ether }();
        // increase_allowance for router of token and weth
        increase_allowance(10_000_000 ether);
        // check reserves to make sure they are 0
        // (uint256 rb0, uint256 rb1) = check_reserves();
        // add liq
        console.log("Adding Liq");
        uniRouter.addLiquidity(
            address(token),
            uniRouter.WETH(),
            token_r,
            weth_r,
            token_r / 2,
            weth_r / 2,
            msg.sender,
            block.timestamp + 100
        );
        //check reserves to make sure they are not 0
        // (uint256 ra0, uint256 ra1) = check_reserves();
    }

    function increase_allowance(uint256 _amount) internal {
        weth.approve(address(uniRouter), _amount);
        token.approve(address(uniRouter), _amount);
        (uint256 w_a, uint256 t_a) = check_allowance();
        console.log("allowance for router", w_a);
        console.log("allowance for router", t_a);
    }

    function check_reserves() internal view returns (uint256, uint256) {
        // t0 is weth
        address t0 = tokenPair.token0();
        (uint256 r0, uint256 r1,) = tokenPair.getReserves();
        console.log("(add0, res0, res1)", t0, r0, r1);
        return (r0, r1);
    }

    function check_allowance() internal view returns (uint256, uint256) {
        uint256 w_a = weth.allowance(msg.sender, address(uniRouter));
        uint256 t_a = token.allowance(msg.sender, address(uniRouter));
        return (w_a, t_a);
    }
}
