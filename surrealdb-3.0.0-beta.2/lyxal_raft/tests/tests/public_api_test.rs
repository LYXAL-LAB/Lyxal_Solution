//! Compile-time test to verify all public API paths remain accessible from external crates.
//!
//! This test ensures that refactoring or restructuring of modules
//! does not break any existing public API paths.

#![allow(unused_imports)]
#![allow(dead_code)]

// =============================================================================
// Root-level exports from lyxalraft
// =============================================================================

use lyxal_raft::AnyError;
use lyxal_raft::AppData;
use lyxal_raft::AppDataResponse;
use lyxal_raft::AsyncRuntime;
use lyxal_raft::BasicNode;
use lyxal_raft::ChangeMembers;
use lyxal_raft::Config;
use lyxal_raft::ConfigError;
use lyxal_raft::EffectiveMembership;
use lyxal_raft::EmptyNode;
use lyxal_raft::Entry;
use lyxal_raft::EntryPayload;
use lyxal_raft::ErrorSubject;
use lyxal_raft::ErrorVerb;
use lyxal_raft::Instant;
use lyxal_raft::LogId;
use lyxal_raft::LogIdOptionExt;
use lyxal_raft::LogIndexOptionExt;
use lyxal_raft::LogState;
use lyxal_raft::Membership;
use lyxal_raft::MembershipState;
use lyxal_raft::MessageSummary;
use lyxal_raft::Node;
use lyxal_raft::NodeId;
use lyxal_raft::OptionalSend;
use lyxal_raft::OptionalSerde;
use lyxal_raft::OptionalSync;
use lyxal_raft::RPCTypes;
use lyxal_raft::Raft;
use lyxal_raft::RaftLogReader;
use lyxal_raft::RaftMetrics;
use lyxal_raft::RaftNetworkFactory;
use lyxal_raft::RaftSnapshotBuilder;
use lyxal_raft::RaftState;
use lyxal_raft::RaftTypeConfig;
use lyxal_raft::ReadPolicy;
use lyxal_raft::Snapshot;
use lyxal_raft::SnapshotId;
use lyxal_raft::SnapshotMeta;
use lyxal_raft::SnapshotPolicy;
use lyxal_raft::SnapshotSegmentId;
use lyxal_raft::StorageError;
use lyxal_raft::StorageHelper;
use lyxal_raft::StoredMembership;
use lyxal_raft::ToStorageResult;
use lyxal_raft::TryAsRef;
use lyxal_raft::Vote;
use lyxal_raft::WatchChangeHandle;
use lyxal_raft::WatchSender;
use lyxal_raft::add_async_trait;
use lyxal_raft::anyerror;
// =============================================================================
// async_runtime module exports
// =============================================================================
use lyxal_raft::async_runtime;
use lyxal_raft::async_runtime::AsyncRuntime as AsyncRuntime2;
use lyxal_raft::async_runtime::Instant as Instant2;
use lyxal_raft::async_runtime::Mpsc;
use lyxal_raft::async_runtime::MpscReceiver;
use lyxal_raft::async_runtime::MpscSender;
use lyxal_raft::async_runtime::MpscWeakSender;
use lyxal_raft::async_runtime::Mutex;
use lyxal_raft::async_runtime::Oneshot;
use lyxal_raft::async_runtime::OneshotSender;
use lyxal_raft::async_runtime::RecvError;
use lyxal_raft::async_runtime::SendError;
use lyxal_raft::async_runtime::TokioInstant;
use lyxal_raft::async_runtime::TryRecvError;
use lyxal_raft::async_runtime::Watch;
use lyxal_raft::async_runtime::WatchReceiver;
use lyxal_raft::async_runtime::WatchSender as WatchSender2;
use lyxal_raft::async_runtime::instant;
use lyxal_raft::async_runtime::instant::Instant as InstantTrait;
use lyxal_raft::async_runtime::mpsc;
use lyxal_raft::async_runtime::mpsc::Mpsc as MpscTrait;
use lyxal_raft::async_runtime::mpsc::MpscReceiver as MpscReceiverTrait;
use lyxal_raft::async_runtime::mpsc::MpscSender as MpscSenderTrait;
use lyxal_raft::async_runtime::mpsc::MpscWeakSender as MpscWeakSenderTrait;
use lyxal_raft::async_runtime::mpsc::SendError as MpscSendError;
use lyxal_raft::async_runtime::mpsc::TryRecvError as MpscTryRecvError;
use lyxal_raft::async_runtime::mutex;
use lyxal_raft::async_runtime::mutex::Mutex as MutexTrait;
use lyxal_raft::async_runtime::oneshot;
use lyxal_raft::async_runtime::oneshot::Oneshot as OneshotTrait;
use lyxal_raft::async_runtime::oneshot::OneshotSender as OneshotSenderTrait;
use lyxal_raft::async_runtime::watch;
use lyxal_raft::async_runtime::watch::RecvError as WatchRecvError;
use lyxal_raft::async_runtime::watch::SendError as WatchSendError;
use lyxal_raft::async_runtime::watch::Watch as WatchTrait;
use lyxal_raft::async_runtime::watch::WatchReceiver as WatchReceiverTrait;
use lyxal_raft::async_runtime::watch::WatchSender as WatchSenderTrait;
// =============================================================================
// base module exports
// =============================================================================
use lyxal_raft::base::OptionalFeatures;
use lyxal_raft::base::OptionalSend as BaseOptionalSend;
use lyxal_raft::base::OptionalSerde as BaseOptionalSerde;
use lyxal_raft::base::OptionalSync as BaseOptionalSync;
// Note: config module is private; items are re-exported at root level

