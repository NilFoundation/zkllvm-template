from ssz.hashable_container import HashableContainer
from ssz.sedes import (
    Bitlist,
    Bitvector,
    ByteVector,
    List,
    Vector,
    boolean,
    byte,
    bytes4,
    bytes32,
    bytes48,
    uint8,
    uint64,
    uint256
)

import constants

Hash32 = bytes32
Root = bytes32
Gwei = uint64
Epoch = uint64
Slot = uint64
CommitteeIndex = uint64
ValidatorIndex = uint64
BLSPubkey = bytes48
ExecutionAddress = ByteVector(20)
WithdrawalIndex = uint64
ParticipationFlags = uint8
Version = bytes4

class Fork(HashableContainer):
    fields = [
        ("previous_version", Version),
        ("current_version", Version),
        ("epoch", Epoch)  # Epoch of latest fork
    ]


class Checkpoint(HashableContainer):
    fields = [
        ("epoch", Epoch),
        ("root", Root)
    ]


class BeaconBlockHeader(HashableContainer):
    fields = [
        ("slot", Slot),
        ("proposer_index", ValidatorIndex),
        ("parent_root", Root),
        ("state_root", Root),
        ("body_root", Root),
    ]


class Eth1Data(HashableContainer):
    fields = [
        ("deposit_root", Root),
        ("deposit_count", uint64),
        ("block_hash", Hash32),
    ]


class Validator(HashableContainer):
    fields = [
        ("pubkey", BLSPubkey),
        ("withdrawal_credentials", bytes32),  # Commitment to pubkey for withdrawals
        ("effective_balance", Gwei),  # Balance at stake
        ("slashed", boolean),
        # Status epochs
        ("activation_eligibility_epoch", Epoch),  # When criteria for activation were met
        ("activation_epoch", Epoch),
        ("exit_epoch", Epoch),
        ("withdrawable_epoch", Epoch),  # When validator can withdraw funds
    ]


class AttestationData(HashableContainer):
    fields = [
        ("slot", Slot),
        ("index", CommitteeIndex),
        ("beacon_block_root", Root),
        ("source", Checkpoint),
        ("target", Checkpoint),
    ]


class PendingAttestation(HashableContainer):
    fields = [
        ("aggregation_bits", Bitlist(constants.MAX_VALIDATORS_PER_COMMITTEE)),
        ("data", AttestationData),
        ("inclusion_delay", Slot),
        ("proposer_index", ValidatorIndex),
    ]


class SyncCommittee(HashableContainer):
    fields = [
        ("pubkeys", Vector(BLSPubkey, constants.SYNC_COMMITTEE_SIZE)),
        ("aggregate_pubkey", BLSPubkey),
    ]

class ExecutionPayloadHeader(HashableContainer):
    # Execution block header fields
    fields = [
        ("parent_hash", Hash32),
        ("fee_recipient", ExecutionAddress),
        ("state_root", bytes32),
        ("receipts_root", bytes32),
        ("logs_bloom", ByteVector(constants.BYTES_PER_LOGS_BLOOM)),
        ("prev_randao", bytes32),
        ("block_number", uint64),
        ("gas_limit", uint64),
        ("gas_used", uint64),
        ("timestamp", uint64),
        # ("extra_data", ByteList(constants.MAX_EXTRA_DATA_BYTES)),
        # workaround - looks like ByteList is partially broken, but extra data is exactly bytes32
        ("extra_data", List(byte, constants.MAX_EXTRA_DATA_BYTES)),
        ("base_fee_per_gas", uint256),
        ("block_hash", Hash32),
        ("transactions_root", Root),
        ("withdrawals_root", Root),
        # ("excess_data_gas: uint256", uint256),
    ]

class HistoricalSummary(HashableContainer):
    """
    `HistoricalSummary` matches the components of the phase0 `HistoricalBatch`
    making the two hash_tree_root-compatible.
    """
    fields = [
        ("block_summary_root", Root),
        ("state_summary_root", Root),
    ]


Balances = List(Gwei, constants.VALIDATOR_REGISTRY_LIMIT)


class BeaconState:
    fields = [
        # Versioning
        ("genesis_time", uint64),
        ("genesis_validators_root", Root),
        ("slot", Slot),
        ("fork", Fork),
        # History
        ("latest_block_header", BeaconBlockHeader),
        ("block_roots", Vector(Root, constants.SLOTS_PER_HISTORICAL_ROOT)),
        ("state_roots", Vector(Root, constants.SLOTS_PER_HISTORICAL_ROOT)),
        ("historical_roots", List(Root, constants.HISTORICAL_ROOTS_LIMIT)),  # Frozen in Capella, replaced by historical_summaries
        # Eth1
        ("eth1_data", Eth1Data),
        ("eth1_data_votes", List(Eth1Data, constants.EPOCHS_PER_ETH1_VOTING_PERIOD * constants.SLOTS_PER_EPOCH)),
        ("eth1_deposit_index", uint64),
        # Registry
        ("validators", List(Validator, constants.VALIDATOR_REGISTRY_LIMIT)),
        ("balances", Balances),
        # Randomness
        ("randao_mixes", Vector(bytes32, constants.EPOCHS_PER_HISTORICAL_VECTOR)),
        # Slashings
        ("slashings", Vector(Gwei, constants.EPOCHS_PER_SLASHINGS_VECTOR)),   # Per-epoch sums of slashed effective balances
        # Participation
        ("previous_epoch_participation", List(ParticipationFlags, constants.VALIDATOR_REGISTRY_LIMIT)),
        ("current_epoch_participation", List(ParticipationFlags, constants.VALIDATOR_REGISTRY_LIMIT)),
        # Finality
        ("justification_bits", Bitvector(constants.JUSTIFICATION_BITS_LENGTH)), # Bit set for every recent justified epoch
        ("previous_justified_checkpoint", Checkpoint),
        ("current_justified_checkpoint", Checkpoint),
        ("finalized_checkpoint", Checkpoint),
        # Inactivity
        ("inactivity_scores", List(uint64, constants.VALIDATOR_REGISTRY_LIMIT)),
        # Sync
        ("current_sync_committee", SyncCommittee),
        ("next_sync_committee", SyncCommittee),
        # Execution
        ("latest_execution_payload_header", ExecutionPayloadHeader), # (Modified in Capella)
        # Withdrawals
        ("next_withdrawal_index", WithdrawalIndex),   # (New in Capella)
        ("next_withdrawal_validator_index", ValidatorIndex),   # (New in Capella)
        # Deep history valid from Capella onwards
        ("historical_summaries", List(HistoricalSummary, constants.HISTORICAL_ROOTS_LIMIT)),   # (New in Capella)
    ]