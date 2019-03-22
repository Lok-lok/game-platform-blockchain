var Migrations = artifacts.require("./VotingContract.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations, 10);
};
