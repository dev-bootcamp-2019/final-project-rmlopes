pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";


contract TDBayToken is IERC20, ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable {

    string private _name = "3DBayToken";
    string private _symbol = "3DB";
    uint8 private _decimals = 2;
    uint public constant INITIAL_SUPPLY = 100000;

    constructor() public 
        ERC20()
        ERC20Detailed(_name, _symbol, _decimals)
        ERC20Mintable()
        ERC20Burnable() {
        mint(msg.sender, INITIAL_SUPPLY);
    }
}
