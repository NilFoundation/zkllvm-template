from mock_beacon_state import get_random_state
import json
import sys
import random

def slice_into_low_high(digest):
    low = int.from_bytes(digest[:16], 'big')
    high = int.from_bytes(digest[16:], 'big')

    return [low, high]

if __name__ == "__main__":
    index = random.randint(1, 16)
    state, tree = get_random_state()
    merkle_path = tree.prove_inclusion(index)
    leaf = tree.get_leaf(index)
    root = state.state_root[0]
    print(f"Preparing Merkle path for index {index - 1} and state root {root.hex()}")
    input = [{"array" : [slice_into_low_high(node) for node in merkle_path.path]}, {"vector": slice_into_low_high(leaf)}, {"vector" : slice_into_low_high(root)}] 
    with open("path.inp", 'w') as f:
        sys.stdout = f
        print(json.dumps(input, indent=4))
