// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/UserProxies.sol";


contract TestTDBay {
	
	uint public initialBalance = 1 ether;
	TDBay tdbcontract;
	IDesign designContract;
	//address payable tdbcontract;
	IERC20 public tc;
	uint pcost = 2000000;
	uint dcost = 1000000;
	uint mcost = 50000;

	uint fee = 4;
	uint feeRate = 1000;

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

		theUser = new UserProxy(address(tdbcontract));
		address(theUser).transfer(.5 ether);
	}

	/** Test if the initialization is setting the bid values, 
	  * and minting correctly the initial tokens
	  */
	function testInitialize() public{
		Assert.equal(tdbcontract.projectCost(), pcost,
					 "Project cost not set properly");
		Assert.equal(tdbcontract.designBidCost(), dcost,
					 "Design bid cost not set properly");
		Assert.equal(tdbcontract.manufactureBidCost(), mcost,
					 "Manufacture bid cost not set properly");

		//IERC20 tc = TDBayToken(tdbcontract.tokenContract());
		Assert.equal(tc.balanceOf(msg.sender),tc.totalSupply(),
					 "Initial tokens not minted to the correct address");
	}

	// Test the update of the costs
	function testSetProjectCreationFee() public{
		tdbcontract.setProjectCreationFee(fee,feeRate);
		(uint256 _fee, uint256 _rate) = tdbcontract.projectFee();
		Assert.equal(_fee, fee, "Fee not set properly");
		Assert.equal(_rate, feeRate, "Fee not set properly");
	}

	// Test if the a new project is created correctly
	function testAddProject() public{
		uint initBalanceContract = address(tdbcontract).balance;
		uint initOwnerBalance = address(this).balance;
		uint initUserBalance = address(theUser).balance;

		string memory name = "MyProject";
		string memory description = "Simply a test project with a short description \n but including new lines";
		uint expectedId = 0;
		uint expectedFee  = pcost * fee / feeRate;
		//tdbcontract.addProject.value(pcost)(name);
		theUser.addProject(name, description, pcost);

		(uint _id, ,string memory _name, address payable _owner,,,) = tdbcontract.projects(0);
		Assert.equal(_name, name, "Project name not set properly.");
		Assert.equal(_id, expectedId, "Project id not set properly.");
		Assert.equal(_owner, address(theUser), "Project owner not set properly.");

		//Check contract balance after creating project
		Assert.equal(address(tdbcontract).balance, 
					 initBalanceContract + pcost - expectedFee, 
					 "Project cost funds not stored in contract.");

		Assert.equal(address(this).balance, 
					 initOwnerBalance + expectedFee, 
					 "Project fee not transfered to owner.");

		Assert.equal(address(theUser).balance, 
					 initUserBalance - pcost, 
					 "Project cost funds not deduced from user.");

		//Check user projects mapping

	}

	// Test if the a new project is created correctly
	function testAddProjectNotEnoughFunds() public{
		string memory name = "MyProject";
		(bool r, ) = address(tdbcontract).call.value(1)(
			abi.encodeWithSignature("addProject(string, string)",name));
		Assert.isFalse(r, "Project creation should have failed.");
	}

	// Test the update of the costs
	function testSetCosts() public{
		pcost = 4000000;
		dcost = 2000000;
		mcost = 1000000;	

		tdbcontract.setProjectCost(pcost);
		Assert.equal(tdbcontract.projectCost(), pcost,
					 "Project cost not updated properly");

		tdbcontract.setDesignBidCost(dcost);
		Assert.equal(tdbcontract.designBidCost(), dcost,
					 "Design bid cost not updated properly");

		tdbcontract.setManufactureBidCost(mcost);
		Assert.equal(tdbcontract.manufactureBidCost(), mcost,
					 "Manufacture bid cost not updated properly");
	}

	function () external payable{}
}
