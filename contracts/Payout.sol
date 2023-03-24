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

    function getBalance(address _owner) public view 
    returns(uint) {
        return balances[_owner];
    }

    // Something is wrong with this function
    function conductPayment() public payable {
        for (uint i = 0; i < n_investors; i++) {
            payable(investors[i]).transfer(balances[investors[i]]);
            balances[investors[i]] = 0;
        }
    }


    // _assetsCost = [A1, ..., An] - costs of corresponding assets
    // _payoutMatrix - matrix size of n_investors x n_assets
    function payoutNaive(uint[][] memory _payoutMatrix, uint[] memory _assetsCost) public payable {
        for (uint investor_index = 0; investor_index < n_investors; investor_index++) {
            uint transfer_value = 0;
            for (uint asset = 0; asset < n_assets; ++asset) {
                transfer_value += _payoutMatrix[investor_index][asset] * _assetsCost[asset];
            }
            balances[investors[investor_index]] += transfer_value;
        }

        // transfer money to investors
        // conductPayment();
    }


    function payoutSparse(uint[3][] memory _payoutTriples, uint[] memory _assetsCost) public payable {
        for (uint i = 0; i < _payoutTriples.length; i++) {
            uint investor_index = _payoutTriples[i][0];
            uint asset_index    = _payoutTriples[i][1];
            uint invest_value   = _payoutTriples[i][2];

            uint transfer_value = _assetsCost[asset_index] * invest_value;
            balances[investors[investor_index]] += transfer_value;
        }
        // transfer money to investors
        // conductPayment();
    }

}