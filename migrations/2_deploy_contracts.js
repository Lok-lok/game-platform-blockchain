var Migrations = artifacts.require("./PlatformContract.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
