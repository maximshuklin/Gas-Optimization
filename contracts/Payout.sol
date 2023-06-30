// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

/** 
 * @title Dividend Payments
 * @dev Implements smart Contract for Dividend Payments
 */
contract PayoutContract {

    uint n_securities = 0;
    uint n_assets = 0;

    address[] public investor_address; // unique addresses of investors
    mapping(address => uint) private balances;

    constructor(address[] memory _investor_address, uint _n_assets) {
        investor_address = _investor_address;
        n_securities = _investor_address.length;
        n_assets = _n_assets;
    }

    
    function getBalance(address _owner) public view returns(uint) {
        return balances[_owner];
    }
    

    function payoutNaive(
                   uint[][] memory _payoutMatrix,
                   uint[] calldata _assetsCost,
                   uint[] calldata investors) public payable {
        /*
        Input:
            _payoutMatrix : n_assets x n_securities matrix
            _assetsCost :   cost[1], ..., cost[n_assets] - cost of corresponding assets
        Returns:
            balances: array of balances
        */
        for (uint security = 0; security < n_securities; security++) {
            uint transfer_value = 0;
            for (uint asset = 0; asset < n_assets; ++asset) {
                transfer_value += _payoutMatrix[asset][security] * _assetsCost[asset];
            }
            balances[investor_address[investors[security]]] += transfer_value;
        }
    }


    function payoutSparse(
                   uint[3][] calldata _payoutTriples,
                   uint[] calldata _assetsCost,
                   uint[] calldata investors) public payable {
        /*
        Input:
            _payoutTriples : 
            _assetsCost :    cost[1], ..., cost[n_assets] - cost of corresponding assets
        Returns:
            balances: array of balances
        */
        for (uint i = 0; i < _payoutTriples.length; i++) {
            uint asset_index    = _payoutTriples[i][0];
            uint security_index = _payoutTriples[i][1];
            uint invest_value   = _payoutTriples[i][2];

            uint transfer_value = _assetsCost[asset_index] * invest_value;
            balances[investor_address[investors[security_index]]] += transfer_value;
        }
    }


    function payoutRepeatedColumns(
                   uint[] calldata _column_id,
                   uint[][] calldata _columns,
                   uint[] calldata _assetsCost,
                   uint[] calldata investors) public payable {
        /*
        Input:
            _column_id :  array size of n_securities
            _columns :    matrix size of (n_different_columns x n_assets)
            _assetsCost : cost[1], ..., cost[n_assets] - cost of corresponding assets
        Returns:
            balances: array of balances
        */
        for (uint col = 0; col < _columns.length; ++col) {
            uint transfer_value = 0;
            for (uint i = 0; i < _assetsCost.length; ++i) {
                transfer_value += _assetsCost[i] * _columns[col][i];
            }
            for (uint i = 0; i < _columns.length; ++i) {
                if (_column_id[i] == col) {
                    balances[investor_address[investors[i]]] += transfer_value;
                }
            }
        }
    }

    
    function payoutLowRank(
                   int[][] calldata L,
                   int[][] calldata R,
                   int[] calldata _assetsCost,
                   uint[] calldata investors) public payable { 
        /*
        Input:
            L :           n_assets x rank
            R :           rank x n_securities
            _assetsCost : cost[1], ..., cost[n_assets] - cost of corresponding assets
            payoutMatrix = L @ R - matrix decomposition
        Returns:
            balances: array of balances
        */
        uint rank = L[0].length;
        int[] memory temp = new int[](rank);
        for (uint col = 0; col < rank; ++col) {
            int value = 0;
            for (uint i = 0; i < n_assets; ++i) {
                value += _assetsCost[i] * L[i][col];
            }
            temp[col] = value;
        }
        for (uint j = 0; j < n_securities; ++j) {
            int transfer_value = 0;
            for (uint i = 0; i < rank; ++i) {
                transfer_value += temp[i] * R[i][j];
            }
            uint security_index = j;
            if (transfer_value > 0) {
                balances[investor_address[investors[security_index]]] += uint(transfer_value);
            }
        }
     
        // O((n_assets + n_securities) * rank) time and O(rank) additional memory
    }

    function payoutRepeatedInvestors(
                   uint[][] memory _payoutMatrix,
                   uint[] calldata _assetsCost,
                   uint[] memory investors) public payable {
        /*
            - Description
        */
        uint[] memory was_index = new uint[](n_securities); // indexing from 1
        uint unique_counter = 0;
        for (uint column = 0; column < n_securities; ++column) {
            uint index = was_index[investors[column]];
            if (index != 0) {
                --index;
                for (uint i = 0; i < n_assets; ++i) {
                    _payoutMatrix[i][index] += _payoutMatrix[i][column];
                }
            } else {
                if (column != unique_counter) {
                    for (uint i = 0; i < n_assets; ++i) {
                        _payoutMatrix[i][unique_counter] = _payoutMatrix[i][column];
                    }
                }
                was_index[investors[column]] = unique_counter + 1;
                investors[unique_counter] = investors[column];
                ++unique_counter;
            }
        }
        // multiplication
        for (uint security = 0; security < unique_counter; security++) {
            uint transfer_value = 0;
            for (uint asset = 0; asset < n_assets; ++asset) {
                transfer_value += _payoutMatrix[asset][security] * _assetsCost[asset];
            }
            balances[investor_address[investors[security]]] += transfer_value;
        }

    }

}

/*

General description:
* _payoutMatrix - matrix size of n_assets x n_securities
* _assetsCost   - array size of n_assets, such as i-th element is cost of corresponding asset
* investors     - array of investors corresponding to securities
* balances      - final balances of investors, return value

*/

