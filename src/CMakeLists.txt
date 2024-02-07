function(add_example example_target)
    set(prefix ARG)
    set(noValues "")
    set(singleValues)
    set(multiValues SOURCES)
    cmake_parse_arguments(${prefix}
                        "${noValues}"
                        "${singleValues}"
                        "${multiValues}"
                        ${ARGN})
    add_circuit(${example_target}
                SOURCES ${ARG_SOURCES}

                LINK_LIBRARIES
                crypto3::algebra
                crypto3::block
                crypto3::codec
                crypto3::containers
                crypto3::hash
                crypto3::kdf
                crypto3::mac
                marshalling::core
                marshalling::crypto3_algebra
                marshalling::crypto3_multiprecision
                marshalling::crypto3_zk
                crypto3::math
                crypto3::modes
                crypto3::multiprecision
                crypto3::passhash
                crypto3::pbkdf
                crypto3::threshold
                crypto3::pkpad
                crypto3::pubkey
                crypto3::random
                crypto3::stream
                crypto3::vdf
                crypto3::zk

                ${Boost_LIBRARIES})
endfunction()

add_example(template SOURCES main.cpp)

if(CI_RUN)
    add_example(arithmetics_cpp_example SOURCES "../zkLLVM/examples/cpp/arithmetics.cpp")
    add_example(ed25519_field_add SOURCES "../zkLLVM/examples/cpp/ed25519_field_add.cpp")
    add_example(ed25519_curve_add SOURCES "../zkLLVM/examples/cpp/ed25519_curve_add.cpp")
    add_example(sha2_256 SOURCES "../zkLLVM/examples/cpp/sha2_256.cpp")
    add_example(merkle_poseidon_1prover SOURCES "../zkLLVM/examples/cpp/merkle_poseidon_1prover.cpp")
    add_example(private_input_array SOURCES "../zkLLVM/examples/cpp/private_input_array.cpp")
    add_example(poseidon SOURCES "../zkLLVM/examples/cpp/poseidon.cpp")
    add_example(placeholder_verifier SOURCES "../zkLLVM/examples/cpp/placeholder_verifier.cpp")
    add_example(merkle_poseidon_21prover_3layers SOURCES "../zkLLVM/examples/cpp/merkle_poseidon_21prover_3layers.cpp")
    add_example(bit_operations_shift_right SOURCES "../zkLLVM/examples/cpp/bit_operations/shift_right.cpp")
    add_example(bit_operations_bit_decomposition SOURCES "../zkLLVM/examples/cpp/bit_operations/bit_decomposition.cpp")
    add_example(bit_operations_uint_division SOURCES "../zkLLVM/examples/cpp/bit_operations/uint_division.cpp")
    add_example(bit_operations_uint_remainder SOURCES "../zkLLVM/examples/cpp/bit_operations/uint_remainder.cpp")
    add_example(compare_lequal SOURCES "../zkLLVM/examples/cpp/compare/lequal.cpp")
    add_example(compare_neq SOURCES "../zkLLVM/examples/cpp/compare/neq.cpp")
    add_example(compare_eq SOURCES "../zkLLVM/examples/cpp/compare/eq.cpp")
    add_example(validate_merkle_path_sha2_256 SOURCES "../zkLLVM/examples/cpp/validate_merkle_path_sha2_256.cpp")
    add_example(eddsa_signature_verification SOURCES "../zkLLVM/examples/cpp/eddsa_signature_verification.cpp")
    add_example(balances_tree SOURCES "../zkLLVM/examples/cpp/balances_tree.cpp")
    add_example(sha2_512 SOURCES "../zkLLVM/examples/cpp/sha2_512.cpp")
    add_example(pallas_curve_examples_pallas_curve_add SOURCES "../zkLLVM/examples/cpp/pallas_curve_examples/pallas_curve_add.cpp")

endif()
