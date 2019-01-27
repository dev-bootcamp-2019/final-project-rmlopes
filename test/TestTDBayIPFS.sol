// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/UserProxies.sol";


contract TestTDBayIPFS {
	
	uint public initialBalance = 1 ether;
	TDBay tdbcontract;
	IDesign designContract;
	//address payable tdbcontract;
	IERC20 public tc;
	uint private pcost = 2000000;
	uint private dcost = 1000000;
	uint private mcost = 50000;

	UserProxy private theUser;

	constructor() public{
		tdbcontract = new TDBay();
		tc = IERC20(DeployedAddresses.TDBayToken());
		designContract = IDesign(new Design());

		tdbcontract.initializeTDBay(address(tc), address(designContract),
									pcost, dcost, mcost);

		designContract.setMaster(ITDBay(tdbcontract));
	}

	// Test the update of the project description IPFS file/folder
	function testUpdateProjectFiles() public{
		theUser = new UserProxy(address(tdbcontract));
		address(theUser).transfer(.5 ether);

		string memory description = "Simply a test project with a short description";
		theUser.addProject("MyProject", description, pcost);

		string memory _hash = "QmSNBgrXsAV5gHHBmZzQMu4iWHAWnNc4wy4542bp53jKRA";
		theUser.updateProjectFiles(_hash, 0);

		(,,,,string memory _ipfsHash,,) = tdbcontract.projects(0);
		Assert.equal(_ipfsHash, _hash,
					 "Project IPFS hash not updated correctly");
	}

	function () external payable{}
}
