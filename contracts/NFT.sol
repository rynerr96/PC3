// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MiPrimerNft is ERC721Upgradeable, PausableUpgradeable, AccessControlUpgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event NftMinted(address indexed minter, address indexed to, uint256 indexed tokenId, string group, string rarity);

    function initialize() initializer public {
        __ERC721_init("MiPrimerNft", "MPRNFT");
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmYAR7NGDpd54ybzHHiGs2gLv7KYkP4Q1BfNXs378VyPYT/";
    }

    function pause() public {
        require(hasRole(PAUSER_ROLE, msg.sender), "MiPrimerNft: must have pauser role to pause");
        _pause();
    }

    function unpause() public {
        require(hasRole(PAUSER_ROLE, msg.sender), "MiPrimerNft: must have pauser role to unpause");
        _unpause();
    }

    function mintNft(address to, uint256 tokenId, string memory group, string memory rarity) public onlyOwner {
        require(hasRole(MINTER_ROLE, msg.sender), "MiPrimerNft: must have minter role to mint");
        require(tokenId >= 1 && tokenId <= 30, "MiPrimerNft: tokenId must be between 1 and 30");

        _safeMint(to, tokenId);
        emit NftMinted(msg.sender, to, tokenId, group, rarity);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
