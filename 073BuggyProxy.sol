// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract CounterV1{
    uint public count;
    function inc() external {
        count++;
    }

    function admin() external view returns(address){
        return address(1);
    }

    function implementation() external view returns(address){
        return address(2);
    }
}

contract CounterV2{
    uint public count;
    function inc() external {
        count++;
    }

    function dec() external {
        count--;
    }
}

contract BuggyProxy{
    // 为什么没有自增？？？ 0xC6446daa74cA104a012eA7f652CE2c0989C4275E
    address public implementation;
    address public admin;

    constructor(){
        admin = msg.sender;
    }

    // Proxy透明转发的原理
    // https://blog.csdn.net/haifeng_zhang_it/article/details/135596953?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-135596953-blog-122745389.235^v43^pc_blog_bottom_relevance_base6&spm=1001.2101.3001.4242.2&utm_relevant_index=3
    function _delegate(address _implementation) private {
        // This code is for "illustration" purposes. To implement this functionality in production it
        // is recommended to use the `Proxy` contract from the `@openzeppelin/contracts` library.
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.2/contracts/proxy/Proxy.sol   
        assembly {
        // (1) copy incoming call data
        calldatacopy(0, 0, calldatasize())
        
        // (2) forward call to logic contract
        let result := 
            delegatecall(gas(), _implementation, 0, calldatasize(),0,0)  
        // (3) retrieve return data
        returndatacopy(0, 0, returndatasize())
        
        // (4) forward return data back to caller
        switch result
        case 0 {
            revert(0, returndatasize())
        }
        default {
            return(0, returndatasize())
        }
        }
    }

    fallback() external payable {
         _delegate(implementation);
    }

    receive() external payable {
         _delegate(implementation);
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin,"not can upgradeTo");
        implementation = _implementation;
    }
}

contract Proxy{

    bytes32 private  constant implementation_slot = bytes32(uint(keccak256("eip1967.proxy.implementation"))-1);

    bytes32 private constant admin_slot = bytes32(uint(keccak256("eip1967.proxy.admin"))-1);



    constructor(){
       _setAdmin(msg.sender);
    }

    fallback() external  payable { 
        _fallback();
    }

    modifier ifAdmin(){
        if(msg.sender == _getAdmin()){
            _;
        }else{
            _fallback();
        }

    }

    function changeAdmin(address _newAdmin) external ifAdmin{
        _setAdmin(_newAdmin);
    }

    function _delegate(address _implementation) private {
        // This code is for "illustration" purposes. To implement this functionality in production it
        // is recommended to use the `Proxy` contract from the `@openzeppelin/contracts` library.
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.2/contracts/proxy/Proxy.sol   
        assembly {
        // (1) copy incoming call data
        calldatacopy(0, 0, calldatasize())
        
        // (2) forward call to logic contract
        let result := 
            delegatecall(gas(), _implementation, 0, calldatasize(),0,0)  
        // (3) retrieve return data
        returndatacopy(0, 0, returndatasize())
        
        // (4) forward return data back to caller
        switch result
        case 0 {
            revert(0, returndatasize())
        }
        default {
            return(0, returndatasize())
        }
        }
    }

    function _fallback() private  {
         _delegate(_getImplementation());
    }

    receive() external payable {
        _fallback();
    }

    function upgradeTo(address _implementation) external ifAdmin {
        require(msg.sender == _getAdmin(),"not can upgradeTo");
        _setImplementation(_implementation);
    }

    function _getAdmin() private view returns (address){
        return StorageSlot.getAddressSlot(admin_slot).value;
    }

    function _setAdmin(address _address) private ifAdmin{
         StorageSlot.getAddressSlot(admin_slot).value = _address;
    }

    function _getImplementation() private view returns (address){
        return StorageSlot.getAddressSlot(implementation_slot).value;
    }

    function _setImplementation(address _address) private ifAdmin{
         StorageSlot.getAddressSlot(implementation_slot).value = _address;
    }

    function admin() external  ifAdmin  returns (address){
        return _getAdmin() ;
    }

    function implementation() external ifAdmin returns (address){
        return _getImplementation() ;
    }
}

contract ProxyAdmin{
    address public  owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not authorized");
        _;
    }

    function changeProxyAdmin(address payable proxy,address _admin) external onlyOwner{
        Proxy(proxy).changeAdmin(_admin);
    }

    function upgrade(address payable proxy,address _implentmetation) external onlyOwner{
                Proxy(proxy).upgradeTo(_implentmetation);
    }

    function getProxyAdmin(address proxy) external view returns (address){

        (bool ok,bytes memory res) =   proxy.staticcall(
            abi.encodeCall(Proxy.admin,())
        );
        require(ok,"staticcall error");
        return abi.decode(res,(address) );
    }

        function getProxyImplentmetation(address proxy) external view returns (address){

        (bool ok,bytes memory res) =   proxy.staticcall(
            abi.encodeCall(Proxy.implementation ,())
        );
        require(ok,"staticcall error");
        return abi.decode(res,(address) );
    }

}

library StorageSlot{
    struct AddressSlot{
        address value;
    }

    // 拿存储槽里的数据
    function getAddressSlot(bytes32 slot) internal pure returns(AddressSlot storage r){
        assembly{
            r.slot := slot
        }
    }
}

contract TestSlot{

    bytes32 public constant SLOT = keccak256("TEST_SLOT");

    function getSlot() external view returns (address){
        return StorageSlot.getAddressSlot(SLOT).value;
    }

    function writeSlot(address _slot) external {
        StorageSlot.getAddressSlot(SLOT).value = _slot;
    }
}

