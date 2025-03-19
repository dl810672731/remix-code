// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 使用关键字 create2 来预计算部署的合约的地址

contract DeployWithCreate2{
    address public  owner; 
    constructor(address _owner) {
        owner = _owner;  
    }
}

contract CreateFactory{

    event Deploy (address addr);

    function deploy (uint _salt ) external {
      // {}()  
      DeployWithCreate2 _contract =   new DeployWithCreate2{
        salt:bytes32(_salt)
      }
      (msg.sender);

      emit Deploy (address(_contract));
    }

    function getAddress (bytes memory bytecode,uint _solt) public view returns(address) {

        bytes32 hash = keccak256(
          abi.encodePacked(
            bytes1(0xff),address(this), _solt ,keccak256(bytecode)
          )
        );

        return address(uint160(uint(hash)));

    }


    function getBytecode(address _owner) public pure returns (bytes memory){

      bytes memory bytecode = type(DeployWithCreate2).creationCode;
      return abi.encodePacked(
          bytecode,abi.encode(_owner)
            );
    }
}