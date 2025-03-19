// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Couter{

    uint public data;
    function count() external view returns (uint){
      return data;
    }
    function incr() external {
        data++;
    }
}