pragma solidity 0.5.0;

import "./IDesign.sol";
import "./ITDBay.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


/** 
 * @title Design 
 * @author Rui L. Lopes
 */
contract Design is IDesign, Ownable {
    
    using SafeMath for uint256;
    
    enum State { Bid, Accepted }

    struct ProjectDesign {
        uint256 id;
        uint256 projectId;
        uint256 cost;
        State state;
        string previewIpfsHash; 
        string ipfsHash;
        address owner;
        string description;
    }

    uint256 public currentId;
    ITDBay public tdbContract;
    ProjectDesign[] public designs;
    mapping (uint256 => mapping(uint256 => bool)) public projectToDesigns;
    mapping (uint256 => uint256[]) public projectToDesignList;
    mapping (address => uint256[]) public ownerToDesignList;

    ITDBay.Fee public designFee = ITDBay.Fee(1,1000);
    
    event DesignBidAccepted(uint256 indexed _id);
    event DesignFeeTransfered(uint256 _fee);
    event UpdatedFiles(uint256 indexed _id, string _hash);
    event UpdatedPreview(uint256 indexed _id, string _hash);

    /** 
     * @dev Checks if the design bid was accepted.
     * @param _id The id of the design
     */
    modifier isAccepted(uint256 _id) {
        require(designs[_id].state == State.Accepted,
                "Contract not accepted yet");
        _;
    }

    /** 
     * @dev Checks if the design is still a bid.
     * @param _id The id of the design
     */
    modifier isBid(uint256 _id) {
        require(designs[_id].state == State.Bid,
                "Contract was already accepted");
        _;
    }

    /** 
     * @dev Checks if the caller owns the design
     * @param _caller The address of the caller
     * @param _id The id of the design
     */
    modifier ownsDesign(address _caller, uint256 _id) {
        require(_caller == designs[_id].owner,
                "User does not own this design");
        _;
    }

    /** 
     * @dev Checks if a design bid exists
     * @param _id The design bid id
     */
    modifier bidExists(uint256 _id) {
        require(_id < currentId,
                "The design bid id is invalid.");
        _;
    }

    /** 
     * @dev Checks if a project exists in the TDBay contract
     * @param _id The project id
     */
    modifier projectExists(uint256 _id) {
        require(_id < tdbContract.getNumProjects(),
                "The project does not exist in the TDBay contract");
        _;
    }

    /** 
     * @dev Checks if the caller is the project owner
     * @param _id The project id
     */
    modifier isProjectOwner(address _caller, uint256 _id) {
        require(_caller == tdbContract.getProjectOwner(_id),
                "The caller is not the project owner");
        _;
    }


    /** 
     * @dev Checks if enough was sent to bid with a design
     * @param _value The value sent to post a bid
     */
    modifier checkDesignBidValue(uint256 _value) {
        require(_value >= tdbContract.designBidCost(),
                "Value not enough to bid for design in a project");
        _;
    }

    /** 
     * @dev Checks if the design contract was accepted.
     * @param _address The address of the caller
     */
    modifier isMaster(address _address) {
        require(_address == address(tdbContract),
                "Caller is not the master  TDBay contract");
        _;
    }

    constructor() public {}

    function () external {}

    /** @dev Allows the owner to withdraw from the contracts balance into the master wallet
      * @param _value The value to withdraw
      */
    function withdraw(uint256 _value) external onlyOwner() {
        require(_value <= address(this).balance,
                "Not enough balance to withdraw.");
        tdbContract.wallet().transfer(_value);
    }

    /** 
     * @dev Adds a design bid to a project.
     * @param _projectId The id of the target project.
     * @param _cost The cost to provide the complete design.
     */
    function addDesignBid(uint _projectId, uint256 _cost, string calldata description) 
        external
        payable
        checkDesignBidValue(msg.value)
        projectExists(_projectId)
    {
        ProjectDesign memory d = 
            ProjectDesign(currentId, _projectId, _cost, State.Bid, "", "", msg.sender, description);
        designs.push(d);
        projectToDesigns[_projectId][d.id] = true;
        projectToDesignList[_projectId].push(d.id);
        ownerToDesignList[address(msg.sender)].push(d.id);
        currentId++;

        uint256 _fee = tdbContract.designBidCost().mul(designFee.fee).div(designFee.rate);
        tdbContract.wallet().transfer(_fee); 
        emit DesignFeeTransfered(_fee);
    }

    /**
     * @dev Gets the design ids for a given project
     * @param _projectId the project id
     * @return uint256[] The list of design ids for a project
     */
    function getDesigns(uint256 _projectId) public view
        projectExists(_projectId)
        isProjectOwner(address(msg.sender), _projectId) 
        returns(uint256[] memory){
        //TODO: verify project owner is calling
        return projectToDesignList[_projectId];
    }

    /**
     * @dev Gets the design ids for the caller
     * @return uint256[] The list of design ids for the caller
     */
    function getOwnerDesigns() public view
        returns(uint256[] memory){
        //TODO: verify project owner is calling
        return ownerToDesignList[address(msg.sender)];
    }

    /**
     * @dev Check whether a design belongs to a project
     * @param _projectId the project id
     * @param _designId the design id
     * @return bool true if design belongs to project
     */
    function designInProject(uint256 _projectId, uint256 _designId) 
        external
        returns (bool)
    {
        return projectToDesigns[_projectId][_designId];
    }

    /** 
     * @dev Sets the TDBay master contract.
     * @param _tdbcontract The TDBay contract to use as master
     */
    function setMaster(ITDBay _tdbcontract) external onlyOwner() {
        tdbContract = _tdbcontract;
    }

    /* * 
     * @dev Accepts a design bid
     * @param _id The design bid id.
     */
    function acceptBid(uint256 _id) 
        external
        isMaster(msg.sender)
        isBid(_id)
    {
        designs[_id].state = State.Accepted;
        emit DesignBidAccepted(_id);
    }

    /** 
     * @dev Gets the state of a design.
     * @param _id The id of the design.
     * @return uint256 the state of the bid
     */
    function getState(uint256 _id) external view bidExists(_id) returns (uint256) {
        return uint256(designs[_id].state);
    }

    /** 
     * @dev Get the IPFS hash for the design CAD file/folder.
     * @param _id The id of the design.
     * @return string The IPFS Hash for the design CAD file/folder.
     */
    function getDesignFiles(uint256 _id) external view bidExists(_id) returns (string memory) {
        return designs[_id].ipfsHash;
    }

    /** 
     * @dev Get the IPFS hash for the design CAD file/folder.
     * @param _id The id of the design.
     * @return string The IPFS Hash for the design CAD file/folder.
     */
    function getPreviewFiles(uint256 _id) external view bidExists(_id) returns (string memory) {
        return designs[_id].previewIpfsHash;
    }

    /** 
     * @dev Get the owner address for a bid
     * @param _id The id of the design.
     * @return address The address of the owner
     */
    function getOwner(uint256 _id) external view bidExists(_id) returns (address) {
        return designs[_id].owner;
    }

    /** 
     * @dev Get the IPFS hash for the design CAD file/folder.
     * @param _id The id of the design.
     * @return string The description of the bid
     */
    function getDescription(uint256 _id) external view bidExists(_id) returns (string memory) {
        return designs[_id].description;
    }

    /** 
     * @dev Get the cost for this contract bid.
     * @param _id The id of the design.
     * @return uint256 The cost to produce this design.
     */
    function getDesignCost(uint256 _id) external view bidExists(_id) returns(uint256) {
        return designs[_id].cost;
    }

    /** 
     * @dev Gets the TDBay master contract.
     * @return address The master TDBay contract address
     */
    function getMaster() public view returns(address) {
        return address(tdbContract);
    }

    /* * 
     * @dev Updates the IPFS hash for the preview of the design (image file)
     * @param _id The id of the design.
     * @param _hash The new IPFS hash of the image file/folder
     */
    function updatePreview(uint256 _id, string memory _hash) 
        public
        bidExists(_id) 
        ownsDesign(msg.sender, _id)
        isBid(_id)
    {
        require(bytes(_hash).length == 46);
        designs[_id].previewIpfsHash = _hash;
        emit UpdatedPreview(_id, _hash);
    }

    /* * 
     * @dev Updates the IPFS hash for the design CAD file/folder
     * @param _id The id of the design.
     * @param _hash The new IPFS hash of the CAD file/folder
     */
    function updateProjectFiles(uint256 _id, string memory _hash) 
        public
        bidExists(_id) 
        ownsDesign(msg.sender, _id)
        isAccepted(_id)
    {
        require(bytes(_hash).length == 46);
        designs[_id].ipfsHash = _hash;
        emit UpdatedFiles(_id, _hash);
    }
}