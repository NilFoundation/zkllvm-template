#define BOOST_TEST_MODULE Test1
#include <boost/test/unit_test.hpp>
#include <boost/test/data/test_case.hpp>

#include "../src/lib.hpp"
#include <nil/crypto3/hash/algorithm/hash.hpp>
#include <nil/crypto3/hash/sha2.hpp>
#include <boost/algorithm/string/join.hpp>

using namespace nil::crypto3;

std::string int_to_hex(unsigned int value)
{
    std::stringstream sstream;
    sstream << std::hex << value;
    std::string result = sstream.str();
    return result;
}


std::string hash256ToHex(hashes::sha2<256>::block_type hash) {
    std::array<std::string, 16> elems;
    std::transform(hash.begin(), hash.end(), elems.begin(), int_to_hex);
    return boost::algorithm::join(elems, "");
}

BOOST_AUTO_TEST_SUITE( test_lib )

BOOST_AUTO_TEST_CASE(test_sum) {
    BOOST_TEST(sum(1, 2) == 3);
    BOOST_TEST(sum(5, 6) == 11);
}

BOOST_AUTO_TEST_CASE(test_balance) {
    std::string expected = "7486af269422f5548b00e57a9b18d2e290b06a514d677a4fd52b08fb0e93021f";
    std::array<typename hashes::sha2<256>::block_type, 0x10> layer_0_leaves = {
        hashes::sha2<256>::block_type {1},
        hashes::sha2<256>::block_type {2},
        hashes::sha2<256>::block_type {3},
        hashes::sha2<256>::block_type {4},
        hashes::sha2<256>::block_type {5},
        hashes::sha2<256>::block_type {6},
        hashes::sha2<256>::block_type {7},
        hashes::sha2<256>::block_type {8},
        hashes::sha2<256>::block_type {9},
        hashes::sha2<256>::block_type {10},
        hashes::sha2<256>::block_type {11},
        hashes::sha2<256>::block_type {12},
        hashes::sha2<256>::block_type {13},
        hashes::sha2<256>::block_type {14},
        hashes::sha2<256>::block_type {15},
        hashes::sha2<256>::block_type {16}
    };
    typename hashes::sha2<256>::block_type root = balance(layer_0_leaves);
    BOOST_TEST(hash256ToHex(root) == expected);
}
BOOST_AUTO_TEST_SUITE_END()