// =============================================================================
// entry module exports
// =============================================================================
use lyxal_raft::entry::Entry as EntryModule;
use lyxal_raft::entry::EntryPayload as EntryPayloadModule;
use lyxal_raft::entry::RaftEntry;
use lyxal_raft::entry::RaftPayload;
// =============================================================================
// error module exports
// =============================================================================
use lyxal_raft::error::AllowNextRevertError;
use lyxal_raft::error::ChangeMembershipError;
use lyxal_raft::error::ClientWriteError;
use lyxal_raft::error::EmptyMembership;
use lyxal_raft::error::Fatal;
use lyxal_raft::error::ForwardToLeader;
use lyxal_raft::error::InProgress;
use lyxal_raft::error::Infallible;
use lyxal_raft::error::InitializeError;
use lyxal_raft::error::InstallSnapshotError;
use lyxal_raft::error::InvalidStateMachineType;
use lyxal_raft::error::LeaderChanged;
use lyxal_raft::error::LearnerNotFound;
use lyxal_raft::error::LinearizableReadError;
use lyxal_raft::error::MembershipError;
use lyxal_raft::error::NetworkError;
use lyxal_raft::error::NoForward;
use lyxal_raft::error::NodeNotFound;
use lyxal_raft::error::NotAllowed;
use lyxal_raft::error::NotInMembers;
use lyxal_raft::error::Operation;
use lyxal_raft::error::QuorumNotEnough;
use lyxal_raft::error::RPCError;
use lyxal_raft::error::RaftError;
use lyxal_raft::error::RemoteError;
use lyxal_raft::error::ReplicationClosed;
use lyxal_raft::error::SnapshotMismatch;
use lyxal_raft::error::StreamingError;
use lyxal_raft::error::Timeout;
use lyxal_raft::error::Unreachable;
use lyxal_raft::error::decompose;
// =============================================================================
// impls module exports
// =============================================================================
use lyxal_raft::impls::BasicNode as ImplsBasicNode;
use lyxal_raft::impls::EmptyNode as ImplsEmptyNode;
use lyxal_raft::impls::Entry as ImplsEntry;
use lyxal_raft::impls::LogId as ImplsLogId;
use lyxal_raft::impls::OneshotResponder;
use lyxal_raft::impls::ProgressResponder;
use lyxal_raft::impls::TokioRuntime;
use lyxal_raft::impls::Vote as ImplsVote;
use lyxal_raft::impls::leader_id_adv;
use lyxal_raft::impls::leader_id_adv::LeaderId as LeaderIdAdv;
use lyxal_raft::impls::leader_id_std;
use lyxal_raft::impls::leader_id_std::LeaderId as LeaderIdStd;
// =============================================================================
// log_id module exports
// =============================================================================
use lyxal_raft::log_id::LogId as LogIdModule;
use lyxal_raft::log_id::LogIdOptionExt as LogIdOptionExtModule;
use lyxal_raft::log_id::LogIndexOptionExt as LogIndexOptionExtModule;
// =============================================================================
// membership module exports
// =============================================================================
use lyxal_raft::membership::EffectiveMembership as EffectiveMembershipModule;
use lyxal_raft::membership::Membership as MembershipModule;
use lyxal_raft::membership::StoredMembership as StoredMembershipModule;
// =============================================================================
// metrics module exports
// =============================================================================
use lyxal_raft::metrics::RaftMetrics as RaftMetricsModule;
use lyxal_raft::metrics::Wait;
use lyxal_raft::metrics::WaitError;
// =============================================================================
// network module exports
// =============================================================================
use lyxal_raft::network::Backoff;
use lyxal_raft::network::RPCOption;
use lyxal_raft::network::RPCTypes as RPCTypesModule;
use lyxal_raft::network::RaftNetworkFactory as RaftNetworkFactoryModule;
use lyxal_raft::network::v2;
use lyxal_raft::network::v2::RaftNetworkV2;
// =============================================================================
// raft module exports
// =============================================================================
use lyxal_raft::raft::AppendEntriesRequest;
use lyxal_raft::raft::AppendEntriesResponse;
use lyxal_raft::raft::ClientWriteResponse;
use lyxal_raft::raft::ClientWriteResult;
use lyxal_raft::raft::FlushPoint;
use lyxal_raft::raft::InstallSnapshotRequest;
use lyxal_raft::raft::InstallSnapshotResponse;
use lyxal_raft::raft::Leader;
use lyxal_raft::raft::Raft as RaftModule;
use lyxal_raft::raft::ReadPolicy as ReadPolicyModule;
use lyxal_raft::raft::RuntimeConfigHandle;
use lyxal_raft::raft::SnapshotResponse;
use lyxal_raft::raft::StreamAppendError;
use lyxal_raft::raft::StreamAppendResult;
use lyxal_raft::raft::TransferLeaderRequest;
use lyxal_raft::raft::VoteRequest;
use lyxal_raft::raft::VoteResponse;
use lyxal_raft::raft::WatchChangeHandle as WatchChangeHandleModule;
use lyxal_raft::raft::WriteRequest;
use lyxal_raft::raft::WriteResponse;
use lyxal_raft::raft::WriteResult;
use lyxal_raft::raft::linearizable_read;
use lyxal_raft::raft::linearizable_read::Linearizer;
use lyxal_raft::raft::responder;
use lyxal_raft::raft::responder::Responder;
use lyxal_raft::raft::trigger;
use lyxal_raft::raft::trigger::Trigger;
// =============================================================================
// storage module exports
// =============================================================================
use lyxal_raft::storage::ApplyResponder;
use lyxal_raft::storage::EntryResponder;
use lyxal_raft::storage::IOFlushed;
use lyxal_raft::storage::LeaderBoundedStreamError;
use lyxal_raft::storage::LeaderBoundedStreamResult;
use lyxal_raft::storage::LogApplied;
use lyxal_raft::storage::LogState as LogStateModule;
use lyxal_raft::storage::RaftLogReader as RaftLogReaderModule;
use lyxal_raft::storage::RaftLogReaderExt;
use lyxal_raft::storage::RaftLogStorage;
use lyxal_raft::storage::RaftLogStorageExt;
use lyxal_raft::storage::RaftSnapshotBuilder as RaftSnapshotBuilderModule;
use lyxal_raft::storage::RaftStateMachine;
use lyxal_raft::storage::Snapshot as SnapshotModule;
use lyxal_raft::storage::SnapshotMeta as SnapshotMetaModule;
use lyxal_raft::storage::SnapshotSignature;
use lyxal_raft::storage::StorageHelper as StorageHelperModule;
// =============================================================================
// testing module exports
// =============================================================================
use lyxal_raft::testing;
use lyxal_raft::testing::log::StoreBuilder as LogStoreBuilder;
use lyxal_raft::testing::log::Suite as LogSuite;
// =============================================================================
// type_config module exports
// =============================================================================
use lyxal_raft::type_config::AsyncRuntime as TypeConfigAsyncRuntime;
use lyxal_raft::type_config::OneshotSender as TypeConfigOneshotSender;
use lyxal_raft::type_config::RaftTypeConfig as TypeConfigRaftTypeConfig;
use lyxal_raft::type_config::async_runtime as type_config_async_runtime;
// =============================================================================
// vote module exports
// =============================================================================
use lyxal_raft::vote::RaftLeaderId;
use lyxal_raft::vote::RaftTerm;
use lyxal_raft::vote::Vote as VoteModule;

// =============================================================================
// Macros
// =============================================================================

// Test that declare_raft_types macro is accessible
// lyxal_raft::declare_raft_types! is tested implicitly by usage in examples

#[test]
fn test_public_api_accessible() {
    // This test just needs to compile to verify all paths are publicly accessible
}
