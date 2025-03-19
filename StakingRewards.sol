// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingRewards{

    // 质押token
    IERC20 public immutable stakingToken;

    // 奖励token
    IERC20 public immutable rewardsToken;

    address public owner;

    // 奖励持续时间
    uint public duration;

    // 奖励结束时间
    uint public finishAt;

    // 合约的更新时间
    uint public updatedAt;

    // 奖励速率
    uint public rewardRate;

    // 总质押量
    uint public rewardPertTokenStored;

    // 每个用户的质押量
    mapping (address => uint256) public userRewardPertPaid;

    // 每个用户的奖励(待领取，尚未领取的奖励)
    mapping (address => uint256) public rewards;

    uint public totalSupply;
    mapping (address => uint256) public balanceOf;


    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        owner = msg.sender;
        // duration = 60 days;// 60天
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    

    // 奖励时间
    function setRewardsDuration(uint _duration) external onlyOwner{
        require(finishAt < block.timestamp, 'Rewards not finished');
        duration = _duration;
    }


    // _amount 新打的奖励
    function notifyRewardAmount(uint _amount) external onlyOwner updateReward(address(0)){
        if(finishAt < block.timestamp){
            rewardRate = _amount/duration;
        }else{
            // 还在本轮次中，剩余的奖金
            uint rewardAmount = rewardRate * ( finishAt - block.timestamp );
            rewardRate = (rewardAmount + _amount) / duration;
        }

        require(rewardRate > 0,"Reward rate should > 0");
        require(rewardRate * duration <rewardsToken.balanceOf(address(this)),"No more reward tokens");

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;


    }

    // 质押 _amount 金额的质押 stakingToken
    function stake(uint _amount) external  updateReward(msg.sender) {

        require(_amount > 0,"Stake amount must be greater than 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;

        totalSupply += _amount;

    }

    function withdraw(uint _amount) external updateReward(msg.sender) {

        require(_amount > 0,"Withdraw amount must be greater than 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender,_amount);
    }

    // 计算每个用户可以收到的奖励金额
    function earned(address _account) public view returns (uint) {
        balanceOf[_account] *  (rewardPerToken() - userRewardPertPaid[_account])  /1e18
        +
         rewards[_account];
    }

    function rewardPerToken() public view returns (uint256) {
        if(totalSupply == 0){
            return rewardPertTokenStored;
        }

        return rewardPertTokenStored +
         (
            rewardRate *
            (_min(block.timestamp,finishAt) - updatedAt)  // 上一次奖励生效的时间长度
         ) * 1e18
          /
           totalSupply;
    }

    // 上一次奖励生效的时间长度
    function lastRewardApplayTime( ) public view returns (uint){
         return  (_min(block.timestamp,finishAt) - updatedAt) ;
    }

    // 更新用户的奖励金额
    modifier  updateReward(address _account){
        rewardPertTokenStored =  rewardPerToken();
        updatedAt = lastRewardApplayTime();

        if(_account != address(0)){
            rewards[_account] = earned(_account);
            userRewardPertPaid[_account] = rewardPertTokenStored;
        }
        _;
    }

    // 用户领取奖励，注意，这里是领取的意思，不是查询的意思
    function getReward() external  updateReward(msg.sender){
        uint reward = rewards[msg.sender];
        if(reward> 0){
            rewards[msg.sender] = 0;
            // 将奖励token 发给此用户
            rewardsToken.transfer(msg.sender, reward);
        }

    }
   
    function _min(uint x,uint y) private pure returns(uint){
        return x < y ? x : y;
    }

}