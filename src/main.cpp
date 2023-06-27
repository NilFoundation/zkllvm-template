#include "lib.hpp"

using namespace nil::crypto3;

[[circuit]] typename hashes::sha2<256>::block_type circuit(
    hashes::sha2<256>::block_type left,
    hashes::sha2<256>::block_type right
) {
    return hash_pair<hashes::sha2<256>>(left, right);
}
