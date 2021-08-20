import { expect } from "chai";
import { ethers } from "hardhat";
import { solidity } from "ethereum-waffle";
import chai from "chai"
import { BigNumber, Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import HRE from "hardhat"

const ERCTokenAbi = require("../artifacts/contracts/interfaces/IERC20Upgradeable.sol/IERC20Upgradeable.json");

chai.use(solidity);

describe("ToolV2", function () {
    
    let ToolV2Factory: ContractFactory;
    let uniswapAddress: string | undefined;
    let toolV2Contract: Contract;
    let accounts: SignerWithAddress[];

    this.beforeAll( async () => {

        let baseContractAddress: string | undefined = process.env.BASE_CONTRACT;

        let kyberNetworkProxyAddress = process.env.KYBER_ADDRESS;

        if (baseContractAddress && kyberNetworkProxyAddress) {
            
            accounts = await ethers.getSigners();

            ToolV2Factory = await ethers.getContractFactory("ToolV2");

            uniswapAddress = process.env.UNISWAP_ADDRESS;
        
            toolV2Contract = await HRE.upgrades.upgradeProxy(baseContractAddress, ToolV2Factory);

            await toolV2Contract.deployed();

            await toolV2Contract.migrate(kyberNetworkProxyAddress);

        } else {
            throw Error("baseContractAddress  is undefined");
        }

    })

    it("should return the owner of the contract and the owner cannot be null", async () => {

        const owner = await toolV2Contract.owner();

        expect(owner).to.be.equal(accounts[0].address);

    })

    describe("require functions", () => {

        it("Should revert if the user pass call swapETHForTokens without send ether", async function () {

            await expect(toolV2Contract
            .swapETHForTokens(accounts[0].address, 
                ["0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa"], [100]))
            .to.be.revertedWith("Insufficient amount");
    
        });
    
    
        it("should revert if the user calls swapETHForTokens with array params of different lengths (_tokensAddress and _percentages)", 
        async () => {
    
            let oneEther = ethers.utils.parseEther("1.0");
    
            await expect(toolV2Contract
                .swapETHForTokens(accounts[0].address, 
                    ["0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa", 
                    "0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa"], 
                    [100], {value: oneEther}))
                .to.be.revertedWith("Please, specify a percentage for each token");
    
    
            await expect(toolV2Contract
                .swapETHForTokens(accounts[0].address, 
                    ["0x6B175474E89094C44Da98b954EedeAC495271d0F", 
                    "0x6B175474E89094C44Da98b954EedeAC495271d0F"], 
                    [10,10,10], {value: oneEther}))
                .to.be.revertedWith("Please, specify a percentage for each token");
    
        });

    });

    describe("swapETHForTokens function", () => {


        it('the owner of the contract should receive a fee of 0.1%', async () => {

            let oneEther = ethers.utils.parseEther("1.0");

            let toolV2Contract2 = toolV2Contract.connect(accounts[1]);
            
            let ownerBalance = await accounts[0].getBalance()

            await toolV2Contract2.swapETHForTokens(accounts[1].address, 
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


        it("should transfer DAI tokens to desired account", async () => {

            let oneEther = ethers.utils.parseEther("1.0");

            let DAIContract: Contract = new ethers
            .Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F", ERCTokenAbi.abi, ethers.provider);

            await toolV2Contract.swapETHForTokens(accounts[5].address, 
                ["0x6B175474E89094C44Da98b954EedeAC495271d0F"], 
                [100], {value: oneEther});


            let balance: BigNumber = await DAIContract.balanceOf(accounts[5].address);

            expect(balance.gt(0)).to.be.true;

        })


        it("should transfer different tokens to the desired account", async () => {

            let oneEther = ethers.utils.parseEther("1.0");

            let DAIContract: Contract = new ethers
            .Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F", ERCTokenAbi.abi, ethers.provider);

            let USDTContract: Contract = new ethers
            .Contract("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", ERCTokenAbi.abi, ethers.provider);

            await toolV2Contract.swapETHForTokens(accounts[6].address, 
                ["0x6B175474E89094C44Da98b954EedeAC495271d0F", "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"], 
                [20, 80], {value: oneEther});


            let DAIbalance: BigNumber = await DAIContract.balanceOf(accounts[6].address);

            let USDTbalance: BigNumber = await USDTContract.balanceOf(accounts[6].address);

            expect(DAIbalance.gt(0)).to.be.true;
            expect(USDTbalance.gt(0)).to.be.true;

        });

    });


    describe("swapETHForTokensKyber function", async () => {

        it('the owner of the contract should receive a fee of 0.1%', async () => {

            let oneEther = ethers.utils.parseEther("1.0");

            let toolV2Contract2 = toolV2Contract.connect(accounts[1]);
            
            let ownerBalance = await accounts[0].getBalance()

            await toolV2Contract2.swapETHForTokens(accounts[1].address, 
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

        it("should transfer DAI tokens to desired account", async () => {

            let oneEther = ethers.utils.parseEther("1.0");

            let DAIContract: Contract = new ethers
            .Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F", ERCTokenAbi.abi, ethers.provider);

            await toolV2Contract.swapETHForTokens(accounts[6].address, 
                ["0x6B175474E89094C44Da98b954EedeAC495271d0F"], 
                [100], {value: oneEther});


            let balance: BigNumber = await DAIContract.balanceOf(accounts[6].address);

            expect(balance.gt(0)).to.be.true;

        })


        it("should transfer different tokens to the desired account", async () => {

            let oneEther = ethers.utils.parseEther("1.0");

            let DAIContract: Contract = new ethers
            .Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F", ERCTokenAbi.abi, ethers.provider);

            let USDTContract: Contract = new ethers
            .Contract("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", ERCTokenAbi.abi, ethers.provider);

            await toolV2Contract.swapETHForTokens(accounts[7].address, 
                ["0x6B175474E89094C44Da98b954EedeAC495271d0F", "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"], 
                [20, 80], {value: oneEther});


            let DAIbalance: BigNumber = await DAIContract.balanceOf(accounts[7].address);

            let USDTbalance: BigNumber = await USDTContract.balanceOf(accounts[7].address);

            expect(DAIbalance.gt(0)).to.be.true;
            expect(USDTbalance.gt(0)).to.be.true;

        });

    })

});
