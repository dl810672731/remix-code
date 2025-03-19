// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TestMultiCall{

    function func1() external  view returns (uint,uint){
        return(1,block.timestamp);
    }

    function func2() external  view returns (uint,uint){
        return(2,block.timestamp);
    }


    function getData1() external  pure  returns (bytes memory){
        return abi.encodeWithSelector(this.func1.selector);
    }

    function getData2() external  pure  returns (bytes memory){
        return abi.encodeWithSelector(this.func2.selector);
    }



}

contract MultiCall {

// 参数书双引号
// ["0x6D0953eFc724DD6e7adAB350B9303E4ce0dA1928","0x6D0953eFc724DD6e7adAB350B9303E4ce0dA1928"]
// ["0x74135154", "0xb1ade4db"]
    function multiCall(address[] calldata targets,bytes[] calldata data)  external view returns (bytes[] memory){

        bytes[] memory results = new bytes[](targets.length);

        for(uint i = 0;i< targets.length;i++){

            (bool success,bytes memory result)  = targets[i].staticcall(data[i]);
            require(success,"Multi Call Failed");
            results[i] = result;
        } 
        return results;   
    }

}