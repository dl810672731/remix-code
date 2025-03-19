// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract WETH is ERC20 {

    event  Deposit(address indexed account,uint256  amount);
    event  Withdrawn(address indexed account,uint256  amount);

    constructor()  ERC20("WETH", "WETH"){}

    fallback() external payable {
        deposit();
    }
    
    // 存款，打款
    function deposit() public payable {
        _mint(msg.sender,msg.value);
        emit Deposit(msg.sender,msg.value);
    }

    function withdraw(uint256 _amount) external {
        // _burn(msg.sender, _amount);
        // _transfer(msg.sender, address(this), _amount);
        payable (msg.sender).transfer(_amount);
        emit Withdrawn(msg.sender,_amount);
    }
}