// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";

contract DeployMoodNftTest is Test {
    MoodNft moodNft;
    DeployMoodNft deployScript;

    function setUp() public {
        deployScript = new DeployMoodNft();
    }

    // Test the deployment process
    function testDeployment() public {
        // Run the deployment script
        moodNft = deployScript.run();

        // Check if the contract address is non-zero (i.e., deployed successfully)
        require(address(moodNft) != address(0), "Contract deployment failed");

        // Optional: Verify if initial contract state is valid
        uint256 tokenCounter = moodNft.getTokenCounter();
        assertEq(tokenCounter, 0, "Token counter should be zero at deployment");
    }

    // Optional: Test gas usage for deployment
    function testDeploymentGasCost() public {
        uint256 gasStart = gasleft();
        moodNft = deployScript.run();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;
        emit log_named_uint("Gas used for contract deployment:", gasUsed);
        assertTrue(
            gasUsed < 500000000,
            "Gas cost should be reasonable for deployment"
        );
    }
}
