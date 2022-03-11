// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaFin is ChainlinkClient, Ownable {
    IERC20 public rewardToken;
    address RewardTokenAddress = 0x0f95bE8f66fE402745b70140067A7fe51a9550cA; // Reward
    address StakeTokenAddress = 0xbbb72255e1AE16EE398D57c62Bfc131749D68793; // Stake 
    uint256 amount = 1000000000000000000;
   
    address[] public stakers;
    // token > address
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokensStaked;
    mapping(address => address) public tokenPriceFeedMapping;
    address[] public allowedTokens;

    constructor() {
        rewardToken = IERC20(RewardTokenAddress);
    }

    function setPriceFeedContract(address token, address priceFeed)
        public
        onlyOwner
    {
        tokenPriceFeedMapping[token] = priceFeed;
    }

    function stakeTokens() public {
        // Require amount greater than 0
        require(amount > 0, "amount cannot be 0");
        updateUniqueTokensStaked(msg.sender, StakeTokenAddress);
        IERC20(StakeTokenAddress).transferFrom(msg.sender, address(this), amount);
        stakingBalance[StakeTokenAddress][msg.sender] =
            stakingBalance[StakeTokenAddress][msg.sender] +
            amount;
        if (uniqueTokensStaked[msg.sender] == 1) {
            stakers.push(msg.sender);
        }
    }

    // Unstaking Tokens (Withdraw)
    function unstakeTokens() public {
        // Fetch staking balance
        uint256 balance = stakingBalance[StakeTokenAddress][msg.sender];
        require(balance > 0, "staking balance cannot be 0");
        IERC20(StakeTokenAddress).transfer(msg.sender, balance);
        stakingBalance[StakeTokenAddress][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
    }

      // Issuing Tokens
    function issueTokens() public onlyOwner {
        // Issue tokens to all stakers
        for (
            uint256 stakersIndex = 0;
            stakersIndex < stakers.length;
            stakersIndex++
        ) {
            address recipient = stakers[stakersIndex];
            rewardToken.transfer(recipient, getUserTotalValue(recipient));
        }
    }

    function getUserTotalValue(address user) public view returns (uint256) {
        uint256 totalValue = 0;
        if (uniqueTokensStaked[user] > 0) {
            totalValue =
                    totalValue +
                    getUserTokenStakingBalanceEthValue(
                        user,
                        StakeTokenAddress
                    );
        }
        return totalValue;
    }

      function getUserTokenStakingBalanceEthValue(address user, address token)
        public
        view
        returns (uint256)
    {
        if (uniqueTokensStaked[user] <= 0) {
            return 0;
        }
        (uint256 price, uint8 decimals) = getTokenEthPrice(token);
        return
            (stakingBalance[token][user] * price) / (10**uint256(decimals));
    }


    function getTokenEthPrice(address token) public view returns (uint256, uint8) {
        address priceFeedAddress = tokenPriceFeedMapping[token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return (uint256(price), priceFeed.decimals());
    }

    function updateUniqueTokensStaked(address user, address token) internal {
        if (stakingBalance[token][user] <= 0) {
            uniqueTokensStaked[user] = uniqueTokensStaked[user] + 1;
        }
    }    
}