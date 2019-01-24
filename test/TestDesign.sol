// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/IDesign.sol";
import "../contracts/Design.sol";
import "../contracts/UserProxies.sol";

contract TestDesign {

	uint public initialBalance = 1 ether;
	TDBay public tdbContract;
	Design public designContract;
	IERC20 public tokenContract;
	DesignUserProxy public du1;
	uint public pcost;
	uint public dcost;
	uint public mcost;

	uint userInitBalance;
	uint contractInitBalance;
	uint walletInitBalance;

	constructor() public {
		pcost = 200000;
		dcost = 100000;
		mcost = 5000;
		tokenContract = IERC20(DeployedAddresses.TDBayToken());
		designContract = new Design();
		du1 = new DesignUserProxy(address(designContract));
	}

	function beforeAll() public{
		// Initialize TDBay contract
		tdbContract = new TDBay();
		tdbContract.initializeTDBay(address(tokenContract), 
									address(designContract),
									pcost, dcost, mcost);
		
		//Add a project to the TDBay contract
		//owner will be this test class
		string memory name = "MyProject";
		tdbContract.addProject.value(pcost)(name);
	}

	// Tests the initialization of the TDBay master contract
	function testSetMaster() public{
		designContract.setMaster(tdbContract);
		Assert.equal(designContract.getMaster(), 
					 address(tdbContract),
					 "TDBay contract not set properly");
	}

	// Tests adding a design bid to a project
	function testAddDesignBid() public{
		// The user is just a proxy, the funds are coming from this test
		userInitBalance = address(this).balance;
		contractInitBalance = address(designContract).balance;
		walletInitBalance = tdbContract.wallet().balance;

		(uint _fee, uint _rate) = designContract.designFee();
		uint256 _feeValue = (tdbContract.designBidCost() * _fee) / _rate;

		uint expectedId = 0;
		uint projId = 0;
		uint expectedState = 0;

		uint costToDesign = 0.1 ether;
		(bool r, ) = address(du1).call.value(dcost)(
			abi.encodeWithSignature("addDesignBid(uint256,uint256)",
									projId, costToDesign));

		Assert.isTrue(r, "Failure adding project");

		(uint _did, 
		 uint _projectId, 
		 uint _cost, 
		 Design.State _state, 
		 string memory _previewIpfsHash, 
		 string memory _ipfsHash) = designContract.designs(0);

		Assert.equal(_did, expectedId, "Design id not set properly");
		Assert.equal(_projectId, projId, 
					 "Corresponding project id not set properly");
		Assert.equal(_cost, costToDesign, 
			  		 "Design cost not set properly");
		Assert.equal(uint(_state), expectedState, 
			 		 "Design state (bid) not set properly");
		Assert.equal(_previewIpfsHash, "", 
					 "Preview IPFS hash not set properly");
		Assert.equal(_ipfsHash, "", 
					 "IPFS hash for the design files not set properly");

		// because the user is just a proxy, and this test is the owner of TDBay, the fee is deposited here as well
		Assert.equal(address(this).balance, userInitBalance - dcost + _feeValue, 
					 "User balance not as expected.");
		Assert.equal(address(designContract).balance, contractInitBalance + dcost - _feeValue, 
					 "User balance not as expected.");
	}

	// Tests the failure using modifier checkDesignBid when adding a design bid
	function testAddDesignBidNotEnoughFunds() public{
	 	uint projId = 0;

		uint costToDesign = 0.1 ether;
		//uint _projectId, uint256 _cost, string memory _previewIpfsHash, string memory _ipfsHash
		(bool r,) = address(du1).call.value(dcost-1)(
			abi.encodeWithSignature("addDesignBid(uint256,uint256)",
									projId, costToDesign));
		Assert.isFalse(r, "Call should have failed because of not enough funds.");
	}

	// Tests the failure using modifier projectExits when adding a design bid
	function testAddDesignBidProjectExists() public{
		uint projId = 1;

		uint costToDesign = 0.1 ether;
		(bool r,) = address(du1).call.value(dcost)(
			abi.encodeWithSignature("addDesignBid(uint256,uint256)",
									projId, 
									costToDesign));
		Assert.isFalse(r, "Call should have failed because of  invalid project.");
	}

	function () external payable{}
}
