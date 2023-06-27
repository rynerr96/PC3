// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract MyTokenMiPrimerToken is ERC20Upgradeable, UUPSUpgradeable {
    address private owner;
    address private gnosisSafe;

    function initialize() initializer public {
        __ERC20_init("MiPrimerToken", "MPT");
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function setGnosisSafeAddress(address gnosisSafeAddress) external onlyOwner {
        require(gnosisSafeAddress != address(0), "Invalid Gnosis Safe address");
        gnosisSafe = gnosisSafeAddress;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(gnosisSafe == address(0) || msg.sender == gnosisSafe, "Transfers are not allowed");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(gnosisSafe == address(0) || msg.sender == gnosisSafe, "Transfers are not allowed");
        return super.transferFrom(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(gnosisSafe == address(0) || msg.sender == gnosisSafe, "Approvals are not allowed");
        return super.approve(spender, amount);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
