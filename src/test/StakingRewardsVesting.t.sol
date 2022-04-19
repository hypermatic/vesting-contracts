pragma solidity 0.8.11;

import "ds-test/test.sol";
import "../Vesting.sol";
import "../MockERC20.sol";
import "./utils/Cheats.sol";
import "../MockStakingRewards.sol";

contract StakingRewardsTest is DSTest {
    Vesting public vesting;
    MockERC20 public token;
    MockStakingRewards public StakingRewards;
    address public addr1;
    address public addr2;
    Cheats internal constant cheats = Cheats(HEVM_ADDRESS);

    function setUp() public {
        vesting = new Vesting();
        token = new MockERC20(100000);
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);
        StakingRewards = new MockStakingRewards(address(token),address(vesting));
        //token.transfer(address(StakingRewards),1000);
        vesting.setApprovedAddress(address(StakingRewards));
        token.approve(address(StakingRewards),100000000000000);
        StakingRewards.setReward(address(addr1), 1000);
        StakingRewards.setReward(cheats.addr(4), 1000);
        
    }

    function testExample() public {
        assertTrue(true);
    }

    function testSpoofRewardsClaim()public{
        //StakingRewards.setReward(addr1, 100);
        cheats.prank(addr2);
        StakingRewards.getReward();

        uint256 x = vesting.getNumOfSchedules(addr2);
        assert(x == 0);
        cheats.stopPrank();
    }


    function testRewardsClaim()public{
        //StakingRewards.setReward(addr1, 100);
        cheats.prank(addr1);
        StakingRewards.getReward();
        emit log_uint(token.balanceOf(address(vesting)));
        uint256 x = vesting.getNumOfSchedules(addr1);
        assert(x > 0);
        emit log_uint(x);
        uint256 y = vesting.getScheduleTotalAmount(x-1);
        emit log_uint(y);
        emit log_address(addr1);
        //vesting.claim(x);
        cheats.stopPrank();
    }

    function testVestingClaim()public{

        cheats.prank(cheats.addr(4));
        StakingRewards.getReward();
        uint256 x = vesting.getNumOfSchedules(cheats.addr(4));
        emit log_uint(x);
        assert(x > 0);
        cheats.warp(block.timestamp + 3 weeks);
        uint256 y = vesting.getScheduleTotalAmount(x-1);
        emit log_uint(y);
        //assert(y > 0);
        assert(token.balanceOf(cheats.addr(4))==0);
        cheats.prank(cheats.addr(4));
        vesting.claim(x-1);
        assert(token.balanceOf(cheats.addr(4))>0);

    }
}