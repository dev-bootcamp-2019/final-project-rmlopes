// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/UserProxies.sol";


contract TestTDBayAcceptDesignModifiers2 {
	
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

	// Test failure accepting a design bid, design does not belong to the project
	function testAcceptDesignNotInProject() public{
		theUser = new UserProxy(address(tdbcontract));
		uint pid = 1;
		uint did = 0;
		
		string memory name = "MyProject";
		string memory description = "Simply a test project with a short description";
		theUser.addProject.value(pcost)(name, description, pcost);
		theUser.addProject.value(pcost)(name, description, pcost);

		designContract.addDesignBid.value(dcost)(0, 0.1 ether, "");

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
