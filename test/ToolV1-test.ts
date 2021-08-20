import { expect, use } from "chai";
import { ethers } from "hardhat";
import HRE from "hardhat"
import { solidity } from "ethereum-waffle";
import { Contract, ContractFactory } from "@ethersproject/contracts";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber } from "ethers";

use(solidity);

describe("ToolV1 contract", function () {

    let ToolV1Factory: ContractFactory;
    let uniswapAddress: string | undefined;
    let toolV1Contract: Contract;
    let accounts: SignerWithAddress[];

    this.beforeAll( async () => {

        accounts = await ethers.getSigners();

        ToolV1Factory = await ethers.getContractFactory("ToolV1");

        uniswapAddress = process.env.UNISWAP_ADDRESS;
    
        toolV1Contract = await HRE.upgrades.deployProxy(ToolV1Factory, [uniswapAddress]);

    })

    it("should return the owner of the contract and the owner cannot be null", async () => {

        const owner = await toolV1Contract.owner();

        expect(owner).to.be.equal(accounts[0].address);

    })

    describe("require functions", () => {

        it("Should revert if the user pass call swapETHForSpecifiedTokens without send ether", async function () {

            await expect(toolV1Contract
            .swapETHForSpecifiedTokens(accounts[0].address, ["0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa"], [100]))
            .to.be.revertedWith("Insufficient amount");
    
        });
    
    
        it("should revert if the user calls swapETHForSpecifiedTokens with array params of different lengths (_tokensAddress and _percentages)", 
        async () => {
    
            let oneEther = ethers.utils.parseEther("1.0");
    
            await expect(toolV1Contract
                .swapETHForSpecifiedTokens(accounts[0].address, 
                    ["0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa", 
                    "0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa"], 
                    [100], {value: oneEther}))
                .to.be.revertedWith("Please, specify a percentage for each token");
    
    
            await expect(toolV1Contract
                .swapETHForSpecifiedTokens(accounts[0].address, 
                    ["0x6B175474E89094C44Da98b954EedeAC495271d0F", 
                    "0x6B175474E89094C44Da98b954EedeAC495271d0F"], 
                    [10,10,10], {value: oneEther}))
                .to.be.revertedWith("Please, specify a percentage for each token");
    
        });

    });

    describe("swapETHForSpecifiedTokens function", () => {


        it('the owner of the contract should receive a fee of 0.1%', async () => {

            let oneEther = ethers.utils.parseEther("1.0");

            let toolV1Contract2 = toolV1Contract.connect(accounts[1]);
            
            let ownerBalance = await accounts[0].getBalance()

            await toolV1Contract2.swapETHForSpecifiedTokens(accounts[1].address, 
                ["0x6B175474E89094C44Da98b954EedeAC495271d0F", 
                "0x6B175474E89094C44Da98b954EedeAC495271d0F"], 
                [50,90], {value: oneEther});

            let newOwnerBalance: BigNumber = await accounts[0].getBalance();

            let fee = ownerBalance.div(BigNumber.from("1000"));

             expect(newOwnerBalance.gt(ownerBalance)).to.be.true;

            expect(newOwnerBalance)
            // @ts-ignore
            .to.be.within( ownerBalance.add(BigNumber.from(1)), fee.add(ownerBalance))

        });

    })
   
});
