### Excessive "RPCError err=NetworkError" in logs when a node is offline

**Symptom**: Continuous error logs `ERROR lyxal_raft::replication: RPCError err=NetworkError`
when a follower is unreachable

**Cause**: Lyxalraft retries replication aggressively. Each failed RPC logs an error.

**Solution**: In your [`RaftNetworkV2`][] implementation, when a node is known to be unreachable,
return [`Unreachable`][] error instead of [`NetworkError`][]. Lyxalraft backs off longer for
`Unreachable` errors, reducing log spam.

[`RaftNetworkV2`]: `crate::network::RaftNetworkV2`
[`Unreachable`]: `crate::error::Unreachable`
[`NetworkError`]: `crate::error::NetworkError`
