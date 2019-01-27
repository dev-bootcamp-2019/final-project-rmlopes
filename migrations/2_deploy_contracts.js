var TDBay = artifacts.require("./TDBay.sol");
var Design = artifacts.require("./Design.sol");
var TDBayToken = artifacts.require("./TDBayToken.sol");

module.exports = function(deployer) {
  deployer.deploy(TDBay);
  deployer.deploy(Design);
  deployer.deploy(TDBayToken);
};
