// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {

    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);

    
}

contract CrowdFund{

    event Launch(uint id,address indexed creator,uint goal,uint32 startAt,uint32 endAt);
    event Cancel(uint id);
    event Pledge(uint id,address indexed creator,uint _amount);
    event Unpledge(uint id,address indexed creator,uint _amount);

   event  Refund(uint id,address indexed creator,uint _amount);




    struct Campaign{
        address creator;
        uint goal;
        uint pledged;
        uint startAt;
        uint endAt;

        // 发起方是否有领取金额
        bool claimed;
    }

    IERC20 public immutable token;

    // 有多少个活动正在发起中
    uint public count;

    mapping (uint => Campaign)public campaigns;

    // 活动id,用户地址，参与金额
    mapping (uint => mapping(address => uint)) public pledgeAmount;

    constructor(address _token){
        token = IERC20(_token);
    }


    function launch(
        uint _goal,// 活动总额
        uint32 _startAt, // 活动开始时间
        uint32 _endAt) external  {
        
        require(_startAt >= block.timestamp, "startAt at < now");
        require(_startAt >= _endAt, "_startAt < _endAt");
        require(_endAt > block.timestamp + 30 days, "_endAt big");
        count+=1;
        campaigns[count] = Campaign({
            creator:msg.sender,
            goal :_goal,
            pledged:0,
            startAt:_startAt,
            endAt : _endAt,
            claimed:false  
        });
        // 打印事件日志
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancle(uint _id) external{
        require(_id > 0 && _id <= count,"invalid id");
        Campaign memory campaign = campaigns[_id];

        require(block.timestamp >= campaign.startAt,"time not started");

        require(msg.sender == campaign.creator, "not creator");

        delete campaigns[_id];

        emit Cancel(_id);
    }

    // 用户参与
    function pledge(uint _id,uint _amount) external {

        require(_id > 0 && _id <= count,"invalid id");
        Campaign memory campaign = campaigns[_id];

        require(block.timestamp <= campaign.endAt,"time endAt");
        campaign.pledged+=_amount;
        pledgeAmount[_id][msg.sender] +=_amount;

        token.transferFrom(msg.sender, address(this),_amount);

        emit Pledge(_id,msg.sender,_amount);
    }


    // 用户取消参与
    function unpledge(uint _id,uint _amount) external {

        require(_id > 0 && _id <= count,"invalid id");
        Campaign memory campaign = campaigns[_id];

        require(block.timestamp <= campaign.endAt,"time endAt");
        campaign.pledged -=_amount;
        pledgeAmount[_id][msg.sender] -=_amount;

        token.transfer(msg.sender,_amount);

        emit Unpledge(_id,msg.sender,_amount);
    }


    // 达成目标后的发起方认领
    function claim(uint _id) external {

        require(_id > 0 && _id <= count,"invalid id");
        Campaign memory campaign = campaigns[_id];

        require(block.timestamp >= campaign.endAt,"time not endAt");
        // 只有发起方才能认领
        require(msg.sender == campaign.creator, "not creator");
        // 需要完成目标金额
        require(campaign.pledged >= campaign.goal,"pledge not big enough");
        // 只能认领一次
        require(campaign.claimed == false,"claim only once");

        campaign.claimed = true;

        // token 里的钱转移到发起方
        token.transfer(msg.sender,campaign.pledged - campaign.goal);

        // token.transferFrom(address(this),msg.sender,campaign.pledged - campaign.goal);
    }

    // 时间截止后，没有达成目标，退款给参与者

    function refund(uint _id) external {

        require(_id > 0 && _id <= count,"invalid id");
        Campaign memory campaign = campaigns[_id];

        require(block.timestamp < campaign.endAt,"time not endAt");
        // 需要完成目标金额
        require(campaign.pledged < campaign.goal,"goal  big ");
        
        // 参与者当时对这个活动的参与金额
        uint bal =  pledgeAmount[_id][msg.sender];

        // token 里的钱转移到发起方
        token.transfer(msg.sender,bal);

        emit Refund(_id,msg.sender,bal);

    }

}