// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {console2, Script} from "forge-std/Script.sol";

contract SplitSignature is Script {
    error __SplitSignatureScript__InvalidSignatureLength();

    function splitSignature(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length != 65) {
            revert __SplitSignatureScript__InvalidSignatureLength();
        }

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }

    function run() external view {
        string memory signature = vm.readFile("signature.txt");
        bytes memory signatureBytes = vm.parseBytes(signature);
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signatureBytes);
        console2.log("v value:");
        console2.log(v);
        console2.log("r value:");
        console2.logBytes32(r);
        console2.log("s value:");
        console2.logBytes32(s);
    }
}
