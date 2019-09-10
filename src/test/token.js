const Token = artifacts.require("Token");
const helper = require("./helpers/truffleTestHelper");

contract.only("Token", function(accounts) {
  const OWNER = accounts[0];
  const ALICE = accounts[1];
  const BOB = accounts[2];

  let tokenInstance;

  beforeEach(async function () {
    tokenInstance = await Token.new();
  });

  describe("Stack tests", () => {
    it.only("Owner should be a hodler", async function () {
      const actual = await tokenInstance.isHodler(OWNER);
      assert.isTrue(actual, "Should not be a hodler");
    });

    it.only("Alice should not be a hodler", async function () {
      const actual = await tokenInstance.isHodler(ALICE);
      assert.isFalse(actual, "Should not be a hodler");
    });

    it.skip("Should add BOB to hodlers", async function () {
      const actual = await tokenInstance.insertHodler(BOB);
      console.log(actual);
      assert.equal(Number(actual), 1, "Should have index of 1");
    });

    it("Should calc 0 interest", async function () {
      const start = await tokenInstance._start();
      console.log(Number(start));

      const actual = await tokenInstance.calc(100, 0);
      console.log(Number(actual));

      assert.equal(actual.valueOf(), 0, "Should be 0");
    });
  });

  describe("Interest tests", () => {
    it.only("Should get delta", async function () {
      //const start = await tokenInstance._start();
      //console.log(Number(start));

      //await helper.advanceTime(6000);

      const actual = await tokenInstance.delta(0, 6000);
      console.log(Number(actual));
      console.log(actual);

      assert.equal(actual, 6000, "Delta should be 6000");
    });

    it.only("Should calc %6 interest on $10,000 principal over a full year", async function () {
      const actual = await tokenInstance.calcInterest(10000, 365);
      assert.equal(Number(actual), 600, "Should be 600");
    });

    it.only("Should calc %6 interest on $10,000 principal over a full year", async function () {
      const actual = await tokenInstance.calcInterest(1000000000, 365);
      assert.equal(Number(actual), 60000000, "Should be 60000000");
    });

    it.only("Should get 0 in circulation", async function () {
      const actual = await tokenInstance.getInCirculation();
      assert.equal(Number(actual), 0, "Should be 0");
    });

    it.only("Should get 500000000 in circulation", async function () {
      await tokenInstance.transfer(ALICE, 500000000, {from: OWNER});
      const balance = await tokenInstance.balanceOf(ALICE);
      assert.equal(Number(balance), 500000000, "Balance should be 500000000");

      const actual = await tokenInstance.getInCirculation();
      assert.equal(Number(actual), 500000000, "Should be 500000000");
    });

    it.only("Should get 900000000 in circulation", async function () {
      await tokenInstance.transfer(ALICE, 500000000, {from: OWNER});
      await tokenInstance.transfer(BOB, 400000000, {from: OWNER});

      const actual = await tokenInstance.getInCirculation();
      assert.equal(Number(actual), 900000000, "Should be 900000000");
    });

    it.only("Should get future balance", async function () {
      await tokenInstance.transfer(ALICE, 1000000000, {from: OWNER});
      let balance = await tokenInstance.balanceOf(ALICE);
      assert.equal(Number(balance), 1000000000, "Balance should be 1000000000");

      const seconds_in_a_day = 86400;
      await helper.advanceTime(365 * seconds_in_a_day);

      balance = await tokenInstance.balanceOf(ALICE);
      assert.equal(Number(balance), 1060000000, "Balance should be 1060000000");
    });
  });

  describe("Transfer tests", () => {
    it.only("Should be able to transfer 600000000", async function () {
      await tokenInstance.transfer(ALICE, 500000000, {from: OWNER});

      let balance = await tokenInstance.balanceOf(ALICE);
      assert.equal(Number(balance), 500000000, "Balance should be 500000000");

      const seconds_in_a_day = 86400;
      await helper.advanceTime(365 * seconds_in_a_day);
      balance = await tokenInstance.balanceOf(ALICE);

      assert.isTrue(balance > 500000000);
    });
  });

  //   it.only("Should get delta", async function () {
  //     //const start = await tokenInstance._start();
  //     //console.log(Number(start));

  //     //await helper.advanceTime(10000);

  //     const actual = await tokenInstance.delta(10000, 20000);
  //     console.log(Number(actual));
  //     console.log(actual);

  //     assert.equal(actual, 10000, "Delta should be 10000");
  //   });

  //   it("Should calc 0 interest", async function () {
  //     const start = await tokenInstance._start();
  //     console.log(Number(start));

  //     const actual = await tokenInstance.calc(100, 0);
  //     console.log(Number(actual));

  //     assert.equal(actual.valueOf(), 0, "Should be 0");
  //   });

  //   it.only("Should calc full year interest", async function () {
  //     const actual = await tokenInstance.calcInterest(10000, 365);
  //     console.log(Number(actual));

  //     assert.equal(Number(actual), 1200, "Should be 1200");
  //   });

  //   it.only("Should calc full year interest", async function () {
  //     const actual = await tokenInstance.calcInterest(10000, 365);
  //     console.log(Number(actual));

  //     assert.equal(Number(actual), 1200, "Should be 1200");
  //   });
    
  //   it("Should calc interest balance", async function () {
  //     await tokenInstance.transfer(BOB, 10000000);

  //     await helper.advanceTime(30 * 24 * 60 * 60);

  //     const actual = await tokenInstance.balanceOf(BOB);
  //     console.log(Number(actual));

  //     assert.equal(Number(actual), 4800000000, "Should be 4800000000");
  //   });

  //   it("Should calc rate 2", async function () {
  //     // await tokenInstance.transfer(BOB, 100000000000000);
  //     // let actual = await tokenInstance.balanceOf(OWNER);

  //     // actual = await tokenInstance.balanceOf(BOB);
  //     // assert.equal(Number(actual), 100000000000000, "Bob balance should be 10,000 tokens");

  //     //await helper.advanceTime(1);

  //     //1000 tokens
  //     const amount = 10000000;

  //     actual = await tokenInstance.calc(amount, 30);
  //     console.log(Number(actual));

  //     //1300 tokens
  //     assert.equal(Number(actual), 4800000000, "Should be 1120 tokens");
  //   });

  //   it("Should not have any interest", async function () {
  //     const start = await tokenInstance._start();
  //     console.log(Number(start));

  //     const actual = await tokenInstance.calc(100, start);
  //     console.log(Number(actual));

  //     assert.equal(actual.valueOf(), 100, "Should still be 100");
  //   });
  // });

  describe("ERC20 tests", () => {
    it.only("Should test ERC20 public properties", async function () {
      const name = await tokenInstance.name();
      assert.equal(name, "Virtual Token", "Name should be Virtual Token");

      const symbol = await tokenInstance.symbol();
      assert.equal(symbol, "VITO", "Symbol should be VITO");
    });

    it.only("Total supply should be 100000000000000", async function () {
      const actual = await tokenInstance.totalSupply();
      assert.equal(Number(actual), Number(100000000000000), "Total supply should be 100000000000000");
    });

    it.only("Owner balance should be 100000000000000", async function () {
      const actual = await tokenInstance.balanceOf(OWNER);
      assert.equal(Number(actual), 100000000000000, "Balance should be 100000000000000");
    });

    it.only("Should transfer 200 tokens to alice", async function () {
      await tokenInstance.transfer(ALICE, 200, {from: OWNER});
      const actual = await tokenInstance.balanceOf(ALICE);
      assert.equal(Number(actual), 200, "Balance should be 200");
    });

    it("Should transfer 500000000 tokens to alice", async function () {
      await tokenInstance.transfer(ALICE, 500000000, {from: OWNER});
      const actual = await tokenInstance.balanceOf(ALICE);
      assert.equal(Number(actual), 500000000, "Balance should be 500000000");
    });

    it("Should transfer 600000000 tokens to alice", async function () {
      await tokenInstance.transfer(ALICE, 600000000, {from: OWNER});
      const actual = await tokenInstance.balanceOf(ALICE);
      assert.equal(Number(actual), 600000000, "Balance should be 600000000");
    });

    it("Should get total in curculation of zero as owners balance is not included", async function () {
      const actual = await tokenInstance._getInCirculation();
      assert.equal(Number(actual), 0, "In circulation should be 0");
    });

    it("Should get total in curculation", async function () {
      await tokenInstance.transfer(ALICE, 600000000, {from: OWNER});
      const actual = await tokenInstance._getInCirculation();

      assert.equal(Number(actual), 600000000, "Total should be 600000000");
    });
    
    it("Owner balance should be 10000000000000", async function () {
      const actual = await tokenInstance.delta();
      assert.equal(Number(actual), 10000000000000, "Balance should be 10000000000000");
    });
  });
});