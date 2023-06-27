#include <nil/crypto3/hash/algorithm/hash.hpp>
#include <nil/crypto3/hash/sha2.hpp>

using namespace nil::crypto3;

#ifdef __ZKLLVM__
typename hashes::sha2<256>::block_type hash_pair(
    hashes::sha2<256>::block_type left,
    hashes::sha2<256>::block_type right
) {
    return hash<hashes::sha2<256>>(left, right);
}
#else
template<typename HashType>
typename HashType::digest_type hash_pair(typename HashType::block_type block0, typename HashType::block_type block1) {
  accumulator_set<HashType> acc;
  acc(block0, accumulators::bits = HashType::block_bits);
  acc(block1, accumulators::bits = HashType::block_bits);

  return accumulators::extract::hash<HashType>(acc);
}
#endif