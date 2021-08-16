import HRE from "hardhat";

async function main() {

  const BoxV2 = await HRE.ethers.getContractFactory("BoxV2");

  const box = await HRE.upgrades.upgradeProxy(BOX_ADDRESS, BoxV2);

  console.log("Tool upgraded from V1 to V2");

}

main();
