const HDWalletProvider = require('@truffle/hdwallet-provider');
const privateKey = '963a24ae791ac2fd16fb5d6e31e3af45651820a86426a2e7a4e0e4f4d10f0f7c'; // Replace with your wallet private key

module.exports = {
  networks: {
    amoy: {
      provider: () => new HDWalletProvider(privateKey, 'https://rpc-amoy.polygon.technology/'),
      network_id: 80002,       // Polygon Mumbai testnet ID
      gas: 5000000,
      gasPrice: 30000000000,   // 10 Gwei
    },
  },
  compilers: {
    solc: {
      version: "0.8.0",
    },
  },
};