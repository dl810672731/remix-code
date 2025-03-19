// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract SenderEther{
    constructor() payable {

    }

    receive() external payable { }

    function sendVaiTransfer(address payable _to) external payable {
        _to.transfer(msg.value);
    }

    function sendVaiSend(address payable _to) external payable {
       bool sent =  _to.send(123);
       require(sent,"error");

    }

    function sendVaiCall(address payable _to) external payable {
      (bool success,)=   _to.call{value:123}("");
      require(success,"error");

    }
}

contract EtherReceive{
    event Log(uint amount,uint gas);

    receive() external payable {
        emit Log(msg.value,gasleft());
    }

}