// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/UserProxies.sol";


contract TestTDBayAddProjectNotEnoughFunds {
	
	uint public initialBalance = 1 ether;
	TDBay private tdbcontract;
	IDesign private designContract;
	IERC20 private  tc;
	uint private  pcost = 20000;
	uint private dcost = 10000;
	uint private mcost = 5000;

	UserProxy theUser;

	constructor() public payable{}

	function beforeAll() public{
		//must to do it like this because of Ownable
		tdbcontract = new TDBay();//
		//tdbcontract = TDBay(DeployedAddresses.TDBay());
		tc = IERC20(DeployedAddresses.TDBayToken());
		designContract = IDesign(new Design());

		tdbcontract.initializeTDBay(address(tc), address(designContract),
									pcost, dcost, mcost);

		designContract.setMaster(ITDBay(tdbcontract));
	}

	// Test failure if not enough funds are sent to create a project
	function testAddProjectNotEnoughFunds() public{
		string memory name = "MyProject";
		(bool r, ) = address(tdbcontract).call.value(1)(
			abi.encodeWithSignature("addProject(string,string,string)",name, "", ""));
		Assert.isFalse(r, "Project creation should have failed.");
	}

	function () external payable{}
}
