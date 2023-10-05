require("@nomicfoundation/hardhat-toolbox")
require("@nomicfoundation/hardhat-ethers")
require("dotenv").config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.19",
    networks: {
        mumbai: {
            url: process.env.TESTNET_RPC,
            accounts: [process.env.MUMBAI_PRIVATE_KEY],
        },
    },
    etherscan: {
        url: "https://mumbai.polygonscan.com/",
        apiKey: process.env.POLYGONSCAN_API_KEY,
    },
}
