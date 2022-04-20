// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IVesting.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MockStakingRewards is ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public rewardsToken;
    mapping(address => uint256) public rewards;
    IVesting public vesting;
    mapping(address => uint256) private _balances;
    address[] Users;



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


    function mockStake(uint256 amount)external{
        require(amount > 0);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        Users.push(msg.sender);

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

    function vestForAllStaked()public{
        for (uint i=0; i < Users.length; i++){
            address user = Users[i];
             uint256 reward = rewards[user];
             if (reward > 0){
                 rewards[user] = 0;
                 rewardsToken.safeTransfer(address(vesting), reward);
                 vesting.vest(user, reward, address(rewardsToken), true, 3, 4, block.timestamp);
             }

        }

    }





    event RewardPaid(address indexed user, uint256 reward);

}