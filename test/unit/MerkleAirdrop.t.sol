// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {console2, Test} from "forge-std/Test.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";
import {HoneyToken} from "../../src/HoneyToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {ZkSyncChainChecker} from "../../lib/foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    HoneyToken public honeyToken;
    MerkleAirdrop public merkleAirdrop;

    address public GAS_PAYER;
    address USER;
    uint256 userPrivKey;
    uint256 public constant AMOUNT_TO_AIRDROP = 25 * 1e18;
    uint256 public constant AMOUNT_INITAL_MINT = AMOUNT_TO_AIRDROP * 10;
    bytes32 public constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 public constant PROOF_ONE = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public constant PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [PROOF_ONE, PROOF_TWO];

    function setUp() external {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployMerkleAirdrop = new DeployMerkleAirdrop();
            (merkleAirdrop, honeyToken) = deployMerkleAirdrop.deployMerkleAirdrop();
        } else {
            honeyToken = new HoneyToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, honeyToken);
            honeyToken.mint(honeyToken.owner(), AMOUNT_INITAL_MINT);
            honeyToken.transfer(address(merkleAirdrop), AMOUNT_INITAL_MINT);
        }
        (USER, userPrivKey) = makeAddrAndKey("user");
        GAS_PAYER = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = honeyToken.balanceOf(USER);
        bytes32 digest = merkleAirdrop.getMessageHash(USER, AMOUNT_TO_AIRDROP);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest); // signing doest need to prank USER to call it

        vm.prank(GAS_PAYER);
        merkleAirdrop.claim(USER, AMOUNT_TO_AIRDROP, proof, v, r, s);

        uint256 endingBalance = honeyToken.balanceOf(USER);

        assertEq(startingBalance, 0);
        assertEq(endingBalance, AMOUNT_TO_AIRDROP);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_AIRDROP);
    }
}
