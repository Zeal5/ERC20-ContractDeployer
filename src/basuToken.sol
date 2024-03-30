// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "src/interfaces/IUniswapV2Factory.sol";
import "src/interfaces/IUniswapV2Router02.sol";

contract BasuToken is ERC20, Ownable(msg.sender) {
    // UniSwapV2 Router address
    IUniswapV2Router02 internal constant router =
        IUniswapV2Router02(0x6BDED42c6DA8FBf0d2bA55B2fa120C5e0c8D7891);
    // address of liq pool
    address internal immutable liquidityPool;
    // address for pair
    // Address of the factory that deployed this contract
    address internal basuFunds;
    // owner taxShare address
    address internal ownerFunds;
    // Tax percentage on buy transactions.
    uint32 internal _buyTax;
    // Tax percentage on sell transactions.
    uint32 internal _sellTax;
    // Percentage of tax that goes to owner pool, remaining goes to basu pool.
    uint32 internal _ownerTaxSharePercentage;
    // Maximum amount for buy/sell transactions.
    uint256 internal maxTxAmount;
    // mapping of addresses that are excluded from tax
    mapping(address => bool) internal isExcludedFromTax;
    // Events

    event ExcludedFromTax(address account, bool exclude);
    // @Dev when basuFundsPool address changes
    event basuFundsPoolUpdated(address newDevelopmentPool);
    // @Dev when buy tax % is changed
    event buytaxPercentageUpdated(uint256 newTaxPercentage);
    // @Dev when sell tax % is changed
    event selltaxPercentageUpdated(uint256 newTaxPercentage);
    // @Dev when owner share of tax is changed
    event ownerTaxSharePercentageUpdated(uint32);
    // @Dev when a tax transfer occurs
    event TaxTransfer(address indexed from, address indexed to, uint256 amount);
    // When max buy/sell amount is updated
    event maxTxAmountUpdated(uint256 newMaxTxAmount);
		// When token is deployed
    event TokenDeployed(address token, address owner,address pool, string name, string symbol, uint32 buyTax, uint32 sellTax);

    // @Dev Raised when ownerOnly functions are called by !owner
    error UnauthorizedAccount();
    //@Dev raise when try to trade with amount greater then allowed in maxTxAmount
    error TransferAmountExceedsMaxTxAmount();

    modifier onlyBasu() {
        if (msg.sender != basuFunds) {
            revert UnauthorizedAccount();
            _;
        }
    }

    modifier changeExcludedFromTax(address oldAddress, address newAddress) {
        isExcludedFromTax[oldAddress] = false;
        isExcludedFromTax[newAddress] = true;
        _;
    }

    constructor(
        uint256 initialSupply,
        string memory _name,
        string memory _symbol,
        uint32 buyTaxPercentage,
        uint32 sellTaxPercentage,
        uint32 owner_tax_share, // @Dev % share of ownerPool
        address _owner_funds_address,
        address _basu_funds_address
    ) ERC20(_name, _symbol) {
        ownerFunds = _owner_funds_address;
        basuFunds = _basu_funds_address;
        _buyTax = buyTaxPercentage;
        _sellTax = sellTaxPercentage;
        _ownerTaxSharePercentage = owner_tax_share;

        // @Dev create liq pool
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());
        address weth = router.WETH();
        liquidityPool = factory.createPair(address(this), weth);

        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[_basu_funds_address] = true;
        isExcludedFromTax[_owner_funds_address] = true;

        // mint initial to end user address
        _mint(msg.sender, initialSupply);
        maxTxAmount = (initialSupply * 2) / 100;
				emit TokenDeployed(address(this), address(msg.sender), liquidityPool,_name, _symbol,_buyTax, _sellTax);
    }

    // Getter functions
    function ownerTaxSharePercentage() public view returns (uint32) {
        return _ownerTaxSharePercentage;
    }

    function buyTax() public view returns (uint32) {
        return _buyTax;
    }

    function sellTax() public view returns (uint32) {
        return _sellTax;
    }

    // Setter functions
    function setBuyTax(uint32 _newBuyTax) external onlyOwner {
        _buyTax = _newBuyTax;
        emit buytaxPercentageUpdated(_newBuyTax);
    }

    function setSellTax(uint32 _newSellTax) external onlyOwner {
        _sellTax = _newSellTax;
        emit selltaxPercentageUpdated(_newSellTax);
    }

    function setOwnerTaxSharePercentage(uint32 ownerSharePercentage) external {
        _ownerTaxSharePercentage = ownerSharePercentage;
        emit ownerTaxSharePercentageUpdated(ownerSharePercentage);
    }

    function setMaxTxAmount(uint256 maxTxAmountPercentage) external onlyOwner {
        uint256 _maxTxAmount = (totalSupply() * maxTxAmountPercentage) / 100;
        maxTxAmount = _maxTxAmount;
        emit maxTxAmountUpdated(_maxTxAmount);
    }

    function _update(address from, address to, uint256 amount)
        internal
        override
    {
        if (from != liquidityPool && to != liquidityPool) {
            super._update(from, to, amount);
        } else {
            if (!isExcludedFromTax[from] && !isExcludedFromTax[to]) {
                if (amount > maxTxAmount) {
                    revert TransferAmountExceedsMaxTxAmount();
                }
                if (to == liquidityPool) {
                    (uint256 taxPercentage_, uint256 splitPercentage_) =
                        (_sellTax, (_ownerTaxSharePercentage));
                    uint256 taxAmount = (amount * taxPercentage_) / 100;
                    unchecked {
                        uint256 ownerShare =
                            (taxAmount * splitPercentage_) / 100;
                        uint256 basuShare = taxAmount - ownerShare;
                        super._update(from, ownerFunds, ownerShare);
                        super._update(from, basuFunds, basuShare);
                        super._update(from, to, amount - taxAmount);
                        emit TaxTransfer(from, basuFunds, ownerShare);
                        emit TaxTransfer(from, ownerFunds, basuShare);
                    }
                } else if (from == liquidityPool) {
                    (uint256 taxPercentage_, uint256 splitPercentage_) =
                        (_buyTax, (_ownerTaxSharePercentage));
                    uint256 taxAmount = (amount * taxPercentage_) / 100;
                    unchecked {
                        uint256 ownerShare =
                            (taxAmount * splitPercentage_) / 100;
                        uint256 basuShare = taxAmount - ownerShare;
                        super._update(from, ownerFunds, ownerShare);
                        super._update(from, basuFunds, basuShare);
                        super._update(from, to, amount - taxAmount);
                        emit TaxTransfer(from, basuFunds, ownerShare);
                        emit TaxTransfer(from, ownerFunds, basuShare);
                    }
                }
            } else {
                super._update(from, to, amount);
            }
        }
    }
}
