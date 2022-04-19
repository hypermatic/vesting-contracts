// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IVesting.sol";

contract MockStakingRewards is ReentrancyGuard{
    using SafeERC20 for IERC20;

    IERC20 public rewardsToken;
    mapping(address => uint256) public rewards;
    IVesting public vesting;



    constructor (address _rewardsToken,address _vesting){
        rewardsToken = IERC20(_rewardsToken);
        vesting = IVesting(_vesting);
    }


    function setVestingAddress(address _vesting)public{
        vesting = IVesting(_vesting);
    }


    function setReward(address to, uint256 amount)public{
        rewardsToken.safeTransferFrom(msg.sender,address(this),amount);
        rewards[to] = amount;
    }


    function getReward() public nonReentrant{
    uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(address(vesting), reward);
            vesting.vest(msg.sender, reward, address(rewardsToken), true, 3, 4, block.timestamp);
            emit RewardPaid(msg.sender, reward);
        }
    }



    event RewardPaid(address indexed user, uint256 reward);

}