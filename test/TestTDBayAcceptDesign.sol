// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/UserProxies.sol";


contract TestTDBayAcceptDesign {
	
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

	// Test accepting a design bid
	function testAcceptDesign() public{
		uint pid = 0;
		uint did = 0;

		theUser = new UserProxy(address(tdbcontract));
		string memory description = "Simply a test project with a short description";
		theUser.addProject.value(pcost)("TheUserProject", description, pcost);

		designContract.addDesignBid.value(dcost)(pid, 0.1 ether, "");

		theUser.acceptDesign(pid, did);

		(, TDBay.ProjectState _state,,,,uint256 _designId,) = tdbcontract.projects(pid);
		Assert.equal(_designId, did, "Design id no set properly");
		Assert.equal(uint256(_state), uint(TDBay.ProjectState.Manufacturing), 
					 "Project state not updated.");
	}

	function () external payable{}
}
