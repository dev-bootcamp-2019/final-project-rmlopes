// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/UserProxies.sol";

contract TestDesignBalances {

	uint public initialBalance = 1 ether;
	TDBay public tdbContract;
	Design public designContract;
	IERC20 public tokenContract;
	DesignUserProxy public du1;
	uint public pcost;
	uint public dcost;
	uint public mcost;

	constructor() public {
		pcost = 200000;
		dcost = 100000;
		mcost = 5000;
		tokenContract = IERC20(DeployedAddresses.TDBayToken());
		designContract = new Design();
		du1 = new DesignUserProxy(address(designContract));
		
		tdbContract = new TDBay();
		tdbContract.initializeTDBay(address(tokenContract), 
									address(designContract),
									pcost, dcost, mcost);
	}

	function beforeAll() public{
		// Initialize TDBay contract
		
		//Add a project to the TDBay contract
		//owner will be this test class
		tdbContract.addProject.value(pcost)(
			"MyProject", 
			"Simply a test project with a short description", 
			"");
	}

	// Tests the initialization of the TDBay master contract
	function testSetMaster() public{
		designContract.setMaster(tdbContract);
		Assert.equal(designContract.getMaster(), 
					 address(tdbContract),
					 "TDBay contract not set properly");
	}

	// Tests the balances after adding a design bid to a project
	function testAddDesignBidBalances() public{
		// The user is just a proxy, the funds are coming from this test
		uint userInitBalance = address(this).balance;
		uint contractInitBalance = address(designContract).balance;
		//uint walletInitBalance = tdbContract.wallet().balance;

		(uint _fee, uint _rate) = designContract.designFee();
		uint256 _feeValue = (tdbContract.designBidCost() * _fee) / _rate;

		uint costToDesign = 0.1 ether;
		du1.addDesignBid.value(dcost)(0, costToDesign, "A description");

		//because the user is just a proxy, and this test is the owner of TDBay, the fee is deposited here as well
		Assert.equal(address(this).balance, userInitBalance - dcost + _feeValue, 
					 "User balance not as expected.");
		Assert.equal(address(designContract).balance, contractInitBalance + dcost - _feeValue, 
					 "Contract balance not as expected.");
	}

	function () external payable{}
}
