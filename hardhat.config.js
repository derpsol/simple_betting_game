require("@nomicfoundation/hardhat-toolbox");

const GOERLI_PRIVATE_KEY = "6ac5224ae5496a0c0830b751e93ef79fed2dcdfaacb1720f80b2070af33dcc46";
const ALCHEMY_API_KEY = "QARk6wvaaHlcADJr55SrUhFmACjgP0lZ";

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
      goerli: 'DEHCB9QGHRA42MIX935Z9SQI9DRD3FYYDG'
    }
  }
};
