// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract OwnerAble{
    address public owner;

    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner(){ 
        require(msg.sender == owner,"not owner");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner{
        require(_newOwner != address(0),"zero address");
        owner = _newOwner;
    }

    function setOnlyOwnerCanCall() external onlyOwner{

    }

    function anyOwnerCanCall()  external{
        
    }
}