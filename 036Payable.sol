// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Payable{
    address payable public sender;
   
    constructor(){
     sender = payable(msg.sender);
    }

    function send() external payable {

    }

    function getBalances() external view returns (uint) {
        return address(this).balance;
    }

    function getThisAddress() external view returns (address) {
        return address(this);
    }

    function getSenderBalances() external view returns (uint) {
        return sender.balance;
    }
}