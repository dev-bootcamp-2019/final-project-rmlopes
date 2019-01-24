pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./TDBayToken.sol";
import "./IDesign.sol";


/** 
 * @title TDBay (3DBay). 
 * @author Rui L. Lopes
 */
interface ITDBay {

    struct Fee {
        uint256 fee;
        uint256 rate;    
    }
    
    /** 
     * @dev Returns the design bid cost
     * @return _designBidCost The project design bid cost
     */
    function designBidCost() external view returns(uint256);
    
    /** @dev Get the number of projects created 
      * @return The numebr of projects created (currentId)
      */
    function getNumProjects() external view returns (uint256);

    /** @dev Get the wallet for withdrawals (avoid locked funds) 
      * @return The wallet address
      */
    function wallet() external view returns (address payable);
}