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
      provider: new HDWalletProvider(
        process.env.PRIVATE_KEY,
        process.env.ROPSTEN_URL
      ),
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
