from mock_beacon_state import get_random_state
import json
import sys
import random
import argparse

def slice_into_low_high(digest):
    low = str(int.from_bytes(digest[:16], 'big'))
    high = str(int.from_bytes(digest[16:], 'big'))

    return [low, high]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog='Dummy data generator for Consensus Layer Storage Proof',
        description='Provides a Merkle path for an account into a state root from Consensus Layer.')
    parser.add_argument('--output', help="Output file path", default="output.json")

    args = parser.parse_args()

    index = random.randint(1, 16)
    state, tree = get_random_state()
    merkle_path = tree.prove_inclusion(index)
    leaf = tree.get_leaf(index)
    root = state.state_root[0]
    print(f"Preparing Merkle path for index {index - 1} and state root {root.hex()}")
    input = [{"array" : [slice_into_low_high(node) for node in merkle_path.path]}, {"vector": slice_into_low_high(leaf)}, {"vector" : slice_into_low_high(root)}] 
    with open(args.output, 'w') as f:
        sys.stdout = f
        print(json.dumps(input, indent=4))

    public_input = [{"root" : root.hex()}, {"leaf" : leaf.hex()}]
    output_pi = "public_input_" + args.output
    with open(output_pi, 'w') as f:
        sys.stdout = f
        print(json.dumps(public_input, indent=4))
