const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const { ethers } = require("hardhat");

describe("Payout something", function () {
  it("Some text", async function () {
    const Number = await ethers.getContractFactory("Lock");
    const number = await Number.deploy([1, 2, 3]);
    var array = [1, 2, 3, 4, 5];
    await number.deployed();

    await number.someLoop();
  });
});