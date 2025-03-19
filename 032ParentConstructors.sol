// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract S {
    string public name;
    constructor(string memory _name){
        name = _name;
    }

}

contract T {
    string public text;
    constructor(string memory _text){
        text = _text;
    }

}

contract U is S("s"),T("t") {

}

// 构造函数执行顺序 
// 1 S
// 2 T
// 3 V
contract V is S,T {
    constructor(string memory _name,string memory _text) S(_name) T(_text){
    }

}

// 构造函数执行顺序 
// 1 T
// 2 s
// 3 V2
contract V2 is T,S {
    constructor(string memory _name,string memory _text) T(_text)  S(_name) {
    }

}