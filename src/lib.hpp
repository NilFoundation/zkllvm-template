#pragma once
#include "hash.hpp"
#include "utils.hpp"

using namespace nil::crypto3;

using hash_type = hashes::sha2<256>;
constexpr size_t half_block_length = hash_type::block_words / 2;
using half_block = std::array<hash_type::block_type::value_type, half_block_length>;

unsigned int circuitImpl(
    uint64_t left,
    uint64_t right,
    hashes::sha2<256>::digest_type expected
) {
    hash_type::block_type block = padAndJoinToBlock<hash_type, 2, 2>(
        uint64ToLittleEndianWords<hash_type>(left), 
        uint64ToLittleEndianWords<hash_type>(right)
    );

    hash_type::digest_type actual = hash_one<hash_type>(block);
    if (actual == expected) {
        return 1;
    } else {
        return 0;
    }
}
