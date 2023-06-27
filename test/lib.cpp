#define BOOST_TEST_MODULE LibTest
#include <boost/test/unit_test.hpp>
#include <boost/test/data/test_case.hpp>
#include <boost/algorithm/string/join.hpp>

#include <nil/crypto3/hash/algorithm/hash.hpp>
#include <nil/crypto3/hash/sha2.hpp>

#include "lib.hpp"


BOOST_AUTO_TEST_SUITE(lib_test)

BOOST_AUTO_TEST_CASE(test_balance) {
    std::string expected = "ff55c97976a840b4ced964ed49e3794594ba3f675238b5fd25d282b60f70a194";

    auto left = hashes::sha2<256>::block_type {1};
    auto right = hashes::sha2<256>::block_type {2};
    
    typename hashes::sha2<256>::digest_type root = hash_pair<hashes::sha2<256>>(
        left, right
    );
    auto actual = std::to_string(root);
    BOOST_TEST(actual == expected);
}

BOOST_AUTO_TEST_SUITE_END()
