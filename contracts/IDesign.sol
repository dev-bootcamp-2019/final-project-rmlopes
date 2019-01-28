pragma solidity ^0.5.0;

import "./ITDBay.sol";


interface IDesign {
    
    /** 
     * @dev Sets the TDBay master contract.
     * @param _tdbcontract The TDBay contract to use as master
     */
    function setMaster(ITDBay _tdbcontract) external; 
    
    /** 
     * @dev Accepts a design bid
     * @param _id The design bid id.
     */
    function acceptBid(uint256 _id) external;
    
    /** 
     * @dev Adds a design bid to a project.
     * @param _projectId The id of the target project.
     * @param _cost The cost to provide the complete design.
     */
    function addDesignBid(uint _projectId, uint256 _cost, string calldata _description) external payable;
    
    /**
     * @dev Check whether a design belongs to a project
     * @param _projectId the project id
     * @param _designId the design id
     * @return bool true if design belongs to project
     */
    function designInProject(uint256 _projectId, uint256 _designId) external returns (bool);

    /** 
     * @dev Gets the state of a design.
     * @param _id The id of the design.
     * @return uint256 the state of the bid
     */
    function getState(uint256 _id) external view returns (uint256);
    
    /** 
     * @dev Get the IPFS hash for the design CAD file/folder.
     * @param _id The id of the design.
     * @return string The IPFS Hash for the design CAD file/folder.
     */
    function getDesignFiles(uint256 _id) external view returns (string memory);
    
    /** 
     * @dev Get the cost for this contract bid.
     * @param _id The id of the design.
     * @return uint256 The cost to produce this design.
     */
    function getDesignCost(uint256 _id) external view returns(uint256);
    
    
}