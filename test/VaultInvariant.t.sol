// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/Vault.sol";

contract VaultInvariantTest is Test {
    Vault vault;
    address user1 = address(1111);
    address user2 = address(2222);

    function setUp() public {
        vault = new Vault();
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    // Invariant: balances should never go negative
    function invariant_BalanceNonNegative() public view {
        assertGe(vault.balances(user1), 0);
        assertGe(vault.balances(user2), 0);
    }

    // Invariant: total ETH in contract = sum of balances
    function invariant_TotalETHMatchesBalances() public view {
        uint256 total = vault.balances(user1) + vault.balances(user2);
        assertEq(address(vault).balance, total);
    }
}
