pragma solidity ^0.4.15;

import 'zeppelin/ownership/owned';

contract Payroll is Owned{
  
    struct Staff {
      bool active;
      string alias;
      uint perHour; //Fiat value perHour
      uint unpaidHours;
      uint paidHours;
      uint lastPaymentDate;
    }
    
    struct UpdateRequest{
      address add; //New address to be set
      bool status;
    }
    
    mapping(address=>Staff) public staffs;
    mapping(string=>address) public staffNames;
    address[] private staffAddreses;
    
    mapping(string=>mapping(address=>bool)) public permissions;
    mapping(address=>UpdateRequest) public updateRequests;
    
    uint totalPaidHours;
    uint totalUnpaidHours;
    
    
    event PayrollFunded(address indexed fundAddress,uint value);
    event StaffPayed(address indexed staffAddress,string alias,uint value);
    event StaffAdded(string alias,address staffAddress);
    event StaffAddressUpdated(string alias,address prvAddress,address newAddress);
    event storageEmptied(address staffAddress,uint value);
    
    
    function totalStaffs()public constant returns(uint){
      return staffAddreses.length;
    }
    
    function getStaffUnpaidHours(string alias) public constant returns(uint){
      return staffs[ staffNames[alias] ].unpaidHours;
    }
      
    function getStaffPaidHours(string alias) public constant returns(uint){
      return staffs[ staffNames[alias] ].paidHours;
    }
      
    
    function emptyStorage() generalPermission(msg.sender) public {}//Refund all remaining contract funds to the owner address
    
    
    
    function payStaff(string alias,uint numHours,uint rate) isStaffName(alias) public {}
      
    function payBatchStaffs(uint count,uint numHours,uint rate)public {}//Pay count number of staffs hours number of unpaidHours
      
    function payBatchStaffsAll(uint count,uint rate)public {}//Pay count number of staffs all unpaid
      
      
    
    function payAddressAmount(address _addr, uint value) internal{}//Actual function that transfers funds to staffs, should always be the last call in any function or set of functions
      
    
    function deletestaffAddress(address _addr) internal {}
      
    function setStaffNewAddress(address _addr) isStaff(msg.sender) public {}
      
    function updateStaffStatus(string alias)
      
    function setNewStaff() hasPermission(msg.sender,'add') public {}
      
      
    modifier hasPermission(_addr,task){
      require(permissions[task][_addr]);
      _;
    }
    
    modifier generalPermission(address _addr){
      require (owner == _addr || staffs[_addr].active);
      _;
    }
    
    modifier isStaff(address _addr){
      require(staffs[_addr].active);
      _;
    }
    
    modifier isStaffName(string alias){
      require( staffs[ staffNames[alias] ].active );
      _;
    }
    
    function()payable{}
      
    
}