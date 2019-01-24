// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/IDesign.sol";
import "../contracts/Design.sol";
import "../contracts/UserProxies.sol";

contract TestDesignIPFS {

	uint public initialBalance = 1 ether;
	TDBay public tdbcontract;
	Design public designContract;
	IERC20 public tokenContract;
	DesignUserProxy du1;
	DesignUserProxy du2;
	uint public pcost;
	uint public dcost;
	uint public mcost;

	string constant IPFS_HASH = "QmSNBgrXsAV5gHHBmZzQMu4iWHAWnNc4wy4542bp53jKRA";
	string constant PREVIEW_IPFS_HASH = "QmWuAbhX3Rp7WjeoJFZD86u9jX6ZJxWQSrQWqCuF5eJYeV";

	constructor() public {
		pcost = 200000;
		dcost = 100000;
		mcost = 5000;
		tokenContract = IERC20(DeployedAddresses.TDBayToken());
		designContract = new Design();
		du1 = new DesignUserProxy(address(designContract));
		du2 = new DesignUserProxy(address(designContract));
	}

	function beforeAll() public{
		tdbcontract = new TDBay();
		tdbcontract.initializeTDBay(address(tokenContract), 
									address(designContract),
									pcost, dcost, mcost);

		//Add a project to the TDBay contract
		//owner will be this test class
		string memory name = "MyProject0";
		tdbcontract.addProject.value(pcost)(name);

		designContract.setMaster(tdbcontract);
		//Add two design bids
		du1.addDesignBid.value(dcost)(0, 0.1 ether);
		du1.addDesignBid.value(dcost)(0, 0.1 ether);
	}

	// Tests updating the preview file/folder hash for a design bid
	function testUpdatePreview() public{
		uint designId = 0;
		(bool r,) = address(du1).call(
			abi.encodeWithSignature("updatePreview(uint256,string)",
									designId, PREVIEW_IPFS_HASH));

		(,,,,string memory _previewHash,) = designContract.designs(designId);
		Assert.isTrue(r, "Call to updatePreview should succeed.");
		Assert.equal(_previewHash, PREVIEW_IPFS_HASH, 
					 "Preview file/folder not updated correctly.");

	}

	// Tests failure updating the preview file/folder with invalid hash
	function testUpdatePreviewInvalidHash() public{
		uint dId = 0;
		(bool r, ) = address(du1).call(
			abi.encodeWithSignature("updatePreview(uint256,string)", dId,""));
		Assert.isFalse(r, "Call should have failed because invalid ipfs hash.");		
	}

	// Tests failure updating the preview file/folder hash for a design bid when not called by the bidder
	function testUpdatePreviewOwnsDesign() public{
		uint dId = 0;
		(bool r, ) = address(du2).call(
			abi.encodeWithSignature("updatePreview(uint256,string)", 
		 							dId,PREVIEW_IPFS_HASH));
		Assert.isFalse(r, "Call sould have failed because user does not own the design.");		
	}

	// Tests failure updating the preview file/folder hash for a design that was already accepted
	function testUpdatePreviewIsNotBid() public{
		uint pid = 0;
		uint designId = 0;
		tdbcontract.acceptDesign(pid, designId);
		
		(bool r,) = address(du1).call(
			abi.encodeWithSignature("updatePreview(uint256,string)",
									designId, PREVIEW_IPFS_HASH));

		Assert.isFalse(r, "Call to updatePreview should fail, not bid anymore.");
	}

	// Tests updating the project CAD file/folder hash for an accepted design
	function testUpdateProjectFiles() public{
		uint designId = 0;

		(bool r,) = address(du1).call(
			abi.encodeWithSignature("updateProjectFiles(uint256,string)",
									designId, IPFS_HASH));

		(,,,,,string memory _ipfsHash) = designContract.designs(designId);
		Assert.isTrue(r, "Call to updateProjectFiles should succeed.");
		Assert.equal(_ipfsHash, IPFS_HASH, 
					 "Project CAD file/folder not updated correctly.");
	}

	// Tests failure updating the project CAD file/folder hash for an accepted design when not called by the designer
	function testUpdateProjectFilesOwnsDesign() public{
		uint designId = 0;

		(bool r,) = address(du2).call(
			abi.encodeWithSignature("updateProjectFiles(uint256,string)",
									designId, IPFS_HASH));

		Assert.isFalse(r, "Call to updateProjectFiles should have failed because user does not own the design.");
	}

	// Tests failure updating the project CAD file/folder hash for a design not yet accepted
	function testUpdateProjectFilesNotAccepted() public{
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
