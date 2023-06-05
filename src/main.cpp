#include <nil/crypto3/hash/algorithm/hash.hpp>
#include <nil/crypto3/hash/sha2.hpp>
#include "lib.hpp";

using namespace nil::crypto3;

[[circuit]] typename hashes::sha2<256>::block_type
    balance_cirtuit(std::array<typename hashes::sha2<256>::block_type, 0x10> layer_0_leaves) {
    return balance(layer_0_leaves);
}