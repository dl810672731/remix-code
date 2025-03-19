// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract HashFunc{

    function hash(string memory _text,uint _num,address _addr) external pure returns (bytes32){
        return keccak256(abi.encodePacked(_text,_num,_addr));
    }

    function encode(string memory _text,string memory _text1) external pure returns (bytes memory){
        return abi.encode(_text,_text1);
    }

    function encodePacked(string memory _text,string memory _text1) external pure returns (bytes memory){
        return abi.encodePacked(_text,_text1);
    }

    function collistion(string memory _text,string memory _text1) external pure returns (bytes32){
        return keccak256(abi.encodePacked(_text,_text1));
    }

    function collistion(string memory _text,uint _x,string memory _text1) external pure returns (bytes32){
        return keccak256(abi.encodePacked(_text,_x,_text1));
    }


}