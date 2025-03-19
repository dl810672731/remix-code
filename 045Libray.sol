// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library MathUtil{
    // library 和 struct 的区别是 ：library 不可以有自己的状态变量

    // 如果是public 的话，那么需要单独部署 library MathUtil
    // 如果是 internal 的话，那么部署下面的 Test 时会自动嵌入到下面的合约里面
    function add(uint256 a, uint256 b) internal pure  returns(uint) {
            return a+b;
    }
}

contract Test{

    function testMathUtil(uint256 _a, uint256 _b) external  pure  returns(uint) {
        return MathUtil.add(_a, _b);
    }

}

library ArrayLib{
    function find(uint[] storage arr,uint x) internal  view returns (uint){
        for(uint i = 0;i<arr.length;i++){
            if(arr[i]==x){
                return i;
            }
        }
        revert("not find");
    }
}

contract TestArrayLib{
    using ArrayLib for uint[];
    uint[] public arr = [1,2,3];

    function test() view external  returns (uint){
        return arr.find(2);
    }
}