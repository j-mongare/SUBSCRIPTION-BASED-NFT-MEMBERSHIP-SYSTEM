// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// === OpenZeppelin imports from GitHub ===
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/utils/Pausable.sol";

/// @title MembershipToken (MT)
/// @notice Mintable, non-transferable (soulbound) ERC721 NFT that proves membership
contract MembershipToken is ERC721, AccessControl, Pausable {

    // ======== STRUCTS ==========
    struct MemberData {
        uint256 id;
        uint8 tier;       // tier 1 = gold, tier 2 = silver, tier 3 = bronze
        bool active;
        uint64 joinDate;  // block timestamp when member joined
    }

    // ======== STATE VARIABLES ==========
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    mapping(uint256 => MemberData) public members;
    uint256 public nextTokenId;
    address public admin;
    address public manager;

    // ======== EVENTS ==========
    event MembershipMinted(address indexed from, address indexed to, uint256 indexed tokenId, uint256 tier);
    event MembershipRevoked(uint256 indexed tokenId);
    event TierUpgraded(uint256 indexed tokenId, uint256 indexed newTier);
    event ContractInitialized();

    // ======== CUSTOM ERRORS ==========
    error TokenDoesNotExist();
    error NotTransferable();
    error InvalidAddress();
    error InvalidTierChange();

    // ======== CONSTRUCTOR ==========
    constructor(address _admin, address _manager) ERC721("MembershipToken", "MT") {
        if (_admin == address(0) && _manager == address (0)) revert InvalidAddress();
         
        admin = _admin;
        manager=_manager;

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE,_manager);
        _grantRole(PAUSER_ROLE, _admin);

        emit ContractInitialized();
    }

    // ======== CORE LOGIC ==========

    function mintMembership(address to, uint8 tier) external whenNotPaused onlyRole(MINTER_ROLE) {
        if (to == address(0)) revert InvalidAddress();

        uint256 tokenId = nextTokenId++;
        _mint(to, tokenId);

        members[tokenId] = MemberData({
            id: tokenId,
            tier: tier,
            active: true,
            joinDate: uint256 (block.timestamp)
        });
        

        emit MembershipMinted(address(0), to, tokenId, tier);
    }

    function revokeMembership(uint256 tokenId) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_ownerOf(tokenId) == address(0)) revert TokenDoesNotExist();

        if (members[tokenId].active) {
            members[tokenId].active = false;
            _burn(tokenId);
        }

        emit MembershipRevoked(tokenId);
    }

    function upgradeTier(uint256 tokenId, uint8 newTier) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 currentTier = members[tokenId].tier;
        if (newTier <= currentTier) revert InvalidTierChange();

        members[tokenId].tier = newTier;
        emit TierUpgraded(tokenId, newTier);
    }

    function pause() external whenNotPaused onlyRole(PAUSER_ROLE) {
        _pause();
        
    }

    function unpause() external whenPaused onlyRole(PAUSER_ROLE) {
        _unpause();
        
    }

    /// @notice Prevents transfers — only mint (from = address(0)), and burn (to = address(0)) are allowed

    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        whenNotPaused
        returns (address)
    {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) revert NotTransferable();

        return super._update(to, tokenId, auth);
    }

    // ======== VIEW HELPERS ==========

    function getMemberData(uint256 tokenId) external view returns (MemberData memory) {
        return members[tokenId];
    }

    //@dev supportsInterface is part of ERC165, which is how smart contracts declare which interfaces (like ERC721, ERC2981, etc.) they implement.
    //@notice When multiple parents implement it, you must merge them manually to keep things unambiguous.
    
    function supportsInterface(bytes4 interfaceId)public view override (ERC721, AccessControl) returns (bool){
        return super.supportsInterface(interfaceId);
    }

    function setAdmin(address newAdmin) external onlyRole(DEFAULT_ADMIN_ROLE){
        if (newAdmin == address(0)) revert InvalidAddress();
        admin= newAdmin;

    }

    function setManager(address newManager) external onlyRole(DEFAULT_ADMIN_ROLE){
        if(newManager== address(0))revert InvalidAddress();
      _grantRole(MINTER_ROLE, newManager);

    }
}




