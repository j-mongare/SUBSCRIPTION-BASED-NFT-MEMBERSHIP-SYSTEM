# SUBSCRIPTION-BASED-NFT-MEMBERSHIP-SYSTEM

This repository contains four Solidity smart contracts that work together to manage a simple on-chain membership and rewards system. The project was built as a learning exercise to understand how contracts can interact and manage roles, payments, and rewards.

* OVERVIEW:

The system includes:

TierRegistry.sol

Stores membership tiers (e.g., Gold, Silver, Bronze) along with their price and duration.
Handles adding and updating membership tiers by an admin.

MembershipToken.sol

A non-transferable (soulbound) ERC721 token that represents a member’s status.
Integrates OpenZeppelin contracts for role management and pausing.

SubscriptionManager.sol

Handles payments and subscription logic.
Connects the ERC20 payment token, the MembershipToken for NFT minting, and the TierRegistry for tier pricing.
Manages renewals, expirations, and fund withdrawals.

RewardPool.sol

A reward distribution contract that encourages long-term membership.
Verifies membership status through the SubscriptionManager before allowing claims.
Admins can deposit and withdraw tokens, and members can claim rewards if their membership is active.

* WHAT I LEARNED:

1. How to write and structure multiple Solidity contracts that interact with each other.

2. How to use OpenZeppelin libraries (ERC721, ERC20 interfaces, AccessControl, Pausable, and ReentrancyGuard).

3. How to implement access control, events, and custom errors for safer and clearer smart contracts.

4. The importance of modifiers, visibility, and security practices like nonReentrant.

* WHAT I PLAN TO WORK ON NEXT: 

Improve the reward calculation logic in RewardPool.sol to make it depend on membership tier and subscription age.

Add automated tests using Hardhat or Foundry to simulate contract interactions.

Improve error handling and refactor logic in SubscriptionManager.sol for better clarity.

Add a simple frontend (React or Next.js) to interact with the contracts on a test network.

* HOW TO USE:

Clone the repository.

git clone https://github.com/<your-username>/<repo-name>.git


Open the project in your Solidity IDE or framework (Remix, Hardhat, or Foundry).

* DEPLOY THE CONTRACTS IN THIS ORDER: 

1. TierRegistry.sol

2. MembershipToken.sol

3. SubscriptionManager.sol

4. RewardPool.sol

Make sure to replace placeholder addresses (like ERC20 token or admin addresses) before deployment.

* NOTES!

1. The contracts are written for Solidity version 0.8.23.

2. This project is still a work in progress and not ready for production.

3. The main goal is to practice writing safe, modular Solidity code that follows good design principles.
