require("dotenv").config();
const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  plugins: ["truffle-security"],

  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 4600000,
    },
    ropsten: {
      provider: () => {
        return new HDWalletProvider(
            process.env.MNEMONIC,
            process.env.ROPSTEN_URL,
            0
        );
      },
      network_id: "3",
      confirmations: 4,
      timeoutBlocks: 200,
      skipDryRun: true,
      gasPrice: 10000000000,
    },
  },
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.6.0",
    },
  },
};