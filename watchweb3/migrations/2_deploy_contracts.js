const ReceiveEther = artifacts.require("ReceiveEther");
const SendEther = artifacts.require("SendEther");

module.exports = function (deployer) {
  deployer.deploy(ReceiveEther);
  deployer.deploy(SendEther);
};
