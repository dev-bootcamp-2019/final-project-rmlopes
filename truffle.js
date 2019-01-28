module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
    },
    ropsten: {
      host: "localhost",
      port: 8546,
      network_id: "3"
    },
    rinkeby: {
      host: "localhost",
      port: 8546,
      network_id: 4,
    }
  },
  solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
  }
};
