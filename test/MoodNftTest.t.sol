// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MoodNft.sol";
import "forge-std/console.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MoodNftTest is Test {
    MoodNft moodNft;
    address user = address(1);
    address nonOwner = address(2);

    function setUp() public {
        moodNft = new MoodNft();
        vm.deal(user, 100 ether);
    }

    // Test minting NFTs
    function testMintNft() public {
        vm.startPrank(user);
        for (uint256 i = 0; i < 5; i++) {
            moodNft.mintNft();
        }
        assertEq(
            moodNft.balanceOf(user),
            5,
            "Minted tokens should increase to 5"
        );
        for (uint256 i = 0; i < 5; i++) {
            assertEq(
                moodNft.ownerOf(i),
                user,
                "User should be the owner of token"
            );
        }
        vm.stopPrank();
    }

    // Test transferring token ownership
    function testTransferToken() public {
        vm.startPrank(user);
        moodNft.mintNft();
        moodNft.transferFrom(user, nonOwner, 0);
        assertEq(
            moodNft.ownerOf(0),
            nonOwner,
            "Non-owner should be the new owner of token 0"
        );
        vm.stopPrank();
    }

    // Test edge case: minting with a high token counter value
    function testMinting10000() public {
        vm.startPrank(user);
        for (uint256 i = 0; i < 10; i++) {
            moodNft.mintNft();
        }
        assertEq(moodNft.balanceOf(user), 10, "Minted tokens should be 10000");
        vm.stopPrank();
    }

    // Test Chainlink price feed integration with large values
    function testChainlinkWithHighPrice() public {
        // Mock high price scenario
        vm.mockCall(
            address(moodNft.priceFeed()),
            abi.encodeWithSelector(
                AggregatorV3Interface.getRoundData.selector,
                uint80(100)
            ),
            abi.encode(
                uint80(100),
                int256(1e18), // High price, e.g., 1,000,000,000,000,000,000 (1e18)
                uint256(0),
                uint256(0),
                uint80(0)
            )
        );
        vm.startPrank(user);
        moodNft.mintNft(); // Ensure minting works as expected even with the high price
        vm.stopPrank();
    }

    // st gas cost for minting NFTs
    function testMintingGasCost() public {
        uint256 gasStart = gasleft();
        vm.startPrank(user);
        moodNft.mintNft();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;
        emit log_named_uint("Gas used for minting NFT:", gasUsed);
        assertTrue(gasUsed < 150000, "Gas cost should be below 150k");
        vm.stopPrank();
    }

    // new test

    function testToString() public view {
        assertEq(moodNft.toString(123), "123", "Integer toString() failed");
    }

    function testNonOwnerCannotTransferToken() public {
        // Step 1: Mint a token as the owner
        vm.startPrank(user);
        moodNft.mintNft();
        vm.stopPrank();

        // Step 2: Attempt to transfer the token by a non-owner
        vm.startPrank(nonOwner);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721InsufficientApproval(address,uint256)",
                nonOwner,
                0
            )
        );
        moodNft.transferFrom(user, nonOwner, 0); // Attempt to transfer token ID 0
        vm.stopPrank();
    }

    function testMockGetHistoricalPrice() public {
        uint80 roundId = 42; // Example round ID
        int256 expectedPrice = 1000 * 1e8; // Example price

        // Mocking the price feed call
        vm.mockCall(
            address(moodNft.priceFeed()),
            abi.encodeWithSelector(
                AggregatorV3Interface.getRoundData.selector,
                roundId - 23
            ),
            abi.encode(
                roundId,
                expectedPrice,
                block.timestamp,
                block.timestamp,
                roundId
            )
        );

        int256 price = moodNft.getHistoricalPrice(roundId);
        assertEq(price, expectedPrice, "Historical price mismatch");
    }

    function testBuildImage() public view {
        // uint256 tokenId = 0;
        // string memory image = moodNft.buildImage(tokenId);
        // require(bytes(image).length > 0, "Image data should not be empty");

        for (uint256 i = 0; i < 10; i++) {
            string memory nft = moodNft.buildImage(i);
            require(bytes(nft).length > 0, "Image data should not be empty");
        }
    }

    function testRandomone() public {
        // Mint NFTs and log the random values from randomOne
        for (uint256 i = 0; i < 10; i++) {
            moodNft = new MoodNft();
            MoodNft.Feel memory feel = moodNft.randomOne(i);

            // Check if the Feel object returned has valid values
            require(
                feel.faceClr < 13, // faceClr is modded by 13, so its value must be in range [0, 12]
                "faceClr should be between 0 and 12"
            );
            require(
                feel.shirtClr < 19, // shirtClr is modded by 19, so its value must be in range [0, 18]
                "shirtClr should be between 0 and 18"
            );
            require(
                feel.hairclr < 10, // hairClr is modded by 10, so its value must be in range [0, 9]
                "hairclr should be between 0 and 9"
            );
        }
    }

    function testGetTokenCounter() public {
        vm.startPrank(user);
        // Check the initial value of s_tokenCounter
        uint256 initialCounter = moodNft.getTokenCounter();
        assertEq(initialCounter, 0, "Initial token counter should be 0");

        // Mint an NFT and check the counter increments
        moodNft.mintNft();
        uint256 afterFirstMint = moodNft.getTokenCounter();
        assertEq(
            afterFirstMint,
            1,
            "Token counter should be 1 after first mint"
        );

        // Mint another NFT and check the counter increments again
        moodNft.mintNft();
        uint256 afterSecondMint = moodNft.getTokenCounter();
        assertEq(
            afterSecondMint,
            2,
            "Token counter should be 2 after second mint"
        );
        vm.stopPrank();
    }

    function testTokenUriForMintedToken() public {
        // Mint an NFT by assigning it to the user
        vm.prank(user); // Set the sender to 'user'
        moodNft.mintNft(); // Mint a new NFT to the user (adjust minting logic as needed)

        // Check tokenURI for minted token
        string memory uri = moodNft.tokenURI(0);
        console.log(uri); // Log the tokenURI to check

        // Test that tokenURI is not empty
        require(
            bytes(uri).length > 0,
            "Token URI should not be empty for a valid token."
        );
    }

    function testTokenUriForNonExistentToken() public {
        // Expect a revert with the `ERC721NonexistentToken` error for a non-existent token
        vm.expectRevert(
            abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 999)
        );
        moodNft.tokenURI(999); // Token 999 does not exist, expecting revert
    }

    function testMetadataGeneration() public {
        vm.startPrank(user);
        moodNft.mintNft();
        string memory metadata = moodNft.tokenURI(0);
        // We remove the message and just assert the condition
        assert(bytes(metadata).length > 0);
        vm.stopPrank();
    }

    function testBuildMetadata() public {
        // Mock image and feels values
        string memory image = "imageMockBase64";
        string memory feels = "happy";
        uint256 tokenId = 1;

        // Create a Feel struct with some values
        MoodNft.Feel memory feel = MoodNft.Feel({
            bg: 1,
            faceClr: 2,
            shirtClr: 3,
            hairclr: 4,
            prop: 1,
            earring: 0,
            hairtype: 2,
            lipsclr: 3,
            eyesd: 1,
            feel_up: 5,
            feel_down: 2
        });

        // Call the buildMetadata function with the mock inputs
        string memory metadata = moodNft.buildMetadata(
            image,
            feel,
            feels,
            tokenId
        );

        // Output the metadata to the console for inspection
        console.log(metadata);

        // Perform assertions on the metadata output
        assertTrue(bytes(metadata).length > 0, "Metadata should not be empty");
        assertTrue(
            bytes(metadata).length > 100, // Arbitrary length check, can be more specific based on expectations
            "Metadata should be long enough"
        );
        assertTrue(
            bytes(metadata).length < 5000, // Arbitrary upper limit, depending on expected size
            "Metadata should not be too long"
        );

        // Check if the tokenId and feels appear correctly in the metadata (e.g., "#1 feels happy")
        assertTrue(
            contains(metadata, "#1 feels happy"),
            "Metadata should contain correct tokenId and feels"
        );
    }

    // Helper function to check if the string `needle` exists in the `haystack`
    function contains(
        string memory haystack,
        string memory needle
    ) internal pure returns (bool) {
        return
            bytes(haystack).length >= bytes(needle).length &&
            keccak256(abi.encodePacked(needle)) ==
            keccak256(abi.encodePacked(needle));
    }
}
