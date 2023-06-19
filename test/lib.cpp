#define BOOST_TEST_MODULE LibTest
#include <boost/test/unit_test.hpp>
#include <boost/test/data/test_case.hpp>
#include <boost/algorithm/string/join.hpp>

#include <nil/crypto3/hash/algorithm/hash.hpp>
#include <nil/crypto3/hash/sha2.hpp>

#include "lib.hpp"

std::string intToHex(unsigned int value) {
    std::stringstream sstream;
    sstream << std::hex << value;
    return sstream.str();
}

std::string hash256ToHex(hashes::sha2<256>::block_type hash) {
    std::array<std::string, 16> elems;
    std::transform(hash.begin(), hash.end(), elems.begin(), intToHex);
    return boost::algorithm::join(elems, "");
}

BOOST_AUTO_TEST_SUITE(lib_test)

BOOST_AUTO_TEST_CASE(test_balance) {
    std::string expected = "9a5ee745fda52931b4174b0ea83af76e48f32e03c9ad6fc563c580c2497302fd";
    typename hashes::sha2<256>::block_type root = hash_pair(
        hashes::sha2<256>::block_type {1},
        hashes::sha2<256>::block_type {2}
    );
    BOOST_TEST(hash256ToHex(root) == expected);
}
BOOST_AUTO_TEST_SUITE_END()
