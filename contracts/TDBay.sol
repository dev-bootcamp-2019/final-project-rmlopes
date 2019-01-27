pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./ITDBay.sol";
import "./TDBayToken.sol";
import "./IDesign.sol";


/** 
 * @title TDBay (3DBay) 
 * @author Rui L. Lopes
 */
contract TDBay is ITDBay, Ownable {

    using SafeMath for uint256;

    enum ProjectState { Designing, Manufacturing }

    struct TDBProject {
        uint256 id;
        ProjectState state;
        string name;
        address payable owner;
        string ipfsHash;
        uint256 designId;
        string description;
        //IManufactureContract manufactureContract;
    }
    
    bool private stopped = false;
    uint256 private currentId;
    mapping (address => TDBProject[]) private userToProject;
    uint256 private projectCost_;
    uint256 private designBidCost_;
    uint256 private manufactureBidCost_;

    // project fee sent to the owner on per mileage basis (project_cost*project_fee/fee_rate)
    Fee public projectFee = Fee(2, 1000);
    address payable public wallet_;

    TDBProject[] public projects;
    IERC20 public tokenContract;
    IDesign public designContract;

    event TDBayInitialized(IERC20 _token, uint256 _pcost, uint256 _dcost, uint256 _mcost);
    event ProjectCostModified(uint256 _pcost);
    event DesignBidModified(uint256 _pcost);
    event ManufactureBidModified(uint256 _pcost);
    event WalletModified(address _wallet);
    event OwnerWithdrawal(address _wallet, uint256 _amount);
    event ProjectCreated(address _creator, string _name);
    event ProjectFeeTransfered(uint _value);
    event StateChanged(uint indexed _id, ProjectState _state);
    event FallbackTrigered();

    /** 
     * @dev Checks if the value sent was enough to create a project.
     * @param _value The value sent by msg.sender
     */
    modifier checkProjectValue(uint256 _value) {
        require(_value >= projectCost_,
                "Value not enough to create a project");
        _;
    }

    /** 
     * @dev Checks if the value sent was enough to bid for design in a project.
     * @param _value The value sent by msg.sender
     */
    modifier checkDesignBidValue(uint256 _value) {
        require(_value >= designBidCost_,
                "Value not enough to bid for design in a project");
        _;
    }

    /** 
     * @dev Checks if the value sent was enough to bid for manufacturing on a project.
     * @param _value The value sent by msg.sender
     */
    modifier checkManufactureBidValue(uint256 _value) {
        require(_value >= manufactureBidCost_,
                "Value not enough to bid for manufacture in a project");
        _;
    }

    /** 
     * @dev Checks if and address is the owner of a project
     * @param _address The address to check
     * @param _id The project id
     */
    modifier ownsProject(address _address, uint256 _id) {
        require(projects[_id].owner == _address,
                "The caller does not own the project");
        _;
    }

    /** 
     * @dev Checks if a project exists
     * @param _id The project id
     */
    modifier projectExists(uint256 _id) {
        require(_id < projects.length,
                "The project id is incorrect");
        _;
    }

    /** 
     * @dev Checks if a design bid exists
     * @param _id The design bid id
     */
    modifier designBidExists(uint256 _id) {
        require(designContract.getState(_id) == 0,
                "The design bid id is incorrect");
        _;
    }

    /** 
     * @dev Checks if a design bid belongs to a project
     * @param _projectId The design bid id
     * @param _designId The design bid id
     */
    modifier designInProject(uint256 _projectId, uint256 _designId) {
        require(designContract.designInProject(_projectId, _designId),
                "The design bid does not belong to the project");
        _;
    }

    /** 
     * @dev Checks if the caller is the design contract
     * @param _address The address of the caller
     */
    modifier isDesignContract(address _address) {
        require(_address == address(designContract),
                "Caller is not the correct design contract");
        _;
    }

    /** 
     * @dev Checks if the project is in design bidding stage.
     * @param _id The project id
     */
    modifier isDesigning(uint _id) {
        require(projects[_id].state == ProjectState.Designing,
                "Project is not in bidding stage");
        _;
    }

    /** 
     * @dev Checks if the project is in manufacture bidding stage.
     * @param _id The project id
     */
    modifier isManufacturing(uint _id) {
        require(projects[_id].state == ProjectState.Manufacturing,
                "Project is not in manufacturing stage");
        _;
    }

    /** 
     * @dev Circuit breaker modifier if not stopped
     */
    modifier whenNotPaused { require(!stopped); _; }

    /** 
     * @dev Circuit breaker modifier if stopped
     */
    modifier whenPaused { require(stopped); _; }

    /** 
     * @dev Initializes the contract setting a payable wallet for the owner
     */
    constructor() public 
      Ownable() 
    {
        wallet_ = msg.sender;
    }

    function () external {
        //wallet_.transfer(msg.value);
        emit FallbackTrigered();
    }

    /** @dev Get the wallet for withdrawals (avoid locked funds) 
      * @return The wallet address
      */
    function wallet() external view returns (address payable) {
        return wallet_;
    }

    /** 
     * @dev Returns the project bid cost
     * @return projectCost The project bid cost
     */
    function projectCost() external view returns(uint256) {
        return projectCost_;
    }

    /** 
     * @dev Returns the design bid cost
     * @return designBidCost The project design bid cost
     */
    function designBidCost() external view returns(uint256) {
        return designBidCost_;
    }

    /** 
     * @dev Returns the manufacture bid cost
     * @return manufactureBidCost The project manufacture bid cost
     */
    function manufactureBidCost() external view returns(uint256) {
        return manufactureBidCost_;
    }

    /** 
     * @dev Returns the project creation fee
     * @return (_fee, _rate) The project creation fee (_fee/_rate)
     */
    function getProjectCreationFee() external view returns(Fee memory) {
         return projectFee;
    }

    /** 
     * @dev Circuit breaker toggler
     */
    function toggleContractActive() public onlyOwner() {
        stopped = !stopped;
    }

    /** @dev  Allows the owner to update the the project cost.
      * @param _cost The new project cost value.
      */
    function setProjectCost(uint256 _cost) public onlyOwner() {
        require(_cost >= projectFee.rate, "Project cost must be larger than the porject creation fee rate.");
        projectCost_ = _cost;
        emit ProjectCostModified(projectCost_);
    }

    /** @dev Allows the owner to update the the design bid cost.
      * @param _cost The new project cost value.
      */
    function setDesignBidCost(uint256 _cost) public onlyOwner() {
        designBidCost_ = _cost;
        emit DesignBidModified(designBidCost_);
    }

    /** @dev Allows the owner to update the the manufacture bid cost.
      * @param _cost The new project cost value.
      */
    function setManufactureBidCost(uint256 _cost) public onlyOwner() {
        manufactureBidCost_ = _cost;
        emit ManufactureBidModified(manufactureBidCost_);
    }

    /** @dev Allows the owner to update the project fee structure (_pfee/_frate).
      * @param _pfee The new project fee per rate.
      * @param _frate The fee rate value.
      */
    function setProjectCreationFee(uint256 _pfee, uint256 _frate) public onlyOwner() {
        require(_frate > _pfee, "The rate must be superior to the fee.");
        projectFee = Fee(_pfee, _frate);
        emit ManufactureBidModified(manufactureBidCost_);
    }

    /** 
     * @dev Initializes the contract costs structure and the acceptable tokens for payment
     * @param _acceptedToken The ERC20 token used for internal transactions
     * @param _designContract The design contract used
     * @param _pcost The project creation cost
     * @param _dcost The design bid cost
     * @param _mcost The manufacture bid cost
     */
    function initializeTDBay(address _acceptedToken, address _designContract, 
        uint256 _pcost, uint256 _dcost, uint256 _mcost) 
        public
        onlyOwner() 
    {
        projectCost_ = _pcost;
        designBidCost_ = _dcost;
        manufactureBidCost_ = _mcost;
        tokenContract = IERC20(_acceptedToken);
        designContract = IDesign(_designContract);
        emit TDBayInitialized(tokenContract, projectCost_, designBidCost_, manufactureBidCost_);
    }

    /** @dev Changes the token contract address
      * @param _address The new contract address
      */
    function setTokenContract(address _address) public onlyOwner(){
        require(_address != address(0));
        tokenContract = IERC20(_address);
    }

    /** @dev Changes the design contract address
      * @param _address The new design contract address
      */
    function setDesignContract(address _address) public onlyOwner(){
        require(_address != address(0));
        designContract = IDesign(_address);
    }

    /** @dev Changes the payable wallet
      * @param _address The new wallet address
      */
    function changeWallet(address payable _address) public onlyOwner() {
        require(_address != address(0));
        wallet_ = _address;
        emit WalletModified(wallet_);
    }

    /** @dev Allows the owner to withdraw from the contracts balance
      * @param _value The value to withdraw
      */
    function withdraw(uint256 _value) public onlyOwner() whenPaused(){
        require(_value <= address(this).balance,
                "Not enough balance to withdraw.");
        emit OwnerWithdrawal(wallet_, _value);
        wallet_.transfer(_value);
    }

    /** @dev Get the number of projects created 
      * @return The numebr of projects created (currentId)
      */
    function getNumProjects() public returns (uint256) {
        return currentId;
    }

    /** @dev Creates a new project owned by the caller
      * @param _name The name of the new project.
      */
    function addProject(string memory _name, string memory _description, string memory _hash) 
        public 
        payable
        whenNotPaused()
        checkProjectValue(msg.value)
    {
        TDBProject memory _project = TDBProject(currentId, 
                                                ProjectState.Designing,
                                                _name, 
                                                msg.sender, 
                                                _hash, 
                                                0,
                                                _description);
        projects.push(_project);
        currentId += 1;
        userToProject[msg.sender].push(_project);
        emit ProjectCreated(msg.sender, _project.name);

        uint256 _fee = projectCost_.mul(projectFee.fee).div(projectFee.rate);
        wallet_.transfer(_fee); 
        emit ProjectFeeTransfered(_fee);
    }

    /* * 
     * @dev Fetches the projects of a user
     * @param _user The owner of the projects to fetch
     * @return TDBProject[] The projects owned by the user
     */
    function fetchUserProjects(address _user) 
        public 
        view
        returns (TDBProject[] memory)
    {
        require(_user != address(0), "Invalid user.");
        return userToProject[_user];
    }

    /* * 
     * @dev Fetches the latest projects created
     * @return TDBProject[] The projects of his contract
     */
    function fetchProjects() 
        public 
        view
        returns (TDBProject[] memory)
    {
        
        return projects;
    }

    /* * 
     * @dev Updates the IPFS hash for the project description files/folders
     * @param _projectId The project id.
     * @param _hash The new IPFS hash of the file/folder
     */
    function updateProjectFiles(uint256 _projectId, string memory _hash) 
        public
        projectExists(_projectId)
        ownsProject(msg.sender, _projectId) 
    {
        require(bytes(_hash).length == 46);
        projects[_projectId].ipfsHash = _hash;
    }

    /** @dev Gets the project owner
      * @param _id The project id.
      * @return address The address of the project owner.
      */
    function getProjectOwner(uint _id) public view 
        projectExists(_id)
        returns (address)
    {
        return projects[_id].owner;
    }

    /** @dev Creates a new project owned by the caller
      * @param _projectId The project  id
      * @param _designId The design id
      */
    function acceptDesign(uint _projectId, uint _designId)  
        public
        projectExists(_projectId)
        isDesigning(_projectId)
        designInProject(_projectId, _designId)
        ownsProject(msg.sender, _projectId)
    {
        projects[_projectId].designId = _designId;
        designContract.acceptBid(_designId);
        projects[_projectId].state = ProjectState.Manufacturing;
        emit StateChanged(_projectId, ProjectState.Manufacturing);
    }
}