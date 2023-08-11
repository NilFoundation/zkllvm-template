from pymerkle import InmemoryTree as MerkleTree
from consensus_layer_ssz import BeaconState
import random

def get_random_state():
    state_size = 16
    state_data = [random.randint(0, (1<<16)) for _ in range(state_size)]
    tree = MerkleTree()
    for x in state_data:
        tree.append_entry(bytes(x))
    root = tree.get_state()

    state: BeaconState = BeaconState()
    state.state_root = [root]
    return state, tree