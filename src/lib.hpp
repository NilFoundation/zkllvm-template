#include <nil/crypto3/hash/algorithm/hash.hpp>
#include <nil/crypto3/hash/sha2.hpp>

using namespace nil::crypto3;

typename hashes::sha2<256>::block_type hash_pair(
    hashes::sha2<256>::block_type left,
    hashes::sha2<256>::block_type right
) {
    return hash<hashes::sha2<256>>(left, right);
}