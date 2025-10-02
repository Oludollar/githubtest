// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/Vault.sol";

contract VaultFuzzTest is Test {
    Vault vault;

    function setUp() public {
        vault = new Vault();
    }

    // Fuzzing test: random deposit values
    function testFuzz_Deposit(uint256 amount) public {
        vm.assume(amount > 0 && amount < 100 ether); // avoid crazy inputs

        // Deposit from a random user
        address user = address(1234);
        vm.deal(user, amount);
        vm.prank(user);
        vault.deposit{value: amount}();

        // Check that balance updated
        assertEq(vault.balances(user), amount);
    }

    // Fuzzing test: random withdraw values
    function testFuzz_Withdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        vm.assume(depositAmount > 0 && depositAmount < 100 ether);
        vm.assume(withdrawAmount <= depositAmount);

        address user = address(5678);
        vm.deal(user, depositAmount);
        vm.startPrank(user);

        vault.deposit{value: depositAmount}();

        vault.withdraw(withdrawAmount);

        // Check remaining balance
        assertEq(vault.balances(user), depositAmount - withdrawAmount);

        vm.stopPrank();
    }
}
