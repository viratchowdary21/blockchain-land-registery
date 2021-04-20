pragma solidity ^0.5.0;

contract asset {

    address public creatorAdmin;
	enum Status { NotExist, Pending, Approved, Rejected }

	struct PropertyDetail {
		Status status;
		uint value;
		address currOwner;
	}

	
	mapping(uint => PropertyDetail) public properties;
	mapping(uint => address) public propOwnerChange;

    mapping(address => int) public users;
    mapping(address => bool) public verifiedUsers;

	modifier onlyOwner(uint _propId) {
		require(properties[_propId].currOwner == msg.sender);
		_;
	}

	modifier verifiedUser(address _user) {
	    require(verifiedUsers[_user]);
	    _;
	}

	modifier verifiedAdmin() {
		require(users[msg.sender] >= 2 && verifiedUsers[msg.sender]);
		_;
	}

	modifier verifiedSuperAdmin() {
	    require(users[msg.sender] == 3 && verifiedUsers[msg.sender]);
	    _;
	}

	
     constructor  ()  public {
		creatorAdmin = msg.sender;
		users[creatorAdmin] = 3;
		verifiedUsers[creatorAdmin] = true;
	}

	
 function createProperty(uint _propId, uint _value, address _owner) verifiedAdmin verifiedUser(_owner) public returns (bool)  {
		properties[_propId] = PropertyDetail(Status.Pending, _value, _owner);
		return true;
	}

	
    	function approveProperty(uint _propId) verifiedSuperAdmin public returns (bool)  {
		require(properties[_propId].currOwner != msg.sender);
		properties[_propId].status = Status.Approved;
		return true;
	}

	
	 function rejectProperty(uint _propId) verifiedSuperAdmin public returns (bool)  {
		require(properties[_propId].currOwner != msg.sender);
		properties[_propId].status = Status.Rejected;
		return true;
	}

	
	function changeOwnership(uint _propId, address _newOwner) onlyOwner(_propId) verifiedUser(_newOwner) public returns (bool)  {
		require(properties[_propId].currOwner != _newOwner);
		require(propOwnerChange[_propId] == address(0));
		propOwnerChange[_propId] = _newOwner;
		return true;
	}

	
	 function approveChangeOwnership(uint _propId) verifiedSuperAdmin public returns (bool)  {
	    require(propOwnerChange[_propId] != address(0));
	    properties[_propId].currOwner = propOwnerChange[_propId];
	    propOwnerChange[_propId] = address(0);
	    return true;
	}

	
     function changeValue(uint _propId, uint _newValue) onlyOwner(_propId) public returns (bool)  {
        require(propOwnerChange[_propId] == address(0));
        properties[_propId].value = _newValue;
        return true;
    }

	
	 function getPropertyDetails(uint _propId) view public returns (Status, uint, address)  {
		return (properties[_propId].status, properties[_propId].value, properties[_propId].currOwner);
	}

	
	 function addNewUser(address _newUser) verifiedAdmin public returns (bool)  {
	    require(users[_newUser] == 0);
	    require(verifiedUsers[_newUser] == false);
	    users[_newUser] = 1;
	    return true;
	}

	
	 function addNewAdmin(address _newAdmin) verifiedSuperAdmin public returns (bool)  {
	    require(users[_newAdmin] == 0);
	    require(verifiedUsers[_newAdmin] == false);
	    users[_newAdmin] = 2;
	    return true;
	}

	
	 function addNewSuperAdmin(address _newSuperAdmin) verifiedSuperAdmin public returns (bool)  {
	    require(users[_newSuperAdmin] == 0);
	    require(verifiedUsers[_newSuperAdmin] == false);
	    users[_newSuperAdmin] = 3;
	    return true;
	}

	
	 function approveUsers(address _newUser) verifiedSuperAdmin public returns (bool)  {
	    require(users[_newUser] != 0);
	    verifiedUsers[_newUser] = true;
	    return true;
	}
}