// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "../src/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Router02 } from "../src/interfaces/IUniswapV2Router02.sol";
import { IWETH9 } from "../src/interfaces/IWETH9.sol";
import { BasuToken } from "./basuToken.sol";
import { UNCX } from "./interfaces/UNCX.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BasuFactory is Ownable(msg.sender) {
    IUniswapV2Router02 uniRouter;
    IUniswapV2Factory uniFactory;
    IUniswapV2Pair uniPair;
    IWETH9 weth;

    event TokenDeployed(address token, address owner);
    event LiquidityAdded(address token, uint256 tokensAdded, uint256 WETHAdded);

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
    ) public returns (BasuToken) {
        BasuToken token = new BasuToken(
            initialSupply,
            _name,
            _symbol,
            buyTaxPercentage,
            sellTaxPercentage,
            owner_tax_share,
            ownerFunds,
            basuFunds,
            address(uniRouter)
        );
        emit TokenDeployed(address(token), address(ownerFunds));
        return token;
    } // function ends

    function addLiquidity(address _token) public payable {
        weth.deposit{ value: msg.value }();
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

    function lock_lp(
        address _lpToken,
        uint256 _amount,
        uint256 _unlockDate,
        address payable _referal,
        bool _fee_in_eth,
        address payable _withdrawer,
        uint16 countryCode
    ) public payable {
        uniPair = IUniswapV2Pair(_lpToken);
        uint256 _bal = uniPair.balanceOf(address(this));
        address uncxAddress = 0xc4E637D37113192F4F1F060DaEbD7758De7F4131;
        uniPair.approve(uncxAddress, _bal);
        UNCX locker = UNCX(uncxAddress);
        // get fees
        (uint256 ethFee,,,,,,,, uint256 referralDiscount) = locker.gFees();
        uint256 lockerFee = ethFee * (1000 - referralDiscount) / 1000;
        locker.lockLPToken{ value: lockerFee }(
            _lpToken,
            _amount,
            _unlockDate,
            _referal,
            _fee_in_eth,
            _withdrawer,
            countryCode
        );
    }
    // create a withdraw method for tokens and eth
    receive() external payable { }
} //contract ends
