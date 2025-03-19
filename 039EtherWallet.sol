// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract EtherWallet{
    address payable public owner;
    constructor(){
        owner = payable(msg.sender);
    }

    receive() external payable { }

    function withraw(uint _amount) external {
        require(msg.sender == owner,"caller is not owner");
        payable (msg.sender).transfer(_amount);
    }

    // 之前是 99999999999993178863
    // withraw 
    //   35325 gas
    // transaction cost	30717 gas 
    // execution cost	9513 gas 

    // getOnwerBalance()本身 消耗 459
    // 之后是 99999999999993117430

    // 再次重试-1 后 99999999999993055997


    function getBalance()  view external returns (uint) {
        return address(this).balance; 
    }

    function getOnwerBalance()  view external returns (uint) {
        return msg.sender.balance; 
    }

}