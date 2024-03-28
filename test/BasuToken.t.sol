// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import { BasuFactory } from "../src/BasuFactory.sol";
import { BasuToken } from "../src/basuToken.sol";
import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "../src/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Router02 } from "../src/interfaces/IUniswapV2Router02.sol";
import { IWETH9 } from "../src/interfaces/IWETH9.sol";

contract CounterTest is Test {}
   //   // ERC20 args
   //   uint256 initialSupply = 1_000_000 * 10 ** 18;
   //   string _name = "BasuToken";
   //   string _symbol = "BSU";
   //   address ownerIs = 0x976EA74026E726554dB657fA54763abd0C3a0aa9; // owner is the end user
   //   uint32 buyTaxPercentage = 3;
   //   uint32 sellTaxPercentage = 3;
   //   uint32 owner_tax_share = 50; // @Dev % share of ownerPool
   //  
   //   BasuToken token;
   //   IUniswapV2Router02 uniRouter;
   //   IUniswapV2Factory uniFactory;
   //   IUniswapV2Pair tokenPair;
   //   IWETH9 weth;
   //   address pairAddress;
   //  
   //   uint256 private_key = vm.envUint("deployer");
   //   address deployer = vm.addr(private_key);
   //  
   //   function setUp() external{
   //       console.log("msg sender is", msg.sender);
   //       console.log("Starting ...");
   //       // vm.startPrank(deployer);
   //       vm.startBroadcast(private_key);
   //       token = new BasuToken(
   //           initialSupply,
   //           _name,
   //           _symbol,
   //           buyTaxPercentage,
   //           sellTaxPercentage,
   //           owner_tax_share
   //       );
   //       uniRouter =
   //           IUniswapV2Router02(0x6BDED42c6DA8FBf0d2bA55B2fa120C5e0c8D7891);
   //       uniFactory = IUniswapV2Factory(uniRouter.factory());
   //       pairAddress = uniFactory.getPair(address(token), uniRouter.WETH());
   //       tokenPair = IUniswapV2Pair(pairAddress);
   //       weth = IWETH9(payable(uniRouter.WETH()));
   //   }
   //  
   //   function get_amounts_out(uint256 _amnt)
   //       internal
   //       view
   //       returns (uint256[] memory)
   //   {
   //       address[] memory _path = new address[](2);
   //       // weth is at 0 index since getAmountsOut return how much of 2nd index
   //       // token we receive for 1st [1st IN, 2nd OUT]
   //       _path[0] = address(weth);
   //       _path[1] = address(token);
   //       uint256[] memory _amount_out = uniRouter.getAmountsOut(_amnt, _path);
   //       return _amount_out;
   //   }
   //  
   //   function buy_tokens(uint256 _amount_weth) internal {
   //       uint256[] memory _amount_out = new uint256[](2);
   //       _amount_out = get_amounts_out(_amount_weth);
   //  
   //       address[] memory path = new address[](2);
   //       path[0] = address(address(weth));
   //       path[1] = address(token);
   //  
   //       uniRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
   //           value: 0.01 ether
   //       }(
   //           _amount_out[1] - (_amount_out[1] * 9 / 10),
   //           path,
   //           msg.sender,
   //           block.timestamp
   //       );
   //   }
   //  
   //   function get_token_balance(address _user) internal view returns (uint256) {
   //       return token.balanceOf(_user);
   //   }
			//
   //   function test_taxes() public {
   //       address random_user = address(1);
   //       create_uniswap_create_pool();
   //       // check if user recerived funds
   //       assertEq(get_token_balance(random_user), 0);
   //       // vm.stopPrank();
   //       // all transaction from here are performed by random user
   //       // vm.startPrank(random_user);
   //       // startHoax(random_user, 1000 ether);
   //       assertGt(random_user.balance, 1 ether);
   //       // buy tokens
   //       buy_tokens(0.01 ether);
   //       // check balance of user again
   //       console.log("Bought tokens");
   //       console.log("msg sender is", msg.sender);
   //       uint256[] memory _amount_out = new uint256[](2);
   //       _amount_out = get_amounts_out(0.01 ether);
   //       assertEq(get_token_balance(random_user), _amount_out[1]);
			//
   //    // uint256 _balance_of_random_user_after = token.balanceOf(random_user);
   //    // assertLt(_balance_of_random_user_after, 1000 ether);
			//
   //    // send token to random wallet
   //    // swap token for weth
   //    //calculate balances after and before swap
   //   }
			//
   //   function test_owner() public {
   //       assertEq(token.owner(), msg.sender);
   //   }
   //  
   //   function create_uniswap_create_pool() public {
   //       // t0 is weth
   //       uint256 weth_r = 5 ether;
   //       uint256 token_r = 100_000 ether;
   //  
   //       assertEq(msg.sender, deployer);
   //       // exchange eth with weth
   //       weth.deposit{ value: 10 ether }();
   //       assertGt(weth.balanceOf(deployer), 10 ether);
   //       // allow uniRouter allowance for token and weth
   //       increase_allowance(10000000 ether);
   //       // check allowance for both tokens before creating pool
   //       (uint256 w_a, uint256 t_a) = check_allowance();
   //       assertGt(w_a, 1000 ether);
   //       assertGt(t_a, 1000 ether);
   //  
   //       (uint256 rb0, uint256 rb1) = check_reserves();
   //       assertEq(rb0, 0);
   //       assertEq(rb1, 0);
   //       // Create a weth pair using uniV2
   //       uniRouter.addLiquidity(
   //           address(token),
   //           uniRouter.WETH(),
   //           token_r,
   //           weth_r,
   //           token_r / 2,
   //           weth_r / 2,
   //           msg.sender,
   //           block.timestamp
   //       );
   //       (uint256 ra0, uint256 ra1) = check_reserves();
   //       assertEq(ra0, weth_r);
   //       assertEq(ra1, token_r);
   //   }
   //  
   //   function check_allowance() internal view returns (uint256, uint256) {
   //       uint256 w_a = weth.allowance(msg.sender, address(uniRouter));
   //       uint256 t_a = token.allowance(msg.sender, address(uniRouter));
   //       return (w_a, t_a);
   //   }
   //  
   //   function check_reserves() internal returns (uint256, uint256) {
   //       // t0 is weth
   //       address t0 = tokenPair.token0();
   //       assertEq(t0, address(weth));
   //       // check if pool was created
   //       (uint256 r0, uint256 r1,) = tokenPair.getReserves();
   //       return (r0, r1);
   //   }
   //  
   //   function increase_allowance(uint256 _amount) internal {
   //       weth.approve(address(uniRouter), _amount);
   //       token.approve(address(uniRouter), _amount);
   //   }
			//
		 // }
