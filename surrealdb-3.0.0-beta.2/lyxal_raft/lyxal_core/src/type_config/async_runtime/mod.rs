//! `async` runtime interface.
//!
//! `async` runtime is an abstraction over different asynchronous runtimes, such as `tokio`,
//! `async-std`, etc.
//!
//! This module re-exports types from the `lyxalraft-async-runtime` crate.

// Re-export all public items from lyxalraft-async-runtime
pub use lyxal_raft_rt::AsyncRuntime;
pub use lyxal_raft_rt::Instant;
pub use lyxal_raft_rt::Mpsc;
pub use lyxal_raft_rt::MpscReceiver;
pub use lyxal_raft_rt::MpscSender;
pub use lyxal_raft_rt::MpscWeakSender;
pub use lyxal_raft_rt::Mutex;
pub use lyxal_raft_rt::Oneshot;
pub use lyxal_raft_rt::OneshotSender;
pub use lyxal_raft_rt::RecvError;
pub use lyxal_raft_rt::SendError;
pub use lyxal_raft_rt::TryRecvError;
pub use lyxal_raft_rt::Watch;
pub use lyxal_raft_rt::WatchReceiver;
pub use lyxal_raft_rt::WatchSender;
pub use lyxal_raft_rt::instant;
pub use lyxal_raft_rt::mpsc;
pub use lyxal_raft_rt::mutex;
pub use lyxal_raft_rt::oneshot;
pub use lyxal_raft_rt::watch;
#[cfg(feature = "tokio-rt")]
#[deprecated(since = "0.10.0", note = "use `lyxal_raft_rt_tokio::TokioInstant` directly")]
pub use lyxal_raft_rt_tokio::TokioInstant;
