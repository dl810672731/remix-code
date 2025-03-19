// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract B{
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = _num * 2;
        sender = msg.sender;
        value = msg.value;
    }




}

contract A{

    // 变量的顺序要和B里面保持一致
    uint256 public num;
    address public sender;
    uint256 public value;

    // _contract 是B合约的地址
    function setVars(address _contract, uint256 _num) public payable {

        // _contract.delegatecall(
        //     abi.encodeWithSignature("setVars(uint256)",_num)
        // );

        (bool success,bytes memory data) =  _contract.delegatecall(
            abi.encodeWithSelector(B.setVars.selector,_num)
        );

        require(success,"delegatecall fail");
    }

        function setVars2(address _contract, uint256 _num) public payable {

        // _contract.delegatecall(
        //     abi.encodeWithSignature("setVars(uint256)",_num)
        // );

        (bool success,bytes memory data) =  _contract.delegatecall(
            abi.encodeWithSelector(B.setVars.selector,_num)
        );

        require(success,"delegatecall fail");
    }
    
}