require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-web3");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  defaultNetwork: "hardhat",
  gasReporter: {
    enabled: true,
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      blockGasLimit: 1000000000000,
      gas: 10000000000
    },
  }
};
