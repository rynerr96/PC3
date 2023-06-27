// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PublicSale is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20 for IERC20Upgradeable;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    IERC20Upgradeable miPrimerToken;
    IERC20Upgradeable usdcToken;
    address gnosisSafeWallet;
    address nftContractAddress;
    uint256 constant MAX_NFT_SUPPLY = 30;
    uint256 constant COMMON_PRICE = 500 * 10**18;
    uint256 constant RARE_PRICE_MULTIPLIER = 1000;
    uint256 constant LEGENDARY_BASE_PRICE = 10000 * 10**18;
    uint256 constant LEGENDARY_PRICE_INCREMENT = 1000 * 10**18;
    uint256 constant LEGENDARY_MAX_PRICE = 50000 * 10**18;

    mapping(uint256 => bool) soldNfts; // Mapping to track sold status of NFTs
    uint256 public startDate; // Start date for calculating the legendary NFT price

    event DeliverNft(address winnerAccount, uint256 nftId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _miPrimerToken,
        address _usdcToken,
        address _gnosisSafeWallet,
        address _nftContractAddress
    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        miPrimerToken = IERC20Upgradeable(_miPrimerToken);
        usdcToken = IERC20Upgradeable(_usdcToken);
        gnosisSafeWallet = _gnosisSafeWallet;
        nftContractAddress = _nftContractAddress;
        startDate = block.timestamp; // Set the start date when the contract is initialized
    }

    function setMiPrimerToken(address tokenAddress) external onlyRole(UPGRADER_ROLE) {
        miPrimerToken = IERC20Upgradeable(tokenAddress);
    }

    function setUsdcToken(address tokenAddress) external onlyRole(UPGRADER_ROLE) {
        usdcToken = IERC20Upgradeable(tokenAddress);
    }

    function setGnosisSafeWallet(address walletAddress) external onlyRole(UPGRADER_ROLE) {
        gnosisSafeWallet = walletAddress;
    }

    function setNftContractAddress(address contractAddress) external onlyRole(UPGRADER_ROLE) {
        nftContractAddress = contractAddress;
    }

    function purchaseNftById(uint256 _id) external {
        require(!_isNftSold(_id), "Public Sale: id not available");
        require(miPrimerToken.allowance(msg.sender, address(this)) >= _getPriceById(_id), "Public Sale: Not enough allowance");
        require(miPrimerToken.balanceOf(msg.sender) >= _getPriceById(_id), "Public Sale: Not enough token balance");
        require(_id >= 1 && _id <= MAX_NFT_SUPPLY, "NFT: Token id out of range");

        uint256 priceNft = _getPriceById(_id);

        uint256 fee = priceNft / 10;
        uint256 net = priceNft - fee;
        miPrimerToken.transferFrom(msg.sender, gnosisSafeWallet, fee);
        miPrimerToken.transferFrom(msg.sender, address(this), net);


        _markNftAsSold(_id);

        emit DeliverNft(msg.sender, _id);
    }

    function purchaseNftWithUsdc(uint256 _id) external {
        require(!_isNftSold(_id), "Public Sale: id not available");
        require(usdcToken.allowance(msg.sender, address(this)) >= _getPriceById(_id), "Public Sale: Not enough allowance");
        require(usdcToken.balanceOf(msg.sender) >= _getPriceById(_id), "Public Sale: Not enough USDC balance");
        require(_id >= 1 && _id <= MAX_NFT_SUPPLY, "NFT: Token id out of range");

        uint256 priceNft = _getPriceById(_id);

        uint256 fee = priceNft / 10;
        uint256 net = priceNft - fee;
        usdcToken.transferFrom(msg.sender, gnosisSafeWallet, fee);
        usdcToken.transferFrom(msg.sender, address(this), net);

        _markNftAsSold(_id);

        emit DeliverNft(msg.sender, _id);
    }

    function depositEthForARandomNft() public payable {
        require(msg.value >= 0.01 ether, "Public Sale: Insufficient ether");
        require(_areNftsAvailable(), "Public Sale: No available NFTs");

        uint256 nftId = _getRandomNftId();

        (bool sent, ) = gnosisSafeWallet.call{value: msg.value}("");
        require(sent, "Public Sale: Failed to send ether to Gnosis Safe");

        if (msg.value > 0.01 ether) {
            payable(msg.sender).transfer(msg.value - 0.01 ether);
        }

        _markNftAsSold(nftId);

        emit DeliverNft(msg.sender, nftId);
    }

    function receive() external payable {
    }

    function _isNftSold(uint256 _id) internal view returns (bool) {
        return soldNfts[_id];
    }

    function _markNftAsSold(uint256 _id) internal {
        soldNfts[_id] = true;
    }

    function _areNftsAvailable() internal view returns (bool) {
        for (uint256 i = 1; i <= MAX_NFT_SUPPLY; i++) {
            if (!_isNftSold(i)) {
                return true;
            }
        }
        return false;
    }

    function withdrawTokens() external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = miPrimerToken.balanceOf(address(this));
        miPrimerToken.transfer(msg.sender, balance);
    }

    function _getRandomNftId() internal view returns (uint256) {
        uint256 randomId;
        while (true) {
            randomId = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % MAX_NFT_SUPPLY + 1;
            if (!_isNftSold(randomId)) {
                break;
            }
        }
        return randomId;
    }

    function _getPriceById(uint256 _id) internal view returns (uint256) {
        if (_id <= 10) {
            return COMMON_PRICE;
        } else if (_id <= 20) {
            return COMMON_PRICE * RARE_PRICE_MULTIPLIER;
        } else {
            uint256 legendaryPrice = LEGENDARY_BASE_PRICE + (_id - 20) * LEGENDARY_PRICE_INCREMENT;
            if (legendaryPrice > LEGENDARY_MAX_PRICE) {
                return LEGENDARY_MAX_PRICE;
            }
            return legendaryPrice;
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}
}
