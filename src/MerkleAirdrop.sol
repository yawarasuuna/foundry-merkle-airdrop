// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdrop is EIP712 {
    /*//////////////////////////////////////////////////////////////
                                 Errors
    //////////////////////////////////////////////////////////////*/

    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__InvalidSignature();

    /*//////////////////////////////////////////////////////////////
                                 Types
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /*//////////////////////////////////////////////////////////////
                            State Variables
    //////////////////////////////////////////////////////////////*/

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_alreadyClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    /*//////////////////////////////////////////////////////////////
                                 Events
    //////////////////////////////////////////////////////////////*/

    event Claim(address account, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                               Functions
    //////////////////////////////////////////////////////////////*/

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                           External Functions
    //////////////////////////////////////////////////////////////*/

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (s_alreadyClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            // message == digest
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_alreadyClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                            Public Functions
    //////////////////////////////////////////////////////////////*/

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    /*//////////////////////////////////////////////////////////////
                           Internal Functions
    //////////////////////////////////////////////////////////////*/

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        // return ecrecover(digest, v, r, s) == account; // unsafe low level call
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

    /*//////////////////////////////////////////////////////////////
                       External & View Functions
    //////////////////////////////////////////////////////////////*/

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
