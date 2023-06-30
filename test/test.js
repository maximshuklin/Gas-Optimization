const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const { ethers } = require("hardhat");


const getBunchOfSigners = (n) => {
    const signers = [];
    for (let i = 0; i < n; i++) {
        signers.push(ethers.Wallet.createRandom().address);
    }
    return signers;
};



describe("Payout something", function () {
    it("Payout Naive. Python Test", async function() {
        const Payout = await ethers.getContractFactory("PayoutContract");

        var json = require('./data/naive.json');
        const n_assets = json.n_assets;
        const n_securities = json.n_securities;
        const matrix = json.matrix;
        const assets_cost = json.assets_cost;
        const investors = json.investors;

        const signers = getBunchOfSigners(n_securities);

        const payout = await Payout.deploy(signers, n_assets);
        await payout.deployed();

        await payout.payoutNaive(matrix, assets_cost, investors);
    });


    it("Payout Sparse. Python Test", async function() {
        const Payout = await ethers.getContractFactory("PayoutContract");

        var json = require('./data/sparse.json');
        const n_assets = json.n_assets;
        const n_securities = json.n_securities;
        const matrix = json.matrix;
        const payoutTriples = json.payout_triples;
        const assets_cost = json.assets_cost;
        const investors = json.investors;

        const signers = getBunchOfSigners(n_securities);

        const payout = await Payout.deploy(signers, n_assets);
        await payout.deployed();

        await payout.payoutSparse(payoutTriples, assets_cost, investors);
    });


    it("Payout Repeated Columns. Python Test", async function() {
        const Payout = await ethers.getContractFactory("PayoutContract");

        var json = require('./data/repeated_columns.json');
        const n_assets = json.n_assets;
        const n_securities = json.n_securities;
        const matrix = json.matrix;
        const assets_cost = json.assets_cost;
        const column_id = json.column_id;
        const columns = json.columns;
        const investors = json.investors;

        const signers = getBunchOfSigners(n_securities);

        const payout = await Payout.deploy(signers, n_assets);
        await payout.deployed();

        await payout.payoutRepeatedColumns(column_id, columns, assets_cost, investors);
    });


    it("Payout LowRank. Python Test", async function() {
        const Payout = await ethers.getContractFactory("PayoutContract");

        var json = require('./data/low_rank.json');
        const n_assets = json.n_assets;
        const n_securities = json.n_securities;
        const matrix = json.matrix;
        const assets_cost = json.assets_cost;
        const L = json.L;
        const R = json.R;
        const investors = json.investors;

        const signers = getBunchOfSigners(n_securities);

        const payout = await Payout.deploy(signers, n_assets);
        await payout.deployed();

        await payout.payoutLowRank(L, R, assets_cost, investors);
    });


    it("payoutRepeatedInvestors. Python Test", async function() {
        const Payout = await ethers.getContractFactory("PayoutContract");

        var json = require('./data/naive.json');
        const n_assets = json.n_assets;
        const n_securities = json.n_securities;
        const matrix = json.matrix;
        const assets_cost = json.assets_cost;
        const investors = json.investors;

        const signers = getBunchOfSigners(n_securities);

        const payout = await Payout.deploy(signers, n_assets);
        await payout.deployed();

        await payout.payoutRepeatedInvestors(matrix, assets_cost, investors);
    });
});