#include "lib.hpp"

using namespace nil::crypto3;

constexpr size_t INPUT_SIZE = 16;

[[circuit]] unsigned int circuit(
    uint64_t left,
    uint64_t right,
    hashes::sha2<256>::digest_type expected
) {
    circuitImpl(left, right, expected);
}
