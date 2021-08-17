// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import HRE from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await HRE.run('compile');

    // We get the contract to deploy
    const toolV1Factory = await HRE.ethers.getContractFactory("ToolV1");

    /* Deploy upgradeable contract, we need to pass the factory as the first argument and 
        UniswapRouterV2 address as the second one 
    */
    const toolV1Contract = await HRE.upgrades.deployProxy(toolV1Factory, ["0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"]);

    await toolV1Contract.deployed();

    console.log("Deployed upgradeable ToolV1 to:", toolV1Contract.address);
    
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
