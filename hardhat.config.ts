require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-ethers");

import './tasks/deploy'
import './tasks/sendData'

module.exports = {
    solidity: {
        version: "0.8.16",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    networks: {
        hardhat: {
            blockGasLimit: 100_000_000,
            chainId: 100,
        },
        localhost: {
            url: "http://127.0.0.1:8545",
        },
        sepolia: {
            url: "your url with API key",
            accounts: ['0x0000000000000000000000000000000000000000000000000000000000000000']
        }
    },
    allowUnlimitedContractSize:true
};
