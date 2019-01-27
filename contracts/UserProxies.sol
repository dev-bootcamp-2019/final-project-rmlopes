pragma solidity ^0.5.0;

import "./TDBay.sol";
import "./Design.sol";


contract UserProxy {
    
    TDBay public tdb;

    constructor(address _tdb) public {
        tdb = TDBay(_tdb);
    }

    function () external payable {}

    function withdraw(uint256 _value) 
        public 
        payable
    {
        tdb.withdraw(_value);
    }

    function addProject(string memory name, string memory description, uint pcost) 
        public 
        payable
    {
        tdb.addProject.value(pcost)(name, description, "");
    }

    function updateProjectFiles(string memory _hash, uint _pId) public {
        tdb.updateProjectFiles(_pId, _hash);
    }

    function acceptDesign(uint256 _projectId, uint256 _designId) public {
        tdb.acceptDesign(_projectId, _designId);
    }
}


contract DesignUserProxy {

    Design public dcontract;

    constructor(address _dcontract) public {
        dcontract = Design(_dcontract);
    }

    function addDesignBid(uint _projectId, uint256 _cost, string memory _desc) public payable {
        dcontract.addDesignBid.value(msg.value)(_projectId, _cost, _desc);
    }

    function updatePreview(uint _id, string memory _hash) public {
        dcontract.updatePreview(_id, _hash);
    }

    function updateProjectFiles(uint _id, string memory _hash) public {
        dcontract.updateProjectFiles(_id, _hash);
    }
}