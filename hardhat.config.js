require("@nomicfoundation/hardhat-toolbox");

const GOERLI_PRIVATE_KEY = "sdfsdfsfsf";
const ALCHEMY_API_KEY = "sdfsfdfdsf";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      goerli: 'sdfsdfsfdssdfdf'
    }
  }
};
