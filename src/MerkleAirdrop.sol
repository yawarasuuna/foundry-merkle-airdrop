// Layout of Contract:
// version
// imports
// Errors
// Interfaces, Libraries, Contracts
// Type declarations
// State Variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// Constructor
// Receive Function (if exists)
// Fallback Function (if exists)
// External
// Public
// Internal
// Private
// Internal & Private View & Pure Functions
// External & Public View & Pure Functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {HoneyToken} from "./HoneyToken.sol";

contract MerkleAirdrop {
    // some list of address
    // allow someone in this list to claim ERC20 tokens

    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidProof();

    using SafeERC20 for IERC20;

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_alreadyClaimed;

    event Claim(address account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        // when using merkle proofs, we need to hash it again to avoid collisions (second pre-image attack)
        // keccak256 is resistent to clashes, but it is a best practice to do it twice
        if (s_alreadyClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_alreadyClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    // if we were to use for loop, it'd be gas intensive, so we use merkle proofs instead
    // merkle proof allow us to prove some piece of data that we want is in that group of data

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}