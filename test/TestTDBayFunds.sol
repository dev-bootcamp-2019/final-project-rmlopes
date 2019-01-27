// TestTDBay.sol

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/UserProxies.sol";


contract TestTDBayFunds {
	
	uint public initialBalance = 1 ether;
	TDBay tdbcontract;
	IDesign designContract;
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

	// Test withdrawal by the owner
	function testWithdrawal() public{
		theUser = new UserProxy(address(tdbcontract));
		address(theUser).transfer(.5 ether);

		string memory description = "Simply a test project with a short description";
		theUser.addProject("MyProject", description, pcost);

		uint initBalanceOwner = address(this).balance;
		uint initBalanceContract = address(tdbcontract).balance;
		uint _value = 1;

		tdbcontract.toggleContractActive();
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

	function () external payable{}
}
