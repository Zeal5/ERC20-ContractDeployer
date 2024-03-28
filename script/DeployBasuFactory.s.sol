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
    address uniSwapRouterAddress = 0x6BDED42c6DA8FBf0d2bA55B2fa120C5e0c8D7891;
    address deployer;

    function setUp() external {
        private_key = vm.envUint("deployer");
        deployer = vm.addr(private_key);
        console.log("msg sender is", msg.sender);
        console.log("Starting ...");
				uniRouter = IUniswapV2Router02(uniSwapRouterAddress);
				uniFactory= IUniswapV2Factory(uniRouter.factory());
    }

    function deployBasuTokenFactory() internal {
			address client = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
        uint256 initialSupply = 1_000_000 * 10 ** 18;
        string memory _name = "BasuToken";
        string memory _symbol = "BSU";
        uint32 buyTaxPercentage = 2;
        uint32 sellTaxPercentage = 8;
        uint32 owner_tax_share = 60; // @Dev % share of ownerPool
        address basuFunds = 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f;
        address ownerFunds = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
        vm.startBroadcast(private_key);
        BasuFactory tokenFactory = new BasuFactory();
        console.log("factory deployed", address(tokenFactory));
        address new_token = tokenFactory.DeployToken(
            initialSupply,
            _name,
            _symbol,
            buyTaxPercentage,
            sellTaxPercentage,
            owner_tax_share,
            ownerFunds,
            basuFunds
        );


				address tokenPair = uniFactory.getPair(address(new_token),uniRouter.WETH());
				log_state(address(new_token), tokenPair);

				console.log(ERC20(new_token).balanceOf(address(tokenFactory)));
				
				//check factory for weth and 
        // ERC20(new_token).transfer(address(payable(tokenFactory)), 800_000);
        tokenFactory.addLiquidity{ value: 2 ether }(
				new_token);
     }
		 		
    function log_state(address _token, address _pair) internal view {
        console.log("uniswap router address ", address(uniRouter));
        console.log("Basu Token address     ", address(_token));
        console.log("uniswap factory addr   ", address(uniFactory));
        console.log("token pair address     ", address(_pair));
        console.log("weth address           ", address(weth));
    }
				
    function run() public {
        deployBasuTokenFactory();
    }
}









