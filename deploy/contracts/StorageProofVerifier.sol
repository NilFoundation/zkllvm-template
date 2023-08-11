// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2023 Ilya Marozau <ilya.marozau@nil.foundation>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//---------------------------------------------------------------------------//
pragma solidity >=0.8.4;

import '@nilfoundation/evm-placeholder-verification/contracts/interfaces/verifier.sol';
import "./IStorageProofVerifier.sol";

contract StorageProofVerifier is IStorageProofVerifier {
    
    address verifier;
    address owner;
    address gate_argument;
    constructor(address _verifier, address _gate_argument) {
        owner = msg.sender;
        verifier = _verifier;
        gate_argument = _gate_argument;
    }

    function setVerifierAddress(address _verifier) public {
        require(msg.sender == owner, "Not owner!");
        verifier = _verifier;
    }

    function setGateAddress(address _gate_argument) public {
        require(msg.sender == owner, "Not owner!");
        gate_argument = _gate_argument;
    }

    function verifyStorageProof(
        bytes calldata _blob, 
        uint256[] calldata _init_params,
        int256[][] calldata _columns_rotations, 
        bytes32 _root,
        bytes32 _leaf
    ) external returns (bool result) {

        result = IVerifier(verifier).verify(_blob, _init_params, _columns_rotations, gate_argument);

        emit VerificationStatusPositive(result);
    }
}
