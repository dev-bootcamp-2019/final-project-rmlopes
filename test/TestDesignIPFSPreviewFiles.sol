// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/UserProxies.sol";

contract TestDesignIPFSPreviewFiles {

	uint public initialBalance = 1 ether;
	TDBay public tdbcontract;
	Design public designContract;
	IERC20 public tokenContract;
	DesignUserProxy du1;
	DesignUserProxy du2;
	uint private pcost;
	uint private dcost;
	uint private mcost;

	string constant PREVIEW_IPFS_HASH = "QmWuAbhX3Rp7WjeoJFZD86u9jX6ZJxWQSrQWqCuF5eJYeV";

	constructor() public {
		pcost = 20000;
		dcost = 10000;
		mcost = 5000;
		tokenContract = IERC20(DeployedAddresses.TDBayToken());
		designContract = new Design();

		tdbcontract = new TDBay();
		tdbcontract.initializeTDBay(address(tokenContract), address(designContract), pcost, dcost, mcost);

		designContract.setMaster(tdbcontract);
	}

	// Tests updating the preview file/folder hash for a design bid
	function testUpdatePreview() public{
		tdbcontract.addProject.value(pcost)("MyProject", "Simply a test project with a short description", "");

		du1 = new DesignUserProxy(address(designContract));
		du1.addDesignBid.value(dcost)(0, 0.1 ether, "");

		uint designId = 0;
		(bool r,) = address(du1).call(
			abi.encodeWithSignature("updatePreview(uint256,string)",
									designId, PREVIEW_IPFS_HASH));

		(,,,,string memory _previewHash,,,) = designContract.designs(designId);
		Assert.isTrue(r, "Call to updatePreview should succeed.");
		Assert.equal(_previewHash, PREVIEW_IPFS_HASH, 
					 "Preview file/folder not updated correctly.");

	}
	
	function () external payable{}
}
