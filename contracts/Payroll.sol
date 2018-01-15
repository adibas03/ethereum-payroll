pragma solidity ^0.4.15;

import 'zeppelin/contracts/ownership/Ownable.sol';
import 'zeppelin/contracts/token/ERC20.sol';
import 'safeMath.sol';

contract Payroll is Ownable{

    struct Staff {
      uint index;
      bool active;
      string alias;
      uint perHour; //Fiat value perHour
      uint paidHours;
      uint unpaidHours;
      uint lastPaymentDate;
    }

    struct UpdateRequest{
      address add; //New address to be set
      bool status;
    }

    mapping(address=>Staff) public staffs;
    mapping(string=>address) private staffNames;
    address[] private staffAddreses;

    mapping(string=>mapping(address=>bool)) private permissions;
    mapping(address=>UpdateRequest) public updateRequests;

    uint rateDecimal = 2;
    uint totalPaidHours;

    event PayrollFunded(address indexed fundAddress,uint value, uint timestamp);
    event StaffPayed(address indexed staffAddress,uint value, uint exchangeRate);
    event StaffAdded(string alias,address staffAddress);
    event StaffAddressUpdated(string alias,address prvAddress,address newAddress);
    event StaffStatusUpdated(address indexed staffAddress,bool prvStatus,bool newStatus);
    event StorageEmptied(address staffAddress,uint value);
    event TokensWithdrawn(address staffAddress, address tokenAddress, uint value);

    function Payroll() public {
      permissions['add'][msg.sender] = true;
      permissions['update'][msg.sender] = true;
      permissions['pay'][msg.sender] = true;
    }

    function totalStaffs()public view returns(uint){
      return staffAddreses.length;
    }

    function getStaffPaidHours(string alias) public view returns(uint){
      return staffs[ staffNames[alias] ].paidHours;
    }

    function calculateUserEthPerHour(address _addr,uint _exchangeRate) public view returns (uint){
      require(_exchangeRate>0);
      (staffs[_addr].perHour*1 ether)/(_exchangeRate*10**rateDecimal);
    }

    function emptyStorage() generalPermission(msg.sender) public {
        StorageEmptied(msg.sender , this.balance);
        owner.transfer(this.balance);
      }//Refund all remaining contract funds to the owner address

    function withdrawToken(address _addr) generalPermission(msg.sender) public {
        ERC20 token = ERC20(_addr);
        uint bal = token.balanceOf(this);
        TokensWithdrawn(msg.sender ,_addr);
        token.transfer(owner, bal);
      }//Refund all remaining contract funds to the owner address



    function payStaff(string alias,uint numHours,uint _exchangeRate) isStaffName(alias) public {
      require(staffNames[alias] != 0x0 );
      payAddressAmount( staffNames[alias], numHours, _exchangeRate);
    }

    function payBatchStaffs(uint firstIndex, uint count,uint numHours,uint _exchangeRate)public {//Pay count number of staffs hours number of unpaidHours
        require(staffAddreses.length >= (firstIndex+count) );
        for(uint s=firstIndex;s<(firstIndex+count); s++){
          payAddressAmount( staffAddreses[s], numHours, _exchangeRate);
        }
    }

    function payAddressAmount(address _addr, uint totHours, uint _exchangeRate) internal hasPermission(msg.sender,'pay'){//Actual function that transfers funds to staffs, should always be the last call in any function or set of functions
        require( staffs[_addr].active == true);
        uint perHour = calculateUserEthPerHour(_addr,_exchangeRate);
        uint totalDue = totHours*perHour;
        require(this.balance >= totalDue);
        totalPaidHours += totHours;
        staffs[_addr].paidHours += totHours;
        staffs[_addr].lastPaymentDate = block.timestamp;
        StaffPayed( _addr,totalDue, _exchangeRate);
        _addr.transfer(totalDue);
    }


    function updateStaffStatus(string alias, bool _active) hasPermission(msg.sender,'update') public {
      address _addr = staffNames['_alias'];
      StaffStatusUpdated(_addr, staffs[_addr].active, _active);
      staffs[_addr].active = _active;
    }

    function deletestaffAddress(address _addr) internal {

    }

    function setStaffNewAddress(address _addr) isStaff(msg.sender) public {

    }



    function setNewStaff(string _alias, address _addr, uint _rate) hasPermission(msg.sender,'add') public {
      require(_rate > 0);
      uint count = staffAddreses.length;
      staffAddreses.push(_addr);
      staffNames['_alias'] = _addr;
      staffs[_addr] = Staff(count,true,_alias,_rate,0,0,0);
      StaffAdded( _alias, _addr);
    }


    modifier hasPermission(address _addr,string task){
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

    function()payable public {
      PayrollFunded(msg.sender,msg.value,block.timestamp);
    }


}
