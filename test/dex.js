const { expect, assert } = require("chai");

const Dex = artifacts.require("DEX.sol");
const Usdc = artifacts.require("USDC.sol");
const Dai = artifacts.require("DAI.sol");
const Usdt = artifacts.require("USDT.sol");


contract("Dex", (accounts) => {
  let dex, dai, usdc, usdt;
  const [DaiSymbol, UsdcSymbol, UsdtSymbol] = ["DAI", "USDC", "USDT"].map(symbol => {
    return web3.utils.fromAscii(symbol)
  });

  const [signer, khagan, esther] = [accounts[0], accounts[1], accounts[2]];

  describe("Deploy Dex and Mock ERC20 Token", () => {

    before(async () => {
      ([dex, dai, usdc, usdt] = await Promise.all([
        Dex.new(),
        Dai.new(),
        Usdc.new(),
        Usdt.new(),
      ]))

      await Promise.all([
        dex.addToken(DaiSymbol, dai.address),
        dex.addToken(UsdcSymbol, usdc.address),
        dex.addToken(UsdtSymbol, usdt.address),
      ])

      const amount = web3.utils.toWei("10000");
      const seedTokenBalance = async (token, trader) => {
        await token.faucet(trader, amount);
        await token.approve(dex.address, amount, {from: trader});
      }

      await Promise.all(
        [dai, usdc, usdt].map(
          token => seedTokenBalance(token, khagan) 
        )
      );
      await Promise.all(
        [dai, usdc, usdt].map(
          token => seedTokenBalance(token, esther) 
        )
      );
    });


    describe("Transactions ", () => {
      it("Check Balance", async() => {
        const amount = web3.utils.toWei("10000");
        const balance = await dai.balanceOf(khagan);
        assert(balance.toString() === amount)
      });

      it("Deposit to Dai", async() => {
        const amount = web3.utils.toWei("1000");
        const dp = await dex.deposit(amount, DaiSymbol, {from: khagan})
        const balance = await dex.traderBalances(khagan, DaiSymbol);
        assert(balance.toString() === amount)
      });

      it("Should Not deposit", async() => {
        const amount = web3.utils.toWei("100");
        await expect(dex.deposit(amount, web3.utils.fromAscii("NAT"), {from: khagan})).to.be.revertedWith("Token does not exist");
      });

      it("Should withdraw tokens", async() => {
        const amount = web3.utils.toWei("100");
        await dex.withdraw(amount, DaiSymbol, {from: khagan});
        const balance = await dex.traderBalances(khagan, DaiSymbol);
        // assert()
      });
    });

  });
})