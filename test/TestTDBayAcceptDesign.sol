// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/UserProxies.sol";


contract TestTDBayAcceptDesign {
	
	uint public initialBalance = 1 ether;
	TDBay tdbcontract;
	IDesign designContract;
	//address payable tdbcontract;
	IERC20 public tc;
	uint pcost = 2000000;
	uint dcost = 1000000;
	uint mcost = 50000;

	UserProxy theUser;
	UserProxy u2;

	constructor() public payable{}

	function beforeAll() public{
		//must to do it like this because of Ownable
		tdbcontract = new TDBay();//
		//tdbcontract = TDBay(DeployedAddresses.TDBay());
		//tc = IERC20(DeployedAddresses.TDBayToken());
		designContract = IDesign(new Design());

		tdbcontract.initializeTDBay(address(tc), address(designContract),
									pcost, dcost, mcost);

		designContract.setMaster(ITDBay(tdbcontract));

		theUser = new UserProxy(address(tdbcontract));
		address(theUser).transfer(.5 ether);
		string memory description = "Simply a test project with a short description";
		theUser.addProject("TheUserProject", description, pcost);

		designContract.addDesignBid.value(dcost)(0, 0.1 ether,"");
	}

	// Test accepting a design bid
	function testAcceptDesign() public{
		uint pid = 0;
		uint did = 0;
		//DesignUserProxy du = DesignUserProxy(address(designContract));
		designContract.addDesignBid.value(dcost)(pid, 0.1 ether, "");
		theUser.acceptDesign(pid, did);
		(, TDBay.ProjectState _state,,,,uint256 _designId,) = tdbcontract.projects(pid);
		Assert.equal(_designId, did, "Design id no set properly");
		Assert.equal(uint256(_state), uint(TDBay.ProjectState.Manufacturing), 
					 "Project state not updated.");
	}

	// Test failure accepting a design bid, project does not exist
	function testAcceptDesignInvalidProject() public{
		uint pid = 10;
		uint did = 0;
		
		(bool r,) = address(theUser).call(
			abi.encodeWithSignature("acceptDesign(uint256,uint256)",pid, did));
		Assert.isFalse(r, "Accept design should have failed, project does not exist");
	}

	// Test failure accepting a design bid, project not in designing stage
	function testAcceptDesignNotDesigningStage() public{
		uint pid = 1;
		uint did = 0;
		
		(bool r,) = address(theUser).call(
			abi.encodeWithSignature("acceptDesign(uint256,uint256)",pid, did));
		Assert.isFalse(r, "Accept design should have failed, project not in designing stage");
	}


	// Test failure accepting a design bid, design does not belong to the project
	function testAcceptDesignNotInProject() public{
		uint pid = 1;
		uint did = 0;
		
		string memory name = "MyProject2";
		string memory description = "Simply a test project with a short description";
		theUser.addProject(name, description, pcost);

		(bool r,) = address(theUser).call(
			abi.encodeWithSignature("acceptDesign(uint256,uint256)",pid, did));
		Assert.isFalse(r, "Accept design should have failed, design does not belong to project");
	}


	// Test failure accepting a design bid, user does not own the project
	function testAcceptDesignNotProjectOwner() public{
		uint pid = 1;
		uint did = 0;
		
		u2 = new UserProxy(address(tdbcontract));
		designContract.addDesignBid.value(dcost)(pid, 0.1 ether, "");
		
		(bool r,) = address(u2).call(
			abi.encodeWithSignature("acceptDesign(uint256,uint256)",pid, did));
		Assert.isFalse(r, "Accept design should have failed, design does not belong to project");
	}

	function () external payable{}
}
