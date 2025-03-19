// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MultiSignWallet{
    event Deposit(address indexed from, uint256 value);
    event Submit(uint indexed txId);
    event Approve(address indexed owner,uint indexed txId);
    event Revoke(address indexed owner,uint indexed txId);
    event Execute(address indexed owner,uint indexed txId);

    address[] public owners;

    // 便于判断是不是owner
    mapping (address =>bool) public isOwnerMapping;

    // 允许的最低下限
    uint public needOwnerNum;

    struct Transaction{
        address to;//地址
        bytes data;
        bool executed;
        uint amount;// 数量
    }
    
    // 交易结构体
    Transaction[] public transactions;

    // 交易是否被允许
    mapping (uint => mapping (address => bool)) public approvedMapping;


    constructor(address[] memory _owners,uint _needOwnerNum){

        // 需要有owners

        // needOwnerNum 小于 _owners 的数量

        // 
        for(uint i=0;i< _owners.length;i++){
            address owner = _owners[i];

            // 基础检验 对owner

            //赋值
            isOwnerMapping[owner] = true;
            owners.push(owner);  

        }

        needOwnerNum  = _needOwnerNum;

    }

    modifier onlyOwner(){
        require (isOwnerMapping[msg.sender]==true,"not owner");
        _;
    }

    // 接收以太
    receive() external payable {
        emit  Deposit(msg.sender, msg.value);
    }

    // 提交交易
    function submit(address _to,uint _value,bytes calldata _data ) external payable onlyOwner{
        Transaction memory t1 =  Transaction({
            to:_to,
            data: _data,
            executed : false,
            amount:_value
        });
        transactions.push(t1);

        emit Submit(transactions.length-1);

    }

    // 允许交易执行

    function approve(uint _txId) external 
    onlyOwner 
    txExists(_txId)
    isNotApprobed(_txId)
    isNotExecute(_txId)
    {
        // 方法体
        approvedMapping[_txId][msg.sender] = true;
        emit Approve(msg.sender,_txId);


    }

    modifier txExists(uint _txId){
        // 
        _;
    }

    modifier isNotApprobed(uint _txId){
        // 
        _;
    }

    modifier isNotExecute(uint _txId){
        // 
        _;
    }

    // 某交易被允许通过的数量
    function _getApprovedCount(uint _txId) private view returns (uint) {

        uint count = 0;

        // 按照owner去遍历
        for(uint i= 0;i<owners.length;i++){
           bool approved =  approvedMapping[_txId][msg.sender];
           if(approved){
            count+=1;
           }
        }

        return count;

    }

    // 交易执行
    function execute(uint _txId) 
    external onlyOwner
     txExists(_txId)
      isNotExecute(_txId)
    {
        Transaction storage t1 = transactions[_txId];
        (bool sent,) = 
            t1.to.call{value:t1.amount}(t1.data);
        require(sent,"fail call");
          // 发送给to
        t1.executed  =true;
        emit Execute(msg.sender, _txId);
        
    }

    // 取消
    function revoke(uint _txId) 
        external onlyOwner
        txExists(_txId) // 交易存在
        isYetApprove(_txId) // 已经被允许了
        isNotExecute(_txId) // 没有被执行过
    {
        require(approvedMapping[_txId][msg.sender],"not approved");

       approvedMapping[_txId][msg.sender] = false;
       emit Revoke(msg.sender, _txId);

        
    }

    // 已经被允许的
    modifier isYetApprove(uint _txId){
        _;
    }
}