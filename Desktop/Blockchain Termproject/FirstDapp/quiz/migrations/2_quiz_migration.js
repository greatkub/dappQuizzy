const Quizy = artifacts.require("Quizy");

module.exports = function (deployer) {
    deployer.deploy(Quizy);
};