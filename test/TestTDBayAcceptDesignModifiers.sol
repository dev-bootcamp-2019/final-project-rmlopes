// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/UserProxies.sol";


contract TestTDBayAcceptDesignModifiers {
	
	uint public initialBalance = 1 ether;
	TDBay private tdbcontract;
	IDesign private designContract;
	IERC20 private tc;
	uint private pcost = 20000;
	uint private dcost = 10000;
	uint private mcost = 5000;

	UserProxy theUser;
	UserProxy u2;

	constructor() public {
		tdbcontract = new TDBay();

		tc = IERC20(DeployedAddresses.TDBayToken());
		
		designContract = IDesign(new Design());

		tdbcontract.initializeTDBay(address(tc), address(designContract),
									pcost, dcost, mcost);

		designContract.setMaster(tdbcontract);
	}

	function beforeAll() public {
		theUser = new UserProxy(address(tdbcontract));
		string memory description = "Simply a test project with a short description";
		theUser.addProject.value(pcost)("TheUserProject", description, pcost);

		designContract.addDesignBid.value(dcost)(0, 0.1 ether, "");
		
		theUser.acceptDesign(0, 0);
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
		uint pid = 0;
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
		theUser.addProject.value(pcost)(name, description, pcost);

		(bool r,) = address(theUser).call(
			abi.encodeWithSignature("acceptDesign(uint256,uint256)",pid, did));
		Assert.isFalse(r, "Accept design should have failed, design does not belong to project");
	}


	// Test failure accepting a design bid, user does not own the project
	function testAcceptDesignNotProjectOwner() public{
		uint pid = 1;
		uint did = 0;
		
		u2 = new UserProxy(address(tdbcontract));
		
		(bool r,) = address(u2).call(
			abi.encodeWithSignature("acceptDesign(uint256,uint256)",pid, did));
		Assert.isFalse(r, "Accept design should have failed, design does not belong to project");
	}

	function () external payable{}
}
