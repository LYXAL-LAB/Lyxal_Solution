//! RPC request type enum for all Raft RPC calls.

use std::fmt;

use lyxal_raft::RPCTypes;
use lyxal_raft::RaftTypeConfig;
use lyxal_raft::Snapshot;
use lyxal_raft::raft::AppendEntriesRequest;
use lyxal_raft::raft::InstallSnapshotRequest;
use lyxal_raft::raft::TransferLeaderRequest;
use lyxal_raft::raft::VoteRequest;

/// Unified enum for all RPC request types in the test framework.
#[derive(Debug)]
#[derive(derive_more::From, derive_more::TryInto)]
pub enum RpcRequest<C: RaftTypeConfig>
where C::SnapshotData: fmt::Debug
{
    AppendEntries(AppendEntriesRequest<C>),
    InstallSnapshot(InstallSnapshotRequest<C>),
    InstallFullSnapshot(Snapshot<C>),
    Vote(VoteRequest<C>),
    TransferLeader(TransferLeaderRequest<C>),
}

impl<C: RaftTypeConfig> RpcRequest<C>
where C::SnapshotData: fmt::Debug
{
    pub fn get_type(&self) -> RPCTypes {
        match self {
            RpcRequest::AppendEntries(_) => RPCTypes::AppendEntries,
            RpcRequest::InstallSnapshot(_) => RPCTypes::InstallSnapshot,
            RpcRequest::InstallFullSnapshot(_) => RPCTypes::InstallSnapshot,
            RpcRequest::Vote(_) => RPCTypes::Vote,
            RpcRequest::TransferLeader(_) => RPCTypes::TransferLeader,
        }
    }
}

impl<C> fmt::Display for RpcRequest<C>
where
    C: RaftTypeConfig,
    C::SnapshotData: fmt::Debug,
{
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            RpcRequest::AppendEntries(req) => write!(f, "AppendEntries({})", req),
            RpcRequest::InstallSnapshot(req) => write!(f, "InstallSnapshot({})", req),
            RpcRequest::InstallFullSnapshot(req) => write!(f, "InstallFullSnapshot({})", req.meta),
            RpcRequest::Vote(req) => write!(f, "Vote({})", req),
            RpcRequest::TransferLeader(req) => write!(f, "TransferLeader({})", req),
        }
    }
}
