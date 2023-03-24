// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Lock {
    uint[] numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    constructor (uint[] memory arr) {
        for (uint i = 0; i < arr.length; i++) {
            numbers[i] = arr[i];
        }
    }

    function someLoop() public {
        for (uint i = 0; i < numbers.length; i++) {
            numbers[i] = 0;
        }
    }

    function someLoop2() public {
        for (uint i = 0; i < numbers.length; ++i) {
            numbers[i] = 0;
        }
    }

}
