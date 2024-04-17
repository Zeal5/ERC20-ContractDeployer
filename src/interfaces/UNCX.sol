// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface  UNCX {
    struct TokenLock {
        address lpToken;
        uint256 lockDate;
        uint256 amount;
        uint256 initialAmount;
        uint256 unlockDate;
        uint256 lockID;
        address owner;
        uint16 countryCode;
    }

    event OnMigrate(
        uint256 lockID,
        address lpToken,
        address owner,
        uint256 amountRemainingInLock,
        uint256 amountMigrated,
        uint256 migrationOption
    );
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event onIncrementLock(
        uint256 lockID,
        address lpToken,
        address owner,
        address payer,
        uint256 amountRemainingInLock,
        uint256 amountAdded,
        uint256 liquidityFee
    );
    event onNewLock(
        uint256 lockID,
        address lpToken,
        address owner,
        uint256 amount,
        uint256 lockDate,
        uint256 unlockDate,
        uint16 countryCode
    );
    event onRelock(
        uint256 lockID,
        address lpToken,
        address owner,
        uint256 amountRemainingInLock,
        uint256 liquidityFee,
        uint256 unlockDate
    );
    event onSplitLock(
        uint256 lockID, address lpToken, address owner, uint256 amountRemainingInLock, uint256 amountRemoved
    );
    event onTransferLockOwnership(uint256 lockID, address lpToken, address oldOwner, address newOwner);
    event onWithdraw(
        uint256 lockID, address lpToken, address owner, uint256 amountRemainingInLock, uint256 amountRemoved
    );

    function COUNTRY_LIST() external view returns (address);
    function LOCKS(uint256)
        external
        view
        returns (
            address lpToken,
            uint256 lockDate,
            uint256 amount,
            uint256 initialAmount,
            uint256 unlockDate,
            uint256 lockID,
            address owner,
            uint16 countryCode
        );
    function NONCE() external view returns (uint256);
    function TOKEN_LOCKS(address, uint256) external view returns (uint256);
    function acceptOwnership() external;
    function gFees()
        external
        view
        returns (
            uint256 ethFee,
            address secondaryFeeToken,
            uint256 secondaryTokenFee,
            uint256 secondaryTokenDiscount,
            uint256 liquidityFee,
            uint256 referralPercent,
            address referralToken,
            uint256 referralHold,
            uint256 referralDiscount
        );
    function getLockedTokenAtIndex(uint256 _index) external view returns (address);
    function getNumLockedTokens() external view returns (uint256);
    function getNumLocksForToken(address _lpToken) external view returns (uint256);
    function getUserLockForTokenAtIndex(address _user, address _lpToken, uint256 _index)
        external
        view
        returns (TokenLock memory);
    function getUserLockedTokenAtIndex(address _user, uint256 _index) external view returns (address);
    function getUserNumLockedTokens(address _user) external view returns (uint256);
    function getUserNumLocksForToken(address _user, address _lpToken) external view returns (uint256);
    function getUserWhitelistStatus(address _user) external view returns (bool);
    function getWhitelistedUserAtIndex(uint256 _index) external view returns (address);
    function getWhitelistedUsersLength() external view returns (uint256);
    function incrementLock(uint256 _lockID, uint256 _amount) external;
    function lockLPToken(
        address _lpToken,
        uint256 _amount,
        uint256 _unlock_date,
        address payable _referral,
        bool _fee_in_eth,
        address payable _withdrawer,
        uint16 _countryCode
    ) external payable;
    function migrate(uint256 _lockID, uint256 _amount, uint256 _migration_option) external;
    function migrator() external view returns (address);
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function relock(uint256 _lockID, uint256 _unlock_date) external;
    function renounceOwnership() external;
    function setDev(address payable _devaddr) external;
    function setFees(
        uint256 _referralPercent,
        uint256 _referralDiscount,
        uint256 _ethFee,
        uint256 _secondaryTokenFee,
        uint256 _secondaryTokenDiscount,
        uint256 _liquidityFee
    ) external;
    function setMigrator(address _migrator) external;
    function setReferralTokenAndHold(address _referralToken, uint256 _hold) external;
    function setSecondaryFeeToken(address _secondaryFeeToken) external;
    function splitLock(uint256 _lockID, uint256 _amount) external payable;
    function transferLockOwnership(uint256 _lockID, address payable _newOwner) external;
    function transferOwnership(address newOwner) external;
    function uniswapFactory() external view returns (address);
    function whitelistFeeAccount(address _user, bool _add) external;
    function withdraw(uint256 _lockID, uint256 _amount) external;
}
