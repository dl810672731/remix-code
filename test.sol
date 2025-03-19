// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract testString{
    string  public s1 = "test1";
    string  public s2 = "test2";

    bool public b = true;
    uint public u = 123; // uint = uint256
    int public i = -123; // int = int256
    int public maxInt = type(int).max;
    int public minInt = type(int).min;
    address addr = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    bytes32  b32 = "0xEA3cBea8b0d3CED";
    string strVal = "0xEA3cBea8b0d3CED";

    
}


contract FunctionInfo{
    // 函数
    function add(uint x,uint y) external pure returns(uint){
        return x+y;
    }
}

contract StateVariables{
    // 状态变量，存储在区块链上,类比java 中的成员变量
    uint public   myUnit =123;
    function foo() external  pure returns(uint){
        // 局部变量
        uint ocalVal = 123; 
        return ocalVal;
    }
}

contract Loaclariables{
    // 状态变量，存储在区块链上,类比java 中的成员变量
    uint public   myUnit =123;
    function foo() external {

        // 局部变量
        uint ocalVal = 123; 

        bool f = false;
        ocalVal+= 456;
        f = true;

        myUnit += 456;
    }
}


// 全局变量
contract GlobalVariables{


    function globalVars() external view returns (address,uint,uint) {

      address sender = msg.sender; // 0x5A86858aA3b595FD6663c2296741eF4cd8BC4d01 调用方的地址
    
      uint timestamp = block.timestamp;
      uint blockNum = block.number;
      return (sender,timestamp,blockNum);
    }
}

// 视图和纯函数
contract ViewAndPureFunction{
    
    uint public i = 456;

    // 读取了区块链上的数据，就是视图
    function viewTest() external  view returns(uint){ 
        return i;
    }

    function pureTest(uint x,uint y) external  pure returns(uint){ 
        return x+y;
    }

}

contract  Constants{

    // 373
    address public constant MY_ADDRESS = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    // 303
    uint public constant MY_UINT = 123;


}

contract  NotConstants{
    // 2505
    address public  MY_ADDRESS = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    // 2403
    uint public  MY_UINT = 123;
}

contract Error{
    function testRequire(uint i) public pure {
        require(i<=10,"i>10");

    }


    function testrevert(uint i) public pure {
        if(i>0){
            // more code
            if(i>10){
                revert("i>10");
            }
        }
    }

    error MyError(address caller,uint i);

    function CustomeError(uint _i) public view  {
        if(_i>0){
            // more code
            if(_i>10){
                revert MyError(msg.sender,_i);
            }
        }
    }
}

// 函数装饰器

contract FunctionModifier{
    uint public myNum = 567;
     
    // functionName.(paramName) = paramName
    modifier MyMuodifier(){
        require(myNum<10,"_myNum>10");
        _;

        // 如果后续这里还有代码的话，那么这个装饰器就是一个三明治装饰器        
    }

    //  这样就能复用装饰器的 MyMuodifier 的代码,进行参数检验
    function inc() external MyMuodifier {
        
        myNum+=1;
    }
}

// 构造函数
contract TestConstructor{
    address public myAddress;
    uint public myUnit;

    // 构造函数只在部署 合约 TestConstructor 的时候调用一次
    constructor(uint _unit){
        myAddress = msg.sender; 
        myUnit = _unit;// 123
    }
}

contract FunctionOutputs{
    function testReturn() public pure  returns (address,bool) {  
        return(address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),true);  //return address 和 bool类型数据
    }

    function testNamedReturn() public pure returns (address add,bool b) {  
        return(address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),true); 
         //return address 和 bool类型数据
    }

   function assignedReturn() public pure returns (address add,bool b) {  
        add =  address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        b = true;
    }

    function test() public pure {  
        address _add;
        bool  _b;
        (_add, _b) =  testReturn();
    }
}

contract Array{

    uint[] public nums = [1,2,3];

    uint[3] public numsFixed = [1,2,3];

    function test() external {
        nums.push(4); // 添加元素
        uint x = nums[1]; // get
        nums[2] = 4; // 设置值

        delete nums[1]; // 清除这个下标的数据内容，但是默认值还在，默认值是0
        nums.pop(); // 弹出最后一个元素
        uint len = nums.length;

        // 创建一个内存中的数据,内存中的数据长度必须是固定的
        uint[] memory a = new uint[](5);
        a[1] = 123;
    }

}

