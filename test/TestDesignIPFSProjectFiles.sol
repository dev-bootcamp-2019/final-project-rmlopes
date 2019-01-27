// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/UserProxies.sol";

contract TestDesignIPFSProjectFiles {

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

	// Tests updating the project CAD file/folder hash for an accepted design
	function testUpdateProjectFiles() public{
		string memory description = "Simply a test project with a short description";
		tdbcontract.addProject.value(pcost)("MyProject0",description, "");
		
		du1 = new DesignUserProxy(address(designContract));
		du1.addDesignBid.value(dcost)(0, 0.1 ether, "");
		uint designId = 0;
		
		tdbcontract.acceptDesign(0,designId);

		(bool r,) = address(du1).call(
			abi.encodeWithSignature("updateProjectFiles(uint256,string)",
									designId, IPFS_HASH));

		(,,,,,string memory _ipfsHash,,) = designContract.designs(designId);
		Assert.isTrue(r, "Call to updateProjectFiles should succeed.");
		Assert.equal(_ipfsHash, IPFS_HASH, 
					 "Project CAD file/folder not updated correctly.");
	}

	function () external payable{}
}
