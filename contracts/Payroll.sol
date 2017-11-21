pragma solidity ^0.4.15;

contract Payroll{
  
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
    
    mapping(address=>Staff) staffs;
    mapping(string=>address) staffNames; 
    
    mapping(string=>mapping(address=>bool)) permissions;
    mapping(address=>UpdateRequest) updateRequests;
    
    uint totalStaffs;
    
    event PayrollFunded(indexed address,uint);
    event StaffPayed(indexed address,string,uint);
    
    
    function getStaffUnpaidHours(string name) public constant returns(uint){}
      
    function getStaffPaidHours(string name) public constant returns(uint){}
    
    function gettotalUnpaidHours(string name) public constant returns(uint){}
      
    function gettotalPaidHours(string name) public constant returns(uint){}
    
      
    
    
    
    function payStaff(string name,uint hours,uint rate) isStaffName(name) public {}
      
    function payBatchStaffs(uint count,uint hours,uint rate)public {}//Pay count number of staffs hours number of unpaidHours
      
    function payBatchStaffsAll(uint count,uint rate)public {}//Pay count number of staffs all unpaid 
      
    
      
    
    
    function setStaffNewAddress(address _addr) isStaff(msg.sender) public {}
      
    function setNewStaff() hasPermission(msg.sender,'add') public {}
      
    modifier hasPermission(_addr,task){
      require(permissions[task][_addr]);
      _;
    }
    
    modifier isStaff(address _addr){
      require(staffs[_addr].active);
      _;
    }
    
    modifier isStaffName(string name){
      require( staffs[ staffNames[name] ].active );
      _;
    }
    
    function()payable{}
      
    
}