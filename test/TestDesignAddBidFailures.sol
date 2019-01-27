// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/IDesign.sol";
import "../contracts/Design.sol";
import "../contracts/UserProxies.sol";

contract TestDesignAddBidFailures {

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

		designContract.setMaster(tdbContract);
	}

	function beforeAll() public{
		string memory name = "MyProject";
		string memory description = "Simply a test project with a short description";
		tdbContract.addProject.value(pcost)(name, description, "");
	}

	// Tests the failure using modifier checkDesignBid when adding a design bid
	function testAddDesignBidNotEnoughFunds() public{
	 	uint projId = 0;

		uint costToDesign = 0.1 ether;
		//uint _projectId, uint256 _cost, string memory _previewIpfsHash, string memory _ipfsHash
		(bool r,) = address(du1).call.value(dcost-1)(
			abi.encodeWithSignature("addDesignBid(uint256,uint256,string)",
									projId, costToDesign, ""));
		Assert.isFalse(r, "Call should have failed because of not enough funds.");
	}

	// Tests the failure using modifier projectExits when adding a design bid
	function testAddDesignBidProjectExists() public{
		uint projId = 1;

		uint costToDesign = 0.1 ether;
		(bool r,) = address(du1).call.value(dcost)(
			abi.encodeWithSignature("addDesignBid(uint256,uint256,string)",
									projId, 
									costToDesign));
		Assert.isFalse(r, "Call should have failed because of  invalid project.");
	}

	function () external payable{}
}
