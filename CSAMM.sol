// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CSAMM{

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0;
    uint public reserve1;
    uint public totalSupply;

    mapping (address => uint) public balanceOf;

    function _mint(address _to,uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _to,uint _amount) private {
        balanceOf[_to] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _reserve0,uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(address _tokenIn,uint _amountIn)  external returns (uint amountOut)  {
        require(_tokenIn == address(token0) ||_tokenIn == address(token1), "Wrong Token");

        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn,IERC20 tokenOut) = isToken0 ? (token0,token1):(token1,token0);
        (uint reserveIn,uint reserveOut) = isToken0 ? (reserve0,reserve1):(reserve1,reserve0);
        uint  amountIn = token0.balanceOf(address(this)) - reserveIn;

       //  uint amountIn = 0;
    
        // 转入token到合约中
        // 如果转入的是 token0
        // if (_tokenIn == address(token0)) {
        //     // token0.transferFrom(from, to, value);
        //     // 把token0转移_amountIn的数量，从发送方转移到此合约中
        //     token0.transferFrom(msg.sender, address(this), _amountIn);

        //     //  精确计算 转入的等于 现在的余额减去上次的余额
        //     amountIn = token0.balanceOf(address(this)) - reserve0;
        // } else {
        //     token1.transferFrom(msg.sender, address(this), _amountIn);
        //     amountIn = token1.balanceOf(address(this)) - reserve1;

        // }

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);        


        // 计算可以换出的 token数量（换另一个token的数量）
        // amountOut = amountIn * 0.997
        amountOut = amountIn * 997 /1000;

        (uint res0,uint res1) = isToken0 ?
         (reserveIn + _amountIn,reserveOut - amountOut)
          :(reserveIn - amountOut,reserveOut + _amountIn);
          _update(res0,res1);
        // 更新2个token的余额
        // if (_tokenIn == address(token0)) {
        //   _update(reserve0 + _amountIn,reserve1 - amountOut);
        // } else {
        //   _update(reserve0 - amountOut,reserve1 + _amountIn);
        // }
        // 把需要换出的token转出到 调用方 中
        tokenOut.transfer(msg.sender,amountOut);
    }

    // 添加流动性
    function addLiquidity(uint _amount0,uint _amount1) external returns(uint shares){

        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));

        uint d0 = bal0 - reserve0;
        uint d1 = bal1 - reserve1;

        if(totalSupply == 0){
            shares = d0 + d1;
        }else{
            shares =(( d0 + d1) + totalSupply) /(reserve0 + reserve1);
        }

        require(shares > 0,"Unable to mint");
        _mint(msg.sender, shares);
        _update(d0, d1);
    }


    function removeLiquidity(uint _shares) external returns(uint d0,uint d1){
        d0 = (_shares * reserve0) / totalSupply;
        d1 = (_shares * reserve1) / totalSupply;

        _burn(msg.sender, _shares);

        _update(reserve0 - d0, reserve1 - d1);
        if(d0 > 0 ){
            token0.transfer(msg.sender, d0 );

        }
        if (d1 > 0 ){
            token1.transfer(msg.sender, d1 );
        }
    }

    constructor(address _token0, address _token1){
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }


}