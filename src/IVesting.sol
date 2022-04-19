pragma solidity ^0.8.11;

interface IVesting {

       function vest(
        address account,
        uint256 amount,
        address asset,
        bool isFixed,
        uint256 cliffWeeks,
        uint256 vestingWeeks,
        uint256 startTime
    ) external;


    function claim(uint256 scheduleNumber) external;

    function rug(address account, uint256 scheduleId) external;

    function withdraw(uint256 amount, address asset) external;
}