// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// @title TierRegistry
// @ notice this contract stores and manages all memebrship tier data (prices, duration, and labels).
contract TierRegistry{

    struct Tier{
        uint256 id;     // unique identifier
        string name;   // eg gold, silver, and bronze
        uint256 price;  // subscription fee in ERC20 tokens
        uint256 duration; // active period in seconds
    }
    //========= storage/state============
    mapping(uint256 => Tier)public tiers;
    uint256 public nextTierId;
    address public admin;

    //====events=========
    event TierAdded(uint256 indexed id, uint256 duration);
    event TierUpdated(uint256 indexed id, string name, uint256 price, uint256 duration);
    event TierRegistryInitialized();
    

    //======custom errors======
    error NotAdmin();
    error InvalidPrice();
    error InvalidTierChange();
    error DurationMustBeGreaterThanZero();
    error InvalidAddress();

    //=======constructor======
    constructor(address _admin){
          admin= _admin;
          

          emit TierRegistryInitialized();
    }
    //=============modieir============
    modifier onlyAdmin(){
        if(msg.sender != admin) revert NotAdmin();
        _;
    }
    //=============core logic==================
    function addTier(string calldata name, uint256 price, uint256 duration) external  onlyAdmin{
        if(price==0)revert InvalidPrice();
        if (duration <= 0) revert DurationMustBeGreaterThanZero();

        uint256 id = nextTierId++;
       

        tiers[id]= Tier({
            id: id,
            name: name,
            price: price,
            duration: duration
        });

        emit TierAdded(id, duration);

    }
    function updateTier(uint256 tierId, string calldata newName, uint256 newPrice, uint256 duration)onlyAdmin external{
        if(tierId >= nextTierId) revert InvalidTierChange();
        if (newPrice == 0) revert InvalidPrice();

        tiers[tierId]= Tier ({
            id: tierId,
            name: newName,
            price: newPrice,
            duration: duration

        });
        emit TierUpdated (tierId, newName, newPrice, duration);

    }
    //============helper functions============
    function getTier(uint tierId)external view returns (Tier memory){
        return tiers[tierId];
    }
    //@notice this enables replacement of admin when necessesary
    function setAdmin(address newAdmin) external onlyAdmin{
        if(newAdmin==address(0))revert InvalidAddress();
        admin= newAdmin;
    }
}