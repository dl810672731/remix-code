// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface IERC721 {

    function transferForm(
        address _from,
        address _to,
        uint _nftId
    ) external ;
    
}
contract DutchAuction{

    uint private constant DURATION = 7 days;
    IERC721 public immutable nft;
    uint public immutable nftId;

    // 卖家地址
    address public  immutable sellerAddress;
    uint public immutable startPrice;

    uint public immutable startTime;
    uint public immutable endTime;
    uint public immutable cutRate;

    constructor(
        uint  _startPrice,
        uint  _cutRate,
        address _nft,
        uint _nftId
    ){
        sellerAddress = payable (msg.sender);
        startPrice = _startPrice;
        cutRate = _cutRate;
        startTime = block.timestamp;
        endTime = block.timestamp + DURATION;

        require(_startPrice >= _cutRate * DURATION);

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns (uint){
        uint time = block.timestamp - startTime;
        uint cutPrice = time * cutRate;
        return  startPrice - cutPrice > 0 ? startPrice - cutPrice : 0;
    }

    function buy() payable external {

        require(block.timestamp < endTime,"time last");
        uint price = getPrice();
        require(msg.value >= price, "Not enough value");
        nft.transferForm(sellerAddress, msg.sender, nftId);

        uint refund = msg.value - price;
        if(refund > 0){
            payable (msg.sender).transfer(refund);
        }

    }





}