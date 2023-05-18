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

    address[] public investors;
    mapping(address => uint) private balances;

    constructor(address[] memory _securities, uint _n_assets) {
        n_securities = _securities.length;
        n_assets = _n_assets;
        investors = _securities;
    }


    function addInvestor(address _investorAddress) public {
        investors.push(_investorAddress);
        n_securities++;
    }


    function addAsset() public {
        n_assets++;
    }

    
    function getBalance(address _owner) public view returns(uint) {
        return balances[_owner];
    }
    

    function conductPayment() public payable {
        for (uint i = 0; i < n_securities; i++) {
            payable(investors[i]).transfer(balances[investors[i]]);
            balances[investors[i]] = 0;
        }
    }


    function payoutNaive(uint[][] calldata _payoutMatrix, uint[] calldata _assetsCost) public payable {
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
            balances[investors[security]] += transfer_value;
        }
    }


    function payoutSparse(uint[3][] calldata _payoutTriples, uint[] calldata _assetsCost) public payable {
        /*
        Input:
            _payoutTriples : 
            _assetsCost :    cost[1], ..., cost[n_assets] - cost of corresponding assets
        Returns:
            balances: array of balances
        */
        console.log("length=", _payoutTriples.length);
        for (uint i = 0; i < _payoutTriples.length; i++) {
            uint asset_index    = _payoutTriples[i][0];
            uint security_index = _payoutTriples[i][1];
            uint invest_value   = _payoutTriples[i][2];

            uint transfer_value = _assetsCost[asset_index] * invest_value;
            balances[investors[security_index]] += transfer_value;
        }
    }


    function payoutRepeatedColumns(uint[] calldata _column_id, uint[][] calldata _columns, uint[] calldata _assetsCost) public payable {
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
                    balances[investors[i]] += transfer_value;
                }
            }
        }
    }

    
    function payoutLowRank(int[][] calldata L, int[][] calldata R, int[] calldata _assetsCost) public payable { 
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
                balances[investors[security_index]] += uint(transfer_value);
            }
        }
     
        // O((n_assets + n_securities) * rank) time and O(rank) additional memory
    }
}

/*

General description:
* _payoutMatrix - matrix size of n_assets x n_securities
* _assetsCost   - array size of n_assets, such as i-th element is cost of corresponding asset
* investors     - array of investors corresponding to securities
* balances      - final balances of investors, return value

*/

