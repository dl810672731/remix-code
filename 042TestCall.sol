// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TestCaler{
    string public message;
    uint public x;

    event Log(address call,uint256 amount,string message);

    receive() external payable { }

    // fallback() external payable { 
    //     emit Log(msg.sender,msg.value, "fallback call");
    // }

    function foo(string memory _message,uint256 _x)
        payable 
        public
    returns (bool,uint)
    {
        message = _message;
        x = _x;
        return (true,x);
    }

}

contract CallTest{
    bytes public data;
    function callFoo(address _test) external payable {
      (bool success,bytes  memory _data) = _test.call{value:111}
      (abi.encodeWithSignature("foo(string,uint256)", "call foo",123));
      require(success,"fail" );
        data = _data;
    }
        
    function test2(address _test) external {
        (bool success,) = _test.call(abi.encodeWithSignature("notFunction(string,uint256)"));
        require(success,"fail");
    }
}