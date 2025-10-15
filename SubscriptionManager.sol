// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./MembershipToken.sol";
import "./TierRegistry.sol";
import  "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/utils/Pausable.sol";

// @title SubscriptionManager.
//@notice handles user payments, mints NFTs via MemberToken.sol, tracks expirations and allows renewals.
//@notice interfaces with MemebrshipToken.sol( for NFT issuance) and TierRegistry.sol for pricing info.
 
 contract SubscriptionManager is ReentrancyGuard, Pausable{

    ///===============state/storage=========

    IERC20 public token; // token used to pay( eg ETH, DAI)

    MembershipToken public  MT; //  NFT contract reference

    TierRegistry public registry; // where pricing info is fetched

    mapping(address => uint256) public expiry; // tracks subscription end to timestamps

    address public immutable admin; // system operator 

    uint256 public totalCollected; // records total funds collected

    //===========EVENTS============================

    event Subscribed(address indexed user, uint256 indexed tierId, uint256 indexed expiryTime);
    event Renewed(address indexed user, uint256 indexed tierId, uint256 newExpiryTime);
    event FundsWithdrawn(address indexed by, uint indexed amount);
    event RegistryChanged(address indexed newRegistry);
    event ContractInitialized();
    event MembershipCancelled(address indexed user);

    //======custom errors=========
    error NotAdmin();
    error InsufficientFunds();
    error TransactionFailed();
    error InvalidAddress();


    //========constructor============
    constructor (address _token, address _MT, address payable _registry, address _admin ){
        token = IERC20(_token);
        MT = MembershipToken(_MT);
        registry= TierRegistry(_registry);
        admin= _admin;

        emit ContractInitialized();

    }
    modifier onlyAdmin(){
        if(msg.sender != admin)revert NotAdmin();
        _;
    }

    //=========Behavioral Logic============

    //@notice this allows any user to buy a membership
    function subscribe(uint256 tierId) external whenNotPaused nonReentrant {
        TierRegistry.Tier memory t = registry.getTier(tierId);
        if(t.price==0 || t.duration==0) revert TransactionFailed(); 

        // @notice user must first call approve On  the ERC20 before subscribing
      // token. approve(msg.sender, address(this), amount);
        token.transferFrom(msg.sender, address(this), t.price);
        totalCollected += t.price;
         
        MT.mintMembership(msg.sender, uint8(tierId)); 
          uint256 expiryTime = block.timestamp + t.duration ;
          expiry[msg.sender]= expiryTime;
        

        emit Subscribed(msg.sender, tierId, expiryTime);

        


    }
   // @notice extends a memebership duration for existing members
    function renew (uint256 tokenId) external nonReentrant whenNotPaused{
        MembershipToken.MemberData memory m = MT.getMemberData(tokenId);
      TierRegistry.Tier memory t = registry.getTier(m.tier); // get NFT tier info
      
       token.transferFrom(msg.sender, address(this), t.price);
       totalCollected += t.price;

       expiry[msg.sender]+= t.duration;

       emit Renewed(msg.sender, tokenId, expiry[msg.sender] );


    }
    function checkExpiration(address user) external view returns (bool){
        return (block.timestamp < expiry[user]);
           
        }
        function cancelMembership(uint256 tokenId, address user) external onlyAdmin{
    MT.revokeMembership(tokenId);
    expiry[user]=0;

    emit MembershipCancelled(user);
    }
function withdrawFunds()external onlyAdmin{

 uint256 amount = token. balanceOf(address (this));

 if(amount==0)revert InsufficientFunds();
 totalCollected = 0 ;

 (bool sent )= token. transfer(admin, amount);
 if(!sent) revert TransactionFailed();

  emit FundsWithdrawn(admin, amount);
 

 }
 function setTierRegistry(address newRegistry)external onlyAdmin {
    if(newRegistry== address(0)) revert InvalidAddress();
    registry = TierRegistry(newRegistry);

    emit RegistryChanged(newRegistry);
 

 
 }
 }
 
 

 