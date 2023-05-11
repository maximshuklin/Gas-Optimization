// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

/** 
 * @title Dividend Payments
 * @dev Implements smart Contract for Dividend Payments
 */
contract PayoutContract {

    uint n_investors = 0;
    uint n_assets = 0;

    address[] public investors;
    mapping(address => uint) private balances;

    constructor(address[] memory _investors, uint _n_assets) {
        n_investors = _investors.length;
        n_assets = _n_assets;
        investors = _investors;
    }

    function addInvestor(address _investorAddress) public {
        investors.push(_investorAddress);
        n_investors++;
    }

    function addAsset() public {
        n_assets++;
    }

    function getBalance(address _owner) public view returns(uint) {
        return balances[_owner];
    }
    
    // Something is wrong with this function
    function conductPayment() public payable {
        for (uint i = 0; i < n_investors; i++) {
            payable(investors[i]).transfer(balances[investors[i]]);
            balances[investors[i]] = 0;
        }
    }


    // _assetsCost: [A1, ..., An] - costs of corresponding assets
    // _payoutMatrix: matrix size of n_assets x n_investors
    // so result equals to 
    // function payoutNaive(uint[][] memory _payoutMatrix, uint[] memory _assetsCost, uint[] memory _investor_idx) public payable {
    function payoutNaive(uint[][] calldata _payoutMatrix, uint[] calldata _assetsCost) public payable {
        for (uint investor_index = 0; investor_index < n_investors; investor_index++) {
            uint transfer_value = 0;
            for (uint asset = 0; asset < n_assets; ++asset) {
                transfer_value += _payoutMatrix[asset][investor_index] * _assetsCost[asset];
            }
            balances[investors[investor_index]] += transfer_value;
        }
    }


    // _payoutTriples: array of triples:
    // (investor_index, asset_index, invest_value)
    function payoutSparse(uint[3][] calldata _payoutTriples, uint[] calldata _assetsCost) public payable {
        console.log("length=", _payoutTriples.length);
        for (uint i = 0; i < _payoutTriples.length; i++) {
            uint asset_index    = _payoutTriples[i][0];
            uint investor_index = _payoutTriples[i][1];
            uint invest_value   = _payoutTriples[i][2];

            uint transfer_value = _assetsCost[asset_index] * invest_value;
            balances[investors[investor_index]] += transfer_value;
        }
    }

    function payoutRepeatedColumns(uint[] calldata column_id, uint[][] calldata columns, uint[] calldata _assetsCost) public payable {
        for (uint col = 0; col < columns.length; ++col) {
            uint transfer_value = 0;
            for (uint i = 0; i < _assetsCost.length; ++i) {
                transfer_value += _assetsCost[i] * columns[col][i];
            }
            for (uint i = 0; i < columns.length; ++i) {
                if (column_id[i] == col) {
                    balances[investors[i]] += transfer_value;
                }
            }
        }
    }

    
    // payoutMatrix = L @ R
    // (_assetsCost @ L) @ R
    // L is n_assets x rank
    // R is rank x n_investors
    // len(_assetsCost) = n_assets
    function payoutLowRank(uint[][] calldata L, uint[][] calldata R, uint[] calldata _assetsCost) public payable { 
        uint rank = L[0].length;
        uint[] memory temp = new uint[](rank);
        for (uint col = 0; col < rank; ++col) {
            uint value = 0;
            for (uint i = 0; i < n_assets; ++i) {
                value += _assetsCost[i] * L[i][col];
            }
            temp[col] = value;
        }
        for (uint j = 0; j < n_investors; ++j) {
            uint transfer_value = 0;
            for (uint i = 0; i < rank; ++i) {
                transfer_value += temp[i] * R[i][j];
            }
            uint investor_index = j;
            balances[investors[investor_index]] += transfer_value;
        }
     
        // O((n_assets + n_investors) * rank) time and O(rank) additional memory
    }
}

/*

[A A A A A B B B B B C C C C C]

[A A A A A A A A B B B B C D E F G H T]

строки - активы
столбцы - ценные бумаги


Матрица A

A = U @ V --> f(U, V)


|
|
|

i [.....]
i [.....]
i [.....]

*/









/*

Consider _payoutMatrix size of n_assets x n_investors.
Assume we have a lot of repeating columns (different investors by similar packages).
In this case we can think of low-rank matrix

*/







