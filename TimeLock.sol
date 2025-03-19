// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TimeLock{

    uint public constant Min_delay = 10;
    uint public constant Max_delay = 1000;

    uint public constant Grace_delay = 1000;



    address public owner;
    mapping (bytes32 => bool) public  queued;

    error NotOwnerError();
    error AlreadyQueueError(bytes32 _texId);
    error  NotQueueError(bytes32 _texId);
    error TimeRangError(uint blockTimestamp,  uint _deadline);
    error TimeRangExecuteError(uint blockTimestamp,  uint _deadline);
    error  TimeRangGraceError(uint blockTimestamp,  uint _deadline);
    error TxFailed();



    event QueueEvent
    (
        bytes32 indexed  txId, 
        address indexed _target, 
        uint _value, 
        string  _func,
        bytes  _data, 
        uint _deadline
    );

    // 
    event Cancel(bytes32 txId);




    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender != owner){
            revert NotOwnerError();
        }
        _;
    }


        
    function queue(
        address _target,// 需要调用的合约的地址
        uint _value, // 以太
        string calldata _func,// 调用的签名
        bytes calldata _data,// 传给合约的参数
        uint _deadline // 时间戳
    ) external {
        bytes32 txId = getTxId(_target,_value,_func,_data,_deadline);
        if( queued[txId]){   
            revert AlreadyQueueError(txId);
        }


        if(
            _deadline < block.timestamp + Min_delay || 
            _deadline >  block.timestamp + Max_delay 
        ){
            revert TimeRangError(block.timestamp,_deadline);

        }


        // 入队
        queued[txId] = true;
        emit QueueEvent(txId,_target,_value,_func,_data,_deadline);

    }

    function getTxId(
        address _target, 
        uint _value, 
        string calldata _func,
        bytes calldata _data, 
        uint _deadline
        )
        public pure  returns (bytes32 id)
    {
            return keccak256(
                abi.encode(_target,_value,_func,_data,_deadline)
            );

    }

    // 执行
    function execute(
        address _target, 
        uint _value, 
        string calldata _func,
        bytes calldata _data, 
        uint _deadline
    ) onlyOwner external payable returns (bytes memory) {

     bytes32 txId = getTxId(_target,_value,_func,_data,_deadline);
        if(!queued[txId]){   
            // 没有入队，需要报错
            revert NotQueueError(txId);
        }

        if(
           block.timestamp < _deadline  
        ){
            // 没有到执行时间
            revert TimeRangExecuteError(block.timestamp,_deadline);
        }

        if(block.timestamp >_deadline +  Grace_delay ){
            // 执行的时间不能过长，执行的周期
            revert TimeRangGraceError(block.timestamp,_deadline);
        }

        bytes memory data;
        if(bytes(_func).length > 0) {
            data = abi.encodePacked(
                //  取方法签名的前4个字节
                bytes4(keccak256((bytes(_func)))),
                _data
            );
        } else{
            data = _data;
        }

      (bool success, bytes memory res)
          = _target.call{value:_value}(data);

      if(!success){
        revert TxFailed();
      }
      // 出队
      queued[txId] = false;

      return res;
    }

    // 取消
    function cancel(bytes32 txId) external onlyOwner{

        if(!queued[txId]){
            revert NotQueueError(txId);
        }
        queued[txId] = false;
        emit Cancel(txId);

    }

    // 
    receive() external payable { }

}

contract TestTimeLock{

    address public timeLock;

    constructor(address _timeLock){
        timeLock = _timeLock;
    }

    function test() external {
        require(msg.sender == timeLock);
    }
}

contract TestTime{

    function getTime() external view returns (uint){

        return block.timestamp +100;

    }
}