#define BOOST_TEST_MODULE LibTest
#include <boost/test/unit_test.hpp>
#include <boost/test/data/test_case.hpp>
#include <boost/algorithm/hex.hpp>

#include "lib.hpp"

#include "testutil.hpp"

using hash_type = hashes::sha2<256>;
using half_block = std::array<hash_type::block_type::value_type, hash_type::block_words / 2>;

BOOST_AUTO_TEST_SUITE(lib_test)

BOOST_AUTO_TEST_CASE(circuitImpl_zeroes) {
    hashes::sha2<256>::digest_type expected;
    
    boost::algorithm::unhex("f5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b", expected.begin());
    
    uint result = circuitImpl(0u, 0u, expected);
    BOOST_TEST(result == 1);
}

BOOST_AUTO_TEST_CASE(hash_single_values) {
    hashes::sha2<256>::digest_type expected;
    
    boost::algorithm::unhex("a50dbf1b92471fd9d5f142060e67c71976b6728ff03df56f3968e4be017ebbcd", expected.begin());
    
    uint result = circuitImpl(0xabcdef012345ul, 0xaabbccddeefful, expected);
    BOOST_TEST(result == 1);
}

BOOST_AUTO_TEST_SUITE_END()
