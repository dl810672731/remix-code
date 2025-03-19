// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Immutable {

   //  address public   owner = msg.sender; 
   // immutable 修饰的变量只能在部署的时候初始化，所以一般是写在构造函数里面去初始化
   address public  immutable owner; 

   constructor(){
      owner = msg.sender; 
   }


    uint public  x;

    function test() external {
        require(msg.sender == owner);
    }
    
}