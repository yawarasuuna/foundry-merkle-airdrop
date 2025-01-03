// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdropScript is Script {
    error ClaimAirdropScript__InvalidSignatureLength();

    address private constant CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 private constant CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 public constant PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 public constant PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [PROOF_ONE, PROOF_TWO];
    bytes private SIGNATURE =
        hex"90f5f78b09d7d693c9818483ed95c0054b31eeca7e9c030c04b8852c5f493b7a273bf9e83798149b90f51ac8ade2febcc11dc859741fd295049b63485dd416d11c";

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address merkleAirdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(merkleAirdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);

        vm.stopBroadcast();
    }

    function splitSignature(bytes memory signature) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length != 65) {
            revert ClaimAirdropScript__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(signature, 32)) // from memory, load first 32 bytes, set into r
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96))) // mload always loads 32 bytes. The byte(0, ...) extracts just the first byte from those 32 bytes.
        }
    }
}
