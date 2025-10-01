// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/MyERC20.sol";

contract MyERC20Test is Test {
    MyERC20 token;

    function setUp() public {
        token = new MyERC20(1000 ether); // initial supply
    }

    // ✅ Simple unit test
    function testTransfer() public {
        token.transfer(address(1), 100 ether);
        assertEq(token.balanceOf(address(1)), 100 ether);
    }

    // ✅ Fuzz test: randomize transfer values
    function testFuzz_Transfer(uint256 amount) public {
        // Bound fuzzed amount between 0 and 1000 ether
        amount = bound(amount, 0, 1000 ether);

        token.transfer(address(1), amount);
        assertEq(token.balanceOf(address(1)), amount);
    }

    // ✅ Invariant: totalSupply must never change
    function invariant_TotalSupplyConstant() public {
        assertEq(token.totalSupply(), 1000 ether);
    }
}
