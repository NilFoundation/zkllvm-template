#include <iostream>
#include <string>
#include <cassert>
#include <unordered_map>

#include <boost/test/unit_test.hpp>
#include <boost/test/data/test_case.hpp>
#include <boost/test/data/monomorphic.hpp>

#include <nil/crypto3/pubkey/bls.hpp>
#include <nil/crypto3/pubkey/modes/threshold_bls.hpp>

#include <nil/crypto3/pubkey/secret_sharing/pedersen.hpp>

#include <nil/crypto3/pubkey/modes/threshold.hpp>

#include <nil/crypto3/pubkey/algorithm/sign.hpp>
#include <nil/crypto3/pubkey/modes/algorithm/sign.hpp>
#include <nil/crypto3/pubkey/algorithm/verify.hpp>
#include <nil/crypto3/pubkey/modes/algorithm/part_verify.hpp>
#include <nil/crypto3/pubkey/algorithm/aggregate.hpp>
#include <nil/crypto3/pubkey/algorithm/deal_shares.hpp>

#include <nil/crypto3/pubkey/modes/algorithm/create_key.hpp>
#include <nil/crypto3/pubkey/modes/algorithm/part_verify.hpp>


using namespace nil::crypto3::algebra;
using namespace nil::crypto3::hashes;
using namespace nil::crypto3::pubkey;


using curve_type = nil::crypto3::algebra::curves::bls12_381;
using base_scheme_type = bls<bls_default_public_params<>>;

using mode_type = modes::threshold<base_scheme_type, weighted_shamir_sss>;
using scheme_type = typename mode_type::scheme_type;
using privkey_type = private_key<scheme_type>;
using pubkey_type = public_key<scheme_type>;


using sss_public_key_group_type = typename pubkey_type::sss_public_key_group_type;
using shares_dealing_processing_mode = typename nil::crypto3::pubkey::modes::isomorphic<sss_public_key_group_type>::template bind<
        nil::crypto3::pubkey::shares_dealing_policy<sss_public_key_group_type>>::type;
using signing_processing_mode_type = typename mode_type::template bind<typename mode_type::signing_policy>::type;
using verification_processing_mode_type =
        typename mode_type::template bind<typename mode_type::verification_policy>::type;
using aggregation_processing_mode_type =
        typename mode_type::template bind<typename mode_type::aggregation_policy>::type;



int main() {

    const std::string msg_str = "hello foo";
    const std::vector<std::uint8_t> msg(std::cbegin(msg_str), std::cend(msg_str));

    std::size_t n = 20;
    std::size_t t = 10;

    auto i = 1;
    auto j = 1;
    typename privkey_type::weights_type weights;
    std::generate_n(std::inserter(weights, weights.end()), n, [&i, &j, &t]() {
        j = j >= t ? 1 : j;
        return std::make_pair(i++, j++);
    });


    auto coeffs = sss_public_key_group_type::get_poly(t, n);
    auto [PK, privkeys] = nil::crypto3::create_key<scheme_type>(coeffs, n, weights);

    //===========================================================================
    // participants sign messages and verify its signatures

    std::vector<typename privkey_type::part_signature_type> part_signatures;
    for (auto &sk : privkeys) {
        part_signatures.emplace_back(
                nil::crypto3::sign<scheme_type, decltype(msg), signing_processing_mode_type>(msg, weights, sk));

        BOOST_CHECK(static_cast<bool>(
                            nil::crypto3::part_verify<mode_type>(msg.begin(), msg.end(), part_signatures.back(), weights, sk)));
    }

    //===========================================================================
    // confirmed group of participants aggregate partial signatures

    // TODO: add simplified call interface for aggregate and verify
    typename pubkey_type::signature_type sig =
            nil::crypto3::aggregate<scheme_type, decltype(std::cbegin(part_signatures)), aggregation_processing_mode_type>(
                    std::cbegin(part_signatures), std::cend(part_signatures));
    BOOST_CHECK(static_cast<bool>(
                        nil::crypto3::verify<scheme_type, decltype(msg), verification_processing_mode_type>(msg, sig, PK)));



    //===========================================================================
    // threshold number of participants sign messages and verify its signatures

    std::vector<typename privkey_type::part_signature_type> part_signatures_t;
    typename privkey_type::weights_type confirmed_weights;
    std::vector<privkey_type> confirmed_keys;
    auto weighted_keys_it = std::cbegin(privkeys);
    auto weight = 0;
    while (weight < t) {
        confirmed_keys.emplace_back(*weighted_keys_it);
        confirmed_weights.emplace(weighted_keys_it->get_index(), weights.at(weighted_keys_it->get_index()));
        weight += weighted_keys_it->get_weight();
        ++weighted_keys_it;
    }

    for (auto &sk : confirmed_keys) {
        part_signatures_t.emplace_back(
                nil::crypto3::sign<scheme_type, decltype(msg), signing_processing_mode_type>(msg, confirmed_weights, sk));
        BOOST_CHECK(static_cast<bool>(nil::crypto3::part_verify<mode_type>(
                msg.begin(), msg.end(), part_signatures_t.back(), confirmed_weights, sk)));
    }

    //===========================================================================
    // threshold number of participants aggregate partial signatures

    // TODO: add simplified call interface for aggregate and verify
    typename pubkey_type::signature_type sig_t =
            nil::crypto3::aggregate<scheme_type, decltype(std::cbegin(part_signatures_t)),
                    aggregation_processing_mode_type>(std::cbegin(part_signatures_t),
                                                      std::cend(part_signatures_t));
    BOOST_CHECK(static_cast<bool>(
                        nil::crypto3::verify<scheme_type, decltype(msg), verification_processing_mode_type>(msg, sig_t, PK)));


    std::cout<<"Successfully verified Weighted BLS signatures\n";
    return 0;
}