contract Mapping{
    mapping (address => uint) public balnces ;
    mapping (address => mapping (address=> bool)) public isFriend;

    function test() public{
        balnces[msg.sender] = 123;
        uint bal =  balnces[msg.sender];
        uint bal2 =  balnces[address(1)]; // 0

        balnces[msg.sender] += 456;
        delete balnces[msg.sender];

        isFriend[msg.sender][address(this)] = true;
    }
}

contract ItreableMapping{
    mapping (address => uint) public balances;
    mapping (address => bool) public insert;
    address[] public keys;

    // 给映射的某个key设置value值
    function set(address _key,uint _val) external {
        balances[_key] = _val;
        if(!insert[_key]){
            insert[_key] = true;
            keys.push(_key);
        }
    }

    // 获取映射的大小
    function getSize() external view returns (uint) {
        return keys.length;
    }

    // 获取映射的第一个元素的值
    function getFirst() external view returns (uint) {
        return balances[keys[0]];
    }

    // 获取映射的最后个元素的值
    function getLast() external view returns (uint) {
        return balances[keys[keys.length-1]];
    }

    // 获取某下标的的元素的值
    function get(uint index) external view returns (uint){
        return balances[keys[index]];
    }

}

contract Structs{

    // 结构体的定义
    struct Car{
        string model;
        uint year;
        address owner;
    }

    Car public car;
    Car[] public cars;
    mapping (address => Car) public catByOwnerMap;

    function test() external {
        // 3种初始化的方式
        // 1
        Car memory toYoTa = Car("ToYoTa",201,msg.sender);
        // 2
        Car memory bmwCar = Car({model:"BMW",year:201,owner:msg.sender});
        // 3
        Car memory tesla;
        tesla.model = "tesla";
        tesla.year = 1234;
        tesla.owner = msg.sender;

        cars.push(toYoTa);
        cars.push(bmwCar);
        cars.push(tesla);
        // memory 内存中创建的变量，函数执行完就消除了

        cars.push(Car("testCar",1996,msg.sender));

        // 如果想修改区块链中的值，需要用  storage
        Car storage _car = cars[0];

        _car.model = "update model";
        _car.year = 1984;

        delete _car.owner; // 清除值内容
        delete cars[0]; // 清除第1个元素的值内容
    }
}

 contract Enum {

    enum Status{
        None,
        Pending,
        Shipped,
        Colpelted,
        Rejected,
        Cancled
    }

    struct Order{
        Status  status;
        address buyer;
    }

    Order[] public orders;
    Status public status;


    function get() external view returns (Status){
        return status;
    }

    function set(Status _status) external{
        status = _status;
    }

    function ship() external{
        status = Status.Shipped;
    }

    function reset() external{
        delete status;
    }


}

contract Event{

    event Log(string message,uint val);
    // indexed 最多修饰3个参数
    event Log(address  indexed  sender,uint val);

    function test() external {
        emit Log("foo",123);
        emit Log(msg.sender,456);
    }

    event Message(address  indexed  _from,address indexed  _to,string  message);

    function sendMessage(address  _to, string calldata message) external {
        emit Message(msg.sender, _to, message);

    }

}

contract A{
    function foo() public pure virtual  returns (string memory){
        return "A";
    }

    function bar()  public pure virtual  returns (string memory){
        return "A";
    }

    function baz() public pure   returns (string memory){
        return "A";
    }
}

contract B is A{
    function foo() public pure virtual override   returns (string memory){
        return "B";
    }

    function bar()  public pure  virtual override  returns (string memory){
        return "B";
    }

}

contract C is B{

    function bar()  public pure   override  returns (string memory){
        return "C";
    }

}

contract D is A,B{

    function foo()  public pure   override(A,B)  returns (string memory){
        return "D";
    }

    function bar()  public pure   override(A,B)  returns (string memory){
        return "D";
    }
}