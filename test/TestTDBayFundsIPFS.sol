// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TDBay.sol";
import "../contracts/TDBayToken.sol";
import "../contracts/UserProxies.sol";


contract TestTDBayFundsIPFS {
	
	uint public initialBalance = 1 ether;
	TDBay tdbcontract;
	IDesign designContract;
	//address payable tdbcontract;
	IERC20 public tc;
	uint pcost = 2000000;
	uint dcost = 1000000;
	uint mcost = 50000;

	uint fee = 4;
	uint feeRate = 1000;

	UserProxy theUser;

	constructor() public payable{}

	function beforeAll() public{
		tdbcontract = new TDBay();
		tc = IERC20(DeployedAddresses.TDBayToken());
		designContract = IDesign(new Design());

		tdbcontract.initializeTDBay(address(tc), address(designContract),
									pcost, dcost, mcost);

		designContract.setMaster(ITDBay(tdbcontract));

		theUser = new UserProxy(address(tdbcontract));
		address(theUser).transfer(.5 ether);

		string memory description = "Simply a test project with a short description";
		theUser.addProject("MyProject", description, pcost);
	}

	// Test withdrawal by the owner
	function testWithdrawal() public{
		uint initBalanceOwner = address(this).balance;
		uint initBalanceContract = address(tdbcontract).balance;
		uint _value = 1;
		tdbcontract.withdraw(_value);
		Assert.equal(address(tdbcontract).balance, 
					 initBalanceContract - _value, 
					 "Value not deduced.");
		Assert.equal(address(this).balance, 
			         initBalanceOwner + _value, 
			         "Value not deduced.");
	}

	// Test withdrawal failure, beacuse excess ammount
	function testWithdrawalExcess() public{
		uint _value = pcost * 2;
		(bool r, ) = address(tdbcontract).call(
			abi.encodeWithSignature("withdraw(uint256)",_value));
		Assert.isFalse(r, "Withdrawal should have failed because of ammount.");	
	}

	// Test withdrawal failure, beacuse not owner
	function testWithdrawalNotOwner() public{
		uint _value = 1;
		(bool r, ) = address(theUser).call(
			abi.encodeWithSignature("withdraw(uint256)", _value));
		Assert.isFalse(r, "Withdrawal should have failed because it is not the owner.");	
	} 

	// Test the update of the project description IPFS file/folder
	function testUpdateProjectFiles() public{
		string memory _hash = "QmSNBgrXsAV5gHHBmZzQMu4iWHAWnNc4wy4542bp53jKRA";
		theUser.updateProjectFiles(_hash, 0);

		(,,,,string memory _ipfsHash,,) = tdbcontract.projects(0);
		Assert.equal(_ipfsHash, _hash,
					 "Project IPFS hash not updated correctly");
	}

	function () external payable{}
}
