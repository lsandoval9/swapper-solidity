import HRE, { ethers } from "hardhat";

async function main() {

    const ToolV2Factory = await HRE.ethers.getContractFactory("ToolV2");

    if (process.env.BASE_CONTRACT) {
        
        const toolV2Contract = await HRE.upgrades.upgradeProxy(
            process.env.BASE_CONTRACT,
            ToolV2Factory,
            {}
        );

        const kyberProxyAddress = process.env.KYBER_ADDRESS
    
        await toolV2Contract.deployed();

        await toolV2Contract.migrate(kyberProxyAddress)
    
    
    
        console.log("Tool upgraded from V1 to V2");
        console.log("Base address: ", process.env.BASE_CONTRACT);
        console.log("Kyber address: ", kyberProxyAddress)
        console.log("Upgraded contract address: ", toolV2Contract.address);

    } else {

        console.error("Please insert the valid address of the base contract in the .env file")

    }

    

    
}

main();
