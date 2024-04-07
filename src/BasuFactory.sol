// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUniswapV2Factory} from "../src/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "../src/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "../src/interfaces/IUniswapV2Router02.sol";
import {IWETH9} from "../src/interfaces/IWETH9.sol";
import {BasuToken} from "./basuToken.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BasuFactory is Ownable(msg.sender) {
    IUniswapV2Router02 uniRouter;
    IUniswapV2Factory uniFactory;
    IWETH9 weth;

    event TokenDeployed(address token, address owner);
		event LiquidityAdded(address token, uint tokensAdded, uint WETHAdded);

    constructor(address _dexAddress) {
        uniRouter = IUniswapV2Router02(_dexAddress);
        uniFactory = IUniswapV2Factory(uniRouter.factory());
        weth = IWETH9(payable(0x4200000000000000000000000000000000000006));
        // add msg.owner as owner of factory
    }

    function DeployToken(
        uint256 initialSupply,
        string memory _name,
        string memory _symbol,
        uint32 buyTaxPercentage,
        uint32 sellTaxPercentage,
        uint32 owner_tax_share,
        address ownerFunds,
        address basuFunds
    ) external returns (address) {
        BasuToken token = new BasuToken(
            initialSupply, _name, _symbol, buyTaxPercentage, sellTaxPercentage, owner_tax_share, ownerFunds, basuFunds, address(uniRouter)
        );
        emit TokenDeployed(address(token), address(msg.sender));
        return address(token);
    } // function ends

    function addLiquidity(address _token) public payable {
        weth.deposit{value: msg.value}();
        // get token balances
        uint256 token_balance = ERC20(_token).balanceOf(address(this));
        uint256 weth_balance = weth.balanceOf(address(this));
        // get approvals
        ERC20(_token).approve(address(uniRouter), token_balance);
        weth.approve(address(uniRouter), weth_balance);

        uniRouter.addLiquidity(
            _token,
            address(weth),
            token_balance,
            weth_balance,
            (token_balance * 80) / 100,
            (weth_balance * 80) / 100,
            address(this),
            block.timestamp
        );
				emit LiquidityAdded(_token, token_balance, weth_balance);
    } // function ends

    receive() external payable {}
} //contract ends
