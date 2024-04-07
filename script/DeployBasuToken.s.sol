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
    IUniswapV2Router02 uniRouter;
    IUniswapV2Factory uniFactory;
    IUniswapV2Pair tokenPair;
    IWETH9 weth;
    address pairAddress;

    // Private key
    // uint256 private_key = vm.envUint("deployer");
    // address deployer = vm.addr(private_key);
    uint256 private_key;
    address uniSwapRouterAddress = 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4;
    address deployer;

    function setUp() external {
        private_key = vm.envUint("deployer");
        deployer = vm.addr(private_key);
        console.log("msg sender is", msg.sender);
        console.log("Starting ...");
    }

    function log_state() internal view {
        console.log("Basu Token address     ", address(token));
        console.log("token pair address     ", address(tokenPair));
    }

    function deployBasuToken() internal {
			vm.startBroadcast();
        token = new BasuToken(
            initialSupply,
            _name,
            _symbol,
            buyTaxPercentage,
            sellTaxPercentage,
            owner_tax_share,
						ownerFunds,
						basuFunds,
						uniSwapRouterAddress
        );
        uniRouter = IUniswapV2Router02(uniSwapRouterAddress);
        uniFactory = IUniswapV2Factory(uniRouter.factory());
        pairAddress = uniFactory.getPair(address(token), uniRouter.WETH());
        tokenPair = IUniswapV2Pair(pairAddress);
        weth = IWETH9(payable(uniRouter.WETH()));
    }

    function run() public {
        deployBasuToken();
				log_state();
    }
}
