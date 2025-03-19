// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Caller{
    function setX(TestContract _test,uint _xt) external  {
        _test.setX(_xt);
    }

    function getX(TestContract _test) view external returns (uint) {
       return  _test.getX();
    }

    function setXandSendEther(TestContract _test, uint _x) external payable {
        _test.setXandSendEther{value:msg.value}(_x);
    }

    function getXandSendEther(TestContract _test) view  external returns (uint,uint)  {
       (uint x,uint value) =   _test.getXandValue();
       return (x,value);
    }
}

contract TestContract{

    uint public x;
    uint public value = 123;

    function setX(uint256 _x) public returns (uint256){
        x = _x;
        return x;
    }

    function getX() public view returns (uint256){
        return x;
    }


    function setXandSendEther(uint256 _x)
        payable 
        public 
    {
        x = _x;
        value = msg.value;
    }

    function getXandValue()
        view  
        public 
        returns (uint,uint)
    {
        return (x,value);
    }
    
}