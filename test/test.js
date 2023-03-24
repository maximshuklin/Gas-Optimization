const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const { ethers } = require("hardhat");

describe("Payout something", function () {
  it("Payout Naive. Small Test", async function() {
    const Payout = await ethers.getContractFactory("PayoutContract");
    const [owner, user1, user2] = await ethers.getSigners();
    console.log(user1);
    const payout = await Payout.deploy([user1.address, user2.address], 3);
    await payout.deployed();

    await payout.payoutNaive([
      [1, 2, 3],
      [2, 3, 4]
    ], [1, 1, 10]);


    expect(await payout.getBalance(user1.address)).to.equal(33);
    expect(await payout.getBalance(user2.address)).to.equal(45);
  });
});

/*
[1, 2, 3]
[2, 3, 4]
*
[1]
[1]
[10]

= 
[33]
[45]

*/
