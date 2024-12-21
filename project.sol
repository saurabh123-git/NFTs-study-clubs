// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LearnToEarnToken is ERC20, Ownable {
    uint256 public constant REWARD_PER_SESSION = 10 * 10**18; // Reward per completed session (10 tokens)
    mapping(address => bool) public isRegistered;
    mapping(address => uint256) public completedSessions;

    event UserRegistered(address indexed user);
    event SessionCompleted(address indexed user, uint256 totalSessions);

    constructor(address initialOwner) ERC20("LearnToEarnToken", "LTE") Ownable(initialOwner) {
        _mint(address(this), 1_000_000 * 10**18); // Mint initial supply of 1 million tokens to the contract
    }

    // Register a new user
    function registerUser() external {
        require(!isRegistered[msg.sender], "User already registered");
        isRegistered[msg.sender] = true;
        emit UserRegistered(msg.sender);
    }

    // Mark a session as completed and reward tokens
    function completeSession() external {
        require(isRegistered[msg.sender], "User not registered");
        completedSessions[msg.sender] += 1;

        uint256 reward = REWARD_PER_SESSION;
        require(balanceOf(address(this)) >= reward, "Insufficient rewards available");
        _transfer(address(this), msg.sender, reward);

        emit SessionCompleted(msg.sender, completedSessions[msg.sender]);
    }

    // Check user progress
    function getUserProgress(address user) external view returns (uint256) {
        return completedSessions[user];
    }

    // Withdraw unused tokens by owner
    function withdrawUnusedTokens(uint256 amount) external onlyOwner {
        require(balanceOf(address(this)) >= amount, "Insufficient contract balance");
        _transfer(address(this), msg.sender, amount);
    }

    // Allow the owner to mint additional rewards if needed
    function mintAdditionalRewards(uint256 amount) external onlyOwner {
        _mint(address(this), amount);
    }
}
