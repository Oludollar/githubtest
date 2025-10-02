// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/Vault.sol";

/// @notice Handler contract exposes actions for Foundry fuzzing
contract VaultHandler is Test {
    Vault vault;
    address[] users;

    constructor(Vault _vault) {
        vault = _vault;

        // Create a few test users
        for (uint160 i = 1; i <= 3; i++) {
            address user = address(i);
            users.push(user);
            vm.deal(user, 100 ether); // each user starts with 100 ETH
        }
    }

    // Random deposit for a random user
    function depositETH(uint256 userIndex, uint256 amount) public {
        userIndex = bound(userIndex, 0, users.length - 1);
        address user = users[userIndex];

        amount = bound(amount, 1, 10 ether); // cap deposits
        vm.prank(user);
        vault.deposit{value: amount}();
    }

    // Random withdraw for a random user
    function withdrawETH(uint256 userIndex, uint256 amount) public {
        userIndex = bound(userIndex, 0, users.length - 1);
        address user = users[userIndex];

        uint256 bal = vault.balances(user);
        if (bal == 0) return; // skip if user has nothing

        amount = bound(amount, 1, bal);
        vm.prank(user);
        vault.withdraw(amount);
    }

    // Expose tracked users
    function getUsers() external view returns (address[] memory) {
        return users;
    }

    receive() external payable {}
}

/// @notice Combined Fuzz + Invariant test suite
contract VaultCombinedTest is Test {
    Vault vault;
    VaultHandler handler;

    function setUp() public {
        vault = new Vault();
        handler = new VaultHandler(vault);

        // Tell Foundry to fuzz across handler functions
        targetContract(address(handler));
    }

    // -------------------------
    // Invariants
    // -------------------------

    /// Invariant 1: Vault balance must equal sum of all user balances
    function invariant_TotalBalanceMatches() public {
        address[] memory users = handler.getUsers();
        uint256 sumBalances;

        for (uint256 i = 0; i < users.length; i++) {
            sumBalances += vault.balances(users[i]);
        }

        assertEq(address(vault).balance, sumBalances, "Vault balance mismatch!");
    }

    /// Invariant 2: No user should ever have a negative balance
    function invariant_NonNegativeBalances() public {
        address[] memory users = handler.getUsers();

        for (uint256 i = 0; i < users.length; i++) {
            assertGe(vault.balances(users[i]), 0, "Negative balance detected!");
        }
    }

    /// Invariant 3: Withdraw should never pull more than available
    function invariant_NoOverdraft() public {
        address[] memory users = handler.getUsers();

        for (uint256 i = 0; i < users.length; i++) {
            assertLe(vault.balances(users[i]), address(vault).balance, "Overdraft detected!");
        }
    }
}
