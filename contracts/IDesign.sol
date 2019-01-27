pragma solidity ^0.5.0;

import "./ITDBay.sol";


interface IDesign {
    
    function setMaster(ITDBay _tdbcontract) external; 
    
    function acceptBid(uint256 _id) external;
    
    function addDesignBid(uint _projectId, uint256 _cost, string calldata _description) external payable;
    
    function designInProject(uint256 _projectId, uint256 _designId) external returns (bool);

    function getState(uint256 _id) external view returns (uint256);
    
    function getDesignFiles(uint256 _id) external view returns (string memory);
    
    function getDesignCost(uint256 _id) external view returns(uint256);
    
    
}