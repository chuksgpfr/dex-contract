// const { expect } = require("chai");
// const { ethers } = require("hardhat");

// describe("Deploy mock ERC20 tokens", () => {
//   let dai, usdt, usdc, dex;
//   let DaiSymbol, UsdcSymbol, UsdtSymbol;
//   let owner, trader1, trader2;

//   // const [trader1, trader2] = [addr1.address, addr2.address];

//   beforeEach(async () => {
//     const [deployer, addr1, addr2] = await hre.ethers.getSigners();
//     [owner, trader1, trader2] = [deployer.address, addr1.address, addr2.address];

//     // console.log([deployer.address, addr1.address, addr2.address]);

//     const Dex = await ethers.getContractFactory("DEX");
//     const Dai = await ethers.getContractFactory("DAI");
//     const Usdc = await ethers.getContractFactory("USDC");
//     const Usdt = await ethers.getContractFactory("USDT");

//     const amount = ethers.utils.parseEther("1000"); 

//     dai = await Dai.deploy();
//     usdc = await Usdc.deploy();
//     usdt = await Usdt.deploy();
//     dex = await Dex.deploy();

//     await dai.deployed();
//     await usdc.deployed();
//     await usdt.deployed();
//     await dex.deployed();

//     // console.log("AM ", amount);

//     [DaiSymbol, UsdcSymbol, UsdtSymbol] = [
//       ethers.utils.formatBytes32String(await usdc.symbol()), 
//       ethers.utils.formatBytes32String(await dai.symbol()), 
//       ethers.utils.formatBytes32String(await usdt.symbol())
//     ];
//      // add token mocks to dex
//      await Promise.all([
//       dex.addToken(DaiSymbol, dai.address),
//       dex.addToken(UsdcSymbol, usdc.address),
//       dex.addToken(UsdtSymbol, usdt.address),
//     ]);

//     // console.log("TL ", await dex.tokenList());

//     const seedTokenBalance = async (token, trader) => {
//       await token.faucet(trader, amount);
//       const app = await token.approve(owner, amount, {from: trader});
//       await app.wait();
//       console.log("APPR ", app);
//     };

//     await Promise.all([
//       [dai, usdc, usdt].map((token) => {
//         seedTokenBalance(token, trader1)
//       })
//     ]);

//     await Promise.all([
//       [dai, usdc, usdt].map((token) => {
//         seedTokenBalance(token, trader2)
//       })
//     ]);

//     await Promise.all([
//       [dai, usdc, usdt].map((token) => {
//         seedTokenBalance(token, owner)
//       })
//     ]);
//   });

//   describe("Transactions", () => {

//     it("Dai Balance", async () => {
//       const balance = await dai.balanceOf(trader1);
//       const amount = ethers.utils.parseEther("1000");
//       expect(await balance).to.equal(amount);
//     });

//     it("Should Deposit", async () => {
//       console.log("OW ", trader1);
//       const depositAmount = ethers.utils.parseEther("10");
//       await dex.connect(trader1).deposit(depositAmount, DaiSymbol);
//       expect(await usdc.symbol()).to.equal("DAI");
//     });

//   });
// })