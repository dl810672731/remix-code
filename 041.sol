// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface  ICouter{
    function count() external view returns (uint);
    function incr() external ;

}

contract MyTest{

    function incr(address _couter) external {
      ICouter(_couter).incr();
    }

    function getCount(address _couter) external view returns (uint){
        return ICouter(_couter).count();
    }
}
