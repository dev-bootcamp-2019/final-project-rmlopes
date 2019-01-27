// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/IDesign.sol";
import "../contracts/Design.sol";
import "../contracts/UserProxies.sol";

contract TestDesignIPFSProjectFilesModifiers {

	uint public initialBalance = 1 ether;
	TDBay public tdbcontract;
	Design public designContract;
	IERC20 public tokenContract;
	DesignUserProxy du1;
	DesignUserProxy du2;

	uint private pcost = 20000;
	uint private dcost = 10000;
	uint private mcost = 5000;

	string constant IPFS_HASH = "QmSNBgrXsAV5gHHBmZzQMu4iWHAWnNc4wy4542bp53jKRA";

	constructor() public {
		tokenContract = IERC20(DeployedAddresses.TDBayToken());
		designContract = new Design();

		tdbcontract = new TDBay();
		tdbcontract.initializeTDBay(address(tokenContract), 
									address(designContract),
									pcost, dcost, mcost);
		
		designContract.setMaster(tdbcontract);
	}

	// Tests failure updating the project CAD file/folder hash for an accepted design when not called by the designer
	function testUpdateProjectFilesOwnsDesign() public{
		string memory description = "Simply a test project with a short description";
		tdbcontract.addProject.value(pcost)("MyProject0",description, "");
		
		du1 = new DesignUserProxy(address(designContract));
		du1.addDesignBid.value(dcost)(0, 0.1 ether, "");
		uint designId = 0;

		du2 = new DesignUserProxy(address(designContract));

		(bool r,) = address(du2).call(
			abi.encodeWithSignature("updateProjectFiles(uint256,string)",
									designId, IPFS_HASH));

		Assert.isFalse(r, "Call to updateProjectFiles should have failed because user does not own the design.");
	}

	// Tests failure updating the project CAD file/folder hash for a design not yet accepted
	function testUpdateProjectFilesNotAccepted() public{
		 du1.addDesignBid.value(dcost)(0, 0.1 ether, "");
		 uint designId = 1;

		(bool r,) = address(du1).call(
			abi.encodeWithSignature("updateProjectFiles(uint256,string)",
									designId, IPFS_HASH));

		Assert.isFalse(r, "Call to updateProjectFiles should have failed because not accepted yet.");
	}
	
	// Tests failure updating the project CAD file/folder hash with invalid hash
	function testUpdateProjectInvalidHash() public{
		uint designId = 0;
		(bool r, ) = address(du1).call(
			abi.encodeWithSignature("updateProjectFiles(uint256,string)", designId,""));
		Assert.isFalse(r, "Call should have failed because invalid ipfs hash.");
	}
	
	function () external payable{}
}
