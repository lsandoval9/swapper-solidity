import "@nomiclabs/hardhat-waffle";
import '@openzeppelin/hardhat-upgrades';
import { ethers, upgrades } from "hardhat";
require('dotenv').config()

import { task } from "hardhat/config";

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});


// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.6.6",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    networks: {
        hardhat: {
            forking: {
                url: "https://eth-mainnet.alchemyapi.io/v2/CyI3yTBWSg1tBk5cCWEPIuZw5InGryfY",
                blockNumber: 13_005_076,
            },
        },
    },

    mocha: {
        timeout: 20000
    }
};
