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

import "@nilfoundation/evm-placeholder-verification/contracts/types.sol";
import "@nilfoundation/evm-placeholder-verification/contracts/basic_marshalling.sol";
import "@nilfoundation/evm-placeholder-verification/contracts/commitments/batched_lpc_verifier.sol";
import "@nilfoundation/evm-placeholder-verification/contracts/interfaces/gate_argument.sol";

contract GateArgument is IGateArgument{
    uint256 constant GATES_N = 1;

    uint256 constant MODULUS_OFFSET = 0x0;
    uint256 constant THETA_OFFSET = 0x20;

    uint256 constant CONSTRAINT_EVAL_OFFSET = 0x00;
    uint256 constant GATE_EVAL_OFFSET = 0x20;
    uint256 constant GATES_EVALUATIONS_OFFSET = 0x40;
    uint256 constant THETA_ACC_OFFSET = 0x60;
    uint256 constant WITNESS_EVALUATIONS_OFFSET = 0x80;
    uint256 constant SELECTOR_EVALUATIONS_OFFSET =0xa0;

    // TODO: columns_rotations could be hard-coded
    // gate argument local variables may be different for different circuits
    struct local_vars_type {
        // 0x0
        uint256 constraint_eval;
        // 0x20
        uint256 gate_eval;
        // 0x40
        uint256 gates_evaluation;
        // 0x60
        uint256 theta_acc;
        // 0x80
        uint256[][] witness_evaluations;
        // 0xa0
        uint256[] selector_evaluations;
    }

    function evaluate_gates_be(
        bytes calldata blob,
        uint256 eval_proof_combined_value_offset,
        types.gate_argument_params memory gate_params,
        types.arithmetization_params memory ar_params,
        int256[][] memory columns_rotations
    ) external pure returns (uint256 gates_evaluation) {
        local_vars_type memory local_vars;
        local_vars.witness_evaluations = new uint256[][](ar_params.witness_columns);
        for (uint256 i = 0; i < ar_params.witness_columns; i++) {
            local_vars.witness_evaluations[i] = new uint256[](columns_rotations[i].length);
            for (uint256 j = 0; j < columns_rotations[i].length; j++) {
                local_vars.witness_evaluations[i][j] = batched_lpc_verifier.get_variable_values_z_i_j_from_proof_be(
                    blob, eval_proof_combined_value_offset, i, j
                );
            }
        }

        local_vars.selector_evaluations = new uint256[](GATES_N);
        for (uint256 i = 0; i < GATES_N; i++) {
            local_vars.selector_evaluations[i] = batched_lpc_verifier.get_fixed_values_z_i_j_from_proof_be(
                    blob,
                    eval_proof_combined_value_offset,
                    i + ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns,
                    0
            );
        }

        uint256 t = 0;
        assembly {
            let modulus := mload(gate_params)
            let theta := mload(add(gate_params, THETA_OFFSET))

            let theta_acc := 1
            mstore(add(local_vars, GATE_EVAL_OFFSET), 0)

            function get_eval_i_by_rotation_idx(idx, rot_idx, ptr) -> result {
                result := mload(add(add(mload(add(add(ptr, 0x20), mul(0x20, idx))), 0x20),
                          mul(0x20, rot_idx)))
            }

            function get_selector_i(idx, ptr) -> result {
                result := mload(add(add(ptr, 0x20), mul(0x20, idx)))
            }
            
            let x1 := add(local_vars, CONSTRAINT_EVAL_OFFSET)
            let x2 := add(local_vars, WITNESS_EVALUATIONS_OFFSET)
            let x3 := get_eval_i_by_rotation_idx(0, 0, mload(x2))
            let x4 := get_eval_i_by_rotation_idx(2, 0, mload(x2))
            mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x3, get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, get_eval_i_by_rotation_idx(1, 0, mload(x2)), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, get_eval_i_by_rotation_idx(3, 0, mload(x2)), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x4, mulmod(x3, get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x4, mulmod(x4, get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x4, get_eval_i_by_rotation_idx(1, 0, mload(x2)), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x4, get_eval_i_by_rotation_idx(3, 0, mload(x2)), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(0x2, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe, mulmod(x3, x3, modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x2, mulmod(x3, mulmod(get_eval_i_by_rotation_idx(8, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe, mulmod(x3, mulmod(get_eval_i_by_rotation_idx(8, 0, mload(x2)), mulmod(x3, x3, modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffff, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(8, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(8, 0, mload(x2)), mulmod(x3, x3, modulus), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(10, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(x4, x3, modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(x4, x4, modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(x4, get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(x3, mulmod(get_eval_i_by_rotation_idx(10, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(x3, x3, modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(x3, x4, modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(x3, get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(4, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(x4, mulmod(x3, get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(x4, get_eval_i_by_rotation_idx(1, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(x4, get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(x3, mulmod(get_eval_i_by_rotation_idx(4, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(x3, mulmod(x3, get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(x3, get_eval_i_by_rotation_idx(1, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(x3, get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(10, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), x3, modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), x4, modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(10, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), x3, modulus), modulus), modulus), modulus), modulus))

            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), x4, modulus), modulus), modulus), modulus), modulus))
            // Last working string
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(4, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), mulmod(x3, get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), get_eval_i_by_rotation_idx(1, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(4, 0, mload(x2)), get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), mulmod(x3, get_eval_i_by_rotation_idx(10, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), get_eval_i_by_rotation_idx(1, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, x4, modulus), modulus))
            mstore(x1, addmod(mload(x1), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(get_eval_i_by_rotation_idx(6, 0, mload(x2)), x4, modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(get_eval_i_by_rotation_idx(6, 0, mload(x2)), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, get_eval_i_by_rotation_idx(3, 0, mload(x2)), modulus), modulus))
            mstore(x1, addmod(mload(x1), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(get_eval_i_by_rotation_idx(6, 0, mload(x2)), get_eval_i_by_rotation_idx(3, 0, mload(x2)), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x3, mulmod(get_eval_i_by_rotation_idx(6, 0, mload(x2)), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, x3, modulus), modulus))
            mstore(x1, addmod(mload(x1), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x4, mulmod(get_eval_i_by_rotation_idx(7, 0, mload(x2)), x3, modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(7, 0, mload(x2)), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, get_eval_i_by_rotation_idx(1, 0, mload(x2)), modulus), modulus))
            mstore(x1, addmod(mload(x1), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x4, mulmod(get_eval_i_by_rotation_idx(7, 0, mload(x2)), get_eval_i_by_rotation_idx(1, 0, mload(x2)), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(7, 0, mload(x2)), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            mstore(x1, addmod(mload(x1), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(get_eval_i_by_rotation_idx(8, 0, mload(x2)), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(8, 0, mload(x2)), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(9, 0, mload(x2)), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(9, 0, mload(x2)), get_eval_i_by_rotation_idx(4, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(x1, 0)
            //1st
            mstore(x1, addmod(mload(x1), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus))
            mstore(x1, addmod(mload(x1), mulmod(x3, mulmod(get_eval_i_by_rotation_idx(8, 0, mload(x2)), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(x4, mulmod(get_eval_i_by_rotation_idx(8, 0, mload(x2)), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(get_eval_i_by_rotation_idx(1, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(9, 0, mload(x2)), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(x1, addmod(mload(x1), mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000, mulmod(get_eval_i_by_rotation_idx(3, 0, mload(x2)), mulmod(get_eval_i_by_rotation_idx(9, 0, mload(x2)), get_eval_i_by_rotation_idx(5, 0, mload(x2)), modulus), modulus), modulus), modulus))
            mstore(add(local_vars, GATE_EVAL_OFFSET), addmod(mload(add(local_vars, GATE_EVAL_OFFSET)), mulmod(mload(x1), theta_acc, modulus), modulus))
            theta_acc := mulmod(theta_acc, theta, modulus)
            mstore(add(local_vars, GATE_EVAL_OFFSET), mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)), get_selector_i(0, mload(add(local_vars, SELECTOR_EVALUATIONS_OFFSET))), modulus))

            gates_evaluation := mload(add(local_vars, GATE_EVAL_OFFSET))
        }
    }
}