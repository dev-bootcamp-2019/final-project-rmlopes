// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/UserProxies.sol";

contract TestDesignIPFSPreviewFilesModifiers {

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

	// Tests failure updating the preview file/folder with invalid hash
	function testUpdatePreviewInvalidHash() public{
		tdbcontract.addProject.value(pcost)("MyProject", "Simply a test project with a short description", "");

		du1 = new DesignUserProxy(address(designContract));
		du1.addDesignBid.value(dcost)(0, 0.1 ether, "");

		uint dId = 0;
		(bool r, ) = address(du1).call(
			abi.encodeWithSignature("updatePreview(uint256,string)", dId,""));
		Assert.isFalse(r, "Call should have failed because invalid ipfs hash.");		
	}

	// Tests failure updating the preview file/folder hash for a design bid when not called by the bidder
	function testUpdatePreviewOwnsDesign() public{
		uint dId = 0;
		du2 = new DesignUserProxy(address(designContract));
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
	
	function () external payable{}
}
