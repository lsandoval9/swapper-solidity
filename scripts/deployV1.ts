// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import HRE from "hardhat";
import path from "path";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await HRE.run('compile');

    // We get the contract to deploy
    /* const toolV1Factory = await HRE.ethers.getContractFactory("ToolV1");

    const toolV1Contract = await HRE.upgrades.deployProxy(toolV1Factory);

    await toolV1Contract.deployed();

    console.log("Deployed upgradeable ToolV1 to:", toolV1Contract.address); */

    console.log(path.resolve(__dirname, ".."));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
