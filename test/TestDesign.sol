// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
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

	constructor() public {
		pcost = 20000;
		dcost = 10000;
		mcost = 5000;
		tokenContract = IERC20(DeployedAddresses.TDBayToken());
		designContract = new Design();
	}

	function beforeAll() public{
		// Initialize TDBay contract
		tdbContract = new TDBay();
		tdbContract.initializeTDBay(address(tokenContract), 
									address(designContract),
									pcost, dcost, mcost);
		
		//Add a project to the TDBay contract
		//owner will be this test class
		tdbContract.addProject.value(pcost)(
			"MyProject", 
			"Simply a test project with a short description", 
			"");
		designContract.setMaster(tdbContract);
	}

	// Tests adding a design bid to a project
	function testAddDesignBid() public{
		uint costToDesign = 0.1 ether;

		du1 = new DesignUserProxy(address(designContract));
		du1.addDesignBid.value(dcost)(0, costToDesign, "A description");

		(uint _did, uint _projectId, 
		 uint _cost, Design.State _state, 
		 string memory _previewIpfsHash, 
		 string memory _ipfsHash,
		 address _owner, string memory _description) = designContract.designs(0);

		Assert.equal(_did, 0, "Design id not set properly");
		Assert.equal(_projectId, 0, "Corresponding project id not set properly");
		Assert.equal(_cost, costToDesign, "Design cost not set properly");
		Assert.equal(uint(_state), 0, "Design state (bid) not set properly");
		Assert.equal(_previewIpfsHash, "", "Preview IPFS hash not set properly");
		Assert.equal(_ipfsHash, "", "IPFS hash for the design files not set properly");
		Assert.equal(_owner, address(du1), "Owner no set properly");
		Assert.equal(_description, "A description", "Description no set properly");
	}

	function () external payable{}
}
