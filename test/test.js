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
    // it("Payout Naive. Small Test", async function() {
    //     const Payout = await ethers.getContractFactory("PayoutContract");
    //     const [owner, user1, user2] = await ethers.getSigners();
    //     const payout = await Payout.deploy([user1.address, user2.address], 3);
    //     await payout.deployed();

    //     await payout.payoutNaive([
    //       [1, 2],
    //       [2, 3],
    //       [3, 4]
    //     ], [1, 1, 10]);


    //     expect(await payout.getBalance(user1.address)).to.equal(33);
    //     expect(await payout.getBalance(user2.address)).to.equal(45);
    // });
    
    // it("Payout Sparse. Small Test", async function() {
    //     const Payout = await ethers.getContractFactory("PayoutContract");
    //     const [owner, user1, user2] = await ethers.getSigners();
    //     // console.log(user1);
    //     const payout = await Payout.deploy([user1.address, user2.address], 3);
    //     await payout.deployed();

    //     await payout.payoutSparse([
    //       [0, 0, 1],
    //       [0, 1, 2],
    //       [0, 2, 3],
    //       [1, 0, 2],
    //       [1, 1, 3],
    //       [1, 2, 4]
    //     ], [1, 1, 10]);


    //     expect(await payout.getBalance(user1.address)).to.equal(33);
    //     expect(await payout.getBalance(user2.address)).to.equal(45);
    // });

    // it("Payout Naive. Big Random Test", async function() {
    //     const Payout = await ethers.getContractFactory("PayoutContract");

    //     const n_investors = 30;
    //     const n_assets = 50;
    //     const signers = getBunchOfSigners(n_investors);
    //     const assets_costs = Array.from({length: n_assets}, () => Math.floor(Math.random() * 100));
    //     const payout_matrix = [];
    //     for (let i = 0; i < n_investors; i++) {
    //       payout_matrix.push(Array.from({length: n_assets}, () => Math.floor(Math.random() * 100)));
    //     }
        
    //     const payout = await Payout.deploy(signers, n_assets);
    //     await payout.deployed();

    //     await payout.payoutNaive(payout_matrix, assets_costs);
    // });



    

    it("Payout Naive. Python Test", async function() {
        const Payout = await ethers.getContractFactory("PayoutContract");

        var json = require('./data/naive.json');
        const n_assets = json.n_assets;
        const n_securities = json.n_securities;
        const matrix = json.matrix;
        const assets_cost = json.assets_cost;

        const signers = getBunchOfSigners(n_securities);

        const payout = await Payout.deploy(signers, n_assets);
        await payout.deployed();

        await payout.payoutNaive(matrix, assets_cost);
    });

    it("Payout Sparse. Python Test", async function() {
        const Payout = await ethers.getContractFactory("PayoutContract");

        var json = require('./data/sparse.json');
        const n_assets = json.n_assets;
        const n_securities = json.n_securities;
        const matrix = json.matrix;
        const payoutTriples = json.payout_triples;
        const assets_cost = json.assets_cost;

        const signers = getBunchOfSigners(n_securities);

        const payout = await Payout.deploy(signers, n_assets);
        await payout.deployed();

        await payout.payoutSparse(payoutTriples, assets_cost);
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

        const signers = getBunchOfSigners(n_securities);

        const payout = await Payout.deploy(signers, n_assets);
        await payout.deployed();

        await payout.payoutRepeatedColumns(column_id, columns, assets_cost);
    });

});

