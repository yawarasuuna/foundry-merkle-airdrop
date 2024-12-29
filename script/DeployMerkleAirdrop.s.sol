// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Script} from "forge-std/Script.sol";
import {HoneyToken} from "../src/HoneyToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountInitialMint = 4 * 25 * 1e18;

    function run() external returns (MerkleAirdrop, HoneyToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, HoneyToken) {
        vm.startBroadcast();
        HoneyToken honeyToken = new HoneyToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(honeyToken)));
        honeyToken.mint(honeyToken.owner(), s_amountInitialMint);
        honeyToken.transfer(address(merkleAirdrop), s_amountInitialMint);
        vm.stopBroadcast();
        return (merkleAirdrop, honeyToken);
    }
}
