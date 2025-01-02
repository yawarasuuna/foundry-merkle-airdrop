// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HoneyToken is ERC20, Ownable {
    constructor() ERC20("Honey", "HNY") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

// ECDSA elliptic curve digital signature algorithm

// generate keys pairs
// create/authenticate signatures
// verify signatures/messages

// signatures
// provide auth in blockchain tech
// verify message/tx originates from intended sender

// signature malleability > form of replay attack which derives the second signature v',r,s' from a known v,r,s on the elliptic curve

// Secp256k1 curve constants:
// 1. Generator Point G: random constant point on the curve
// 2. Order n: defines length of the private key. Prime number generated using G, which is the order of the subgroup of the ECurve points

// v x point on secp256k1 curve
// r polarity, if in + or - part of the curve on y axis
// s proof signer knows priv key

// Transaction types
//  0x00

//  0x01 - EIP-2930, Berlin fork, same as Legacy, but fixes possible breakage risks introduced by EIP-2929, with EIP 2930,
//  which introduces optional access list, which contains an array of addresses and storage keys,
//  enabling gas savings on cross contract calls by pre declaring allowed contracts and storage slots

//  0x02 - EIP-1559, London fork, replaces gasPrice with baseFee
//  new parameters (maxPriorityFeePerGas, maxFeePerGas (maxPriorityFeePerGas + baseFee))

//  0x03 - EIP-4844, Dencun fork, blob tx, non-refundable tx, fee burned before tx executes
//  new parameters (max_blob_fee_per_gas, blob_versioned_hashes)

//  zkSync tx types

//  0x71 - EIP- 712, type 113, defines typed structed data hashing and signing. enables access to zksync specific feat like acc abstraction, and paymasters
//  smart contracts must be deployed using type 113 tx
//  new parameters (gasPerPubData, customsSignature, paymasterParam, factory_deps)
//  gasPerPubData: max gas sender is willing to pay for a single byte of pub data (L2 state data submitted to L1);
//  customsSignature: when signer acc isnt an EOA;
//  paymasterParam: configures customs paymaster , like a smart contract that pays the transaction for us;
//  factory_deps:  contains bytecode of the smart contract being deployed;

//  0xff - L1 -> L2 tx directly in zkSync, priority tx
