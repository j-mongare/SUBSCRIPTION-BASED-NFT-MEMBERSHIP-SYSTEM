// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./SubscriptionManager.sol";
import  "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/utils/Pausable.sol";

contract RewardPool is ReentrancyGuard, Pausable {

    SubscriptionManager public SM;
    IERC20 public rewardToken;
    mapping(address => uint256) public rewardsClaimed;
    uint256 public poolBalance;
    address public admin;

    event RewardsDeposited(uint256 amount);
    event RewardsClaimed(address indexed member, uint256 amount);

    error NotAdmin();
    error TransferFailed();
    error InsufficientFunds();
    error InactiveMembership();
    error InvalidAddress();

    constructor(address _SM, address _rewardToken, address _admin) {
        SM = SubscriptionManager(_SM);
        rewardToken = IERC20(_rewardToken);
        admin = _admin;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    function depositRewards(uint256 amount) external onlyAdmin whenNotPaused nonReentrant {
        if (amount == 0) revert InsufficientFunds();
         poolBalance += amount;

        bool success = rewardToken.transferFrom(admin, address(this), amount);
        if (!success) revert TransferFailed();
       
        emit RewardsDeposited(amount);
    }

    function calculateReward(address user) internal view returns (uint256) {
        // Example placeholder: fixed reward
       // 1% of remaining pool

       return poolBalance / 100; 
    }

    function claimRewards() external whenNotPaused nonReentrant {
        bool active = SM.checkExpiration(msg.sender);
        if (!active) revert InactiveMembership();

        uint256 reward = calculateReward(msg.sender);
        if (reward > poolBalance) revert InsufficientFunds();

        poolBalance -= reward;
        rewardsClaimed[msg.sender] += reward;

        //@ notice....for economic and safety reasons, it would be better if we let users withdraw for themselves (pull payment)
        // in this scenario I have pushed the rewards to the users, which can be expensive in users are many.

        bool success = rewardToken.transfer(msg.sender, reward);
        if (!success) revert TransferFailed();

        emit RewardsClaimed(msg.sender, reward);
    }

    function withdrawUnclaimedRewards() external onlyAdmin whenNotPaused nonReentrant {
        uint256 amount = poolBalance;
        if (amount == 0) revert InsufficientFunds();

        poolBalance = 0;
        bool success = rewardToken.transfer(admin, amount);
        if (!success) revert TransferFailed();
    }

    function pause() external onlyAdmin whenNotPaused {
        _pause();
    }

    function unpause() external onlyAdmin whenPaused {
        _unpause();
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert InvalidAddress();
        admin = newAdmin;
    }
}

