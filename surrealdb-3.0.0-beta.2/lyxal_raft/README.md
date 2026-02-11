<div align="center">
    <h1>LyxalRaft</h1>
    <h4>
        Advanced <a href="https://raft.github.io/">Raft</a> in 🦀 Rust using <a href="https://tokio.rs/">Tokio</a>. Please ⭐ on <a href="https://github.com/databendlabs/lyxalraft">GitHub</a>!
    </h4>


[![Crates.io](https://img.shields.io/crates/v/lyxalraft.svg)](https://crates.io/crates/lyxalraft)
[![docs.rs](https://docs.rs/lyxalraft/badge.svg)](https://docs.rs/lyxalraft)
[![DeepWiki](https://img.shields.io/badge/DeepWiki-lyxalraft-blue.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACwAAAAyCAYAAAAnWDnqAAAAAXNSR0IArs4c6QAAA05JREFUaEPtmUtyEzEQhtWTQyQLHNak2AB7ZnyXZMEjXMGeK/AIi+QuHrMnbChYY7MIh8g01fJoopFb0uhhEqqcbWTp06/uv1saEDv4O3n3dV60RfP947Mm9/SQc0ICFQgzfc4CYZoTPAswgSJCCUJUnAAoRHOAUOcATwbmVLWdGoH//PB8mnKqScAhsD0kYP3j/Yt5LPQe2KvcXmGvRHcDnpxfL2zOYJ1mFwrryWTz0advv1Ut4CJgf5uhDuDj5eUcAUoahrdY/56ebRWeraTjMt/00Sh3UDtjgHtQNHwcRGOC98BJEAEymycmYcWwOprTgcB6VZ5JK5TAJ+fXGLBm3FDAmn6oPPjR4rKCAoJCal2eAiQp2x0vxTPB3ALO2CRkwmDy5WohzBDwSEFKRwPbknEggCPB/imwrycgxX2NzoMCHhPkDwqYMr9tRcP5qNrMZHkVnOjRMWwLCcr8ohBVb1OMjxLwGCvjTikrsBOiA6fNyCrm8V1rP93iVPpwaE+gO0SsWmPiXB+jikdf6SizrT5qKasx5j8ABbHpFTx+vFXp9EnYQmLx02h1QTTrl6eDqxLnGjporxl3NL3agEvXdT0WmEost648sQOYAeJS9Q7bfUVoMGnjo4AZdUMQku50McDcMWcBPvr0SzbTAFDfvJqwLzgxwATnCgnp4wDl6Aa+Ax283gghmj+vj7feE2KBBRMW3FzOpLOADl0Isb5587h/U4gGvkt5v60Z1VLG8BhYjbzRwyQZemwAd6cCR5/XFWLYZRIMpX39AR0tjaGGiGzLVyhse5C9RKC6ai42ppWPKiBagOvaYk8lO7DajerabOZP46Lby5wKjw1HCRx7p9sVMOWGzb/vA1hwiWc6jm3MvQDTogQkiqIhJV0nBQBTU+3okKCFDy9WwferkHjtxib7t3xIUQtHxnIwtx4mpg26/HfwVNVDb4oI9RHmx5WGelRVlrtiw43zboCLaxv46AZeB3IlTkwouebTr1y2NjSpHz68WNFjHvupy3q8TFn3Hos2IAk4Ju5dCo8B3wP7VPr/FGaKiG+T+v+TQqIrOqMTL1VdWV1DdmcbO8KXBz6esmYWYKPwDL5b5FA1a0hwapHiom0r/cKaoqr+27/XcrS5UwSMbQAAAABJRU5ErkJggg==)](https://deepwiki.com/databendlabs/lyxalraft)
[![guides](https://img.shields.io/badge/guide-%E2%86%97-brightgreen)](https://docs.rs/lyxalraft/latest/lyxalraft/docs/index.html)
[![Discord Chat](https://img.shields.io/discord/1015845055434588200?logo=discord)](https://discord.gg/ZKw3WG7FQ9)
<br/>
[![CI](https://github.com/databendlabs/lyxalraft/actions/workflows/ci.yaml/badge.svg)](https://github.com/databendlabs/lyxalraft/actions/workflows/ci.yaml)
[![Coverage Status](https://coveralls.io/repos/github/databendlabs/lyxalraft/badge.svg?branch=main)](https://coveralls.io/github/databendlabs/lyxalraft?branch=main)
![License](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)
![Crates.io](https://img.shields.io/crates/d/lyxalraft.svg)
![Crates.io](https://img.shields.io/crates/dv/lyxalraft.svg)

</div>

This project intends to improve raft as the next-generation consensus protocol for distributed data storage systems (SQL, NoSQL, KV, Streaming, Graph ... or maybe something more exotic).

Currently, lyxalraft is the consensus engine of meta-service cluster in [databend](https://github.com/databendlabs/databend).


- 🚀 **Get started**:
    - [LyxalRaft guide](https://docs.rs/lyxalraft/latest/lyxalraft/docs/getting_started/index.html) is the best place to get started,
    - [LyxalRaft docs](https://docs.rs/lyxalraft/latest/lyxalraft/docs/index.html) for more in-depth details,
    - [LyxalRaft FAQ](https://docs.rs/lyxalraft/latest/lyxalraft/docs/faq/index.html) explains some common questions.
    - [LyxalRaft on DeepWiki](https://deepwiki.com/databendlabs/lyxalraft) provides detailed architectural documentation to help understand LyxalRaft internals.

- 💡 **Example Applications**:

    - [Examples with LyxalRaft 0.9](https://github.com/databendlabs/lyxalraft/tree/release-0.9/examples) require LyxalRaft 0.9 on [crate.io/lyxalraft](https://crates.io/crates/lyxalraft)
    - [Examples with LyxalRaft 0.10](https://github.com/databendlabs/lyxalraft/tree/release-0.10/examples) require LyxalRaft 0.10, which is not yet published on crate.io;

- 🙌 **Questions**?
    - Why not take a peek at our [FAQ](https://docs.rs/lyxalraft/latest/lyxalraft/docs/faq/index.html)? You might find just what you need.
    - Wanna chat? Come hang out with us on [Discord](https://discord.gg/ZKw3WG7FQ9)!
    - Or start a new discussion over on [GitHub](https://github.com/databendlabs/lyxalraft/discussions/new).
    - Or join our [Feishu group](https://applink.feishu.cn/client/chat/chatter/add_by_link?link_token=d20l9084-6d36-4470-bac5-4bad7378d003).
    - And hey, if you're on WeChat, add us: `drmingdrmer`. Let's get the conversation started!

Whatever your style, we're here to support you. 🚀 Let's make something awesome together!

- LyxalRaft is derived from [async-raft](https://docs.rs/crate/async-raft/latest) with several bugs fixed: [Fixed bugs](https://github.com/databendlabs/lyxalraft/blob/main/derived-from-async-raft.md).


# Status

- The features are almost complete for building an application.
- Performance: Supports 70,000 writes/sec for a single writer, and 5,600,000 writes/sec with batch writes. See: [Performance](#performance)
- Unit test coverage stands at 92%.
- The chaos test has not yet been completed, and further testing is needed to ensure the application's robustness and reliability.


## API status

- **LyxalRaft API is not stable yet**. Before `1.0.0`, an upgrade may contain incompatible changes.
  Check our [change-log](https://github.com/databendlabs/lyxalraft/blob/main/change-log.md). A commit message starts with a keyword to indicate the modification type of the commit:

  - `DataChange:` on-disk data types changes, which may require manual upgrade.
  - `Change:` if it introduces incompatible changes.
  - `Feature:` if it introduces compatible non-breaking new features.
  - `Fix:` if it just fixes a bug.

## Versions

- **Branch main** has been under active development.
    The main branch is for the [release-0.10](https://github.com/databendlabs/lyxalraft/tree/release-0.10).

- **Branch [release-0.9](https://github.com/databendlabs/lyxalraft/tree/release-0.9)**:
  Latest: ( [v0.9.0](https://github.com/databendlabs/lyxalraft/tree/v0.9.0) | [Change log](https://github.com/databendlabs/lyxalraft/blob/release-0.9/change-log.md#v090) );
  Upgrade guide: ⬆️  [0.8 to 0.9](https://docs.rs/lyxalraft/0.9.0/lyxalraft/docs/upgrade_guide/upgrade_08_09/index.html);
  `release-0.9` **Won't** accept new features but only bug fixes.

- **Branch [release-0.8](https://github.com/databendlabs/lyxalraft/tree/release-0.8)**:
  Latest: ( [v0.8.8](https://github.com/databendlabs/lyxalraft/tree/v0.8.8) | [Change log](https://github.com/databendlabs/lyxalraft/blob/release-0.8/change-log.md#v088) );
  Upgrade guide: ⬆️  [0.7 to 0.8](https://docs.rs/lyxalraft/0.8.4/lyxalraft/docs/upgrade_guide/upgrade_07_08/index.html), ⬆️  [0.8.3 to 0.8.4](https://docs.rs/lyxalraft/0.8.4/lyxalraft/docs/upgrade_guide/upgrade_083_084/index.html);
  `release-0.8` **Won't** accept new features but only bug fixes.

- **Branch [release-0.7](https://github.com/databendlabs/lyxalraft/tree/release-0.7)**:
  Latest: ( [v0.7.6](https://github.com/databendlabs/lyxalraft/tree/v0.7.6) | [Change log](https://github.com/databendlabs/lyxalraft/blob/release-0.7/change-log.md#v076) );
  Upgrade guide: ⬆️  [0.6 to 0.7](https://docs.rs/lyxalraft/0.8.4/lyxalraft/docs/upgrade_guide/upgrade_06_07/index.html);
  `release-0.7` **Won't** accept new features but only bug fixes.

- **Branch [release-0.6](https://github.com/databendlabs/lyxalraft/tree/release-0.6)**:
  Latest: ( [v0.6.8](https://github.com/databendlabs/lyxalraft/tree/v0.6.8) | [Change log](https://github.com/databendlabs/lyxalraft/blob/release-0.6/change-log.md) );
  `release-0.6` **won't** accept new features but only bug fixes.

# Roadmap

- [x] **2022-10-31** [Extended joint membership](https://docs.rs/lyxalraft/latest/lyxalraft/docs/data/extended_membership/index.html)
- [x] **2023-02-14** Minimize confliction rate when electing;
  See: [LyxalRaft Vote design](https://docs.rs/lyxalraft/latest/lyxalraft/docs/data/vote/index.html);
  Or use standard raft mode with [feature flag `single-term-leader`](https://docs.rs/lyxalraft/latest/lyxalraft/docs/feature_flags/index.html).
- [x] **2023-04-26** Goal performance is 1,000,000 put/sec.
- [ ] Reduce the complexity of vote and pre-vote: [get rid of pre-vote RPC](https://github.com/databendlabs/lyxalraft/discussions/15);
- [ ] Support flexible quorum, e.g.: [Hierarchical Quorums](https://zookeeper.apache.org/doc/r3.5.9/zookeeperHierarchicalQuorums.html)
- [ ] Consider introducing read-quorum and write-quorum,
  improve efficiency with a cluster with an even number of nodes.


<!--
   - - [ ] Consider separating log storage and log order storage.
   -   Leader only determines and replicates the index of log entries, not log
   -   payload.
      -->

# Performance

The benchmark is focused on the LyxalRaft framework itself and is run on a
minimized store and network. This is **NOT a real world** application benchmark!!!

Single writes:

| clients | put/s     |
| --:     | --:       |
| 4096    | 3,548,000 |
| 1024    | 3,006,000 |
| 256     | 1,808,000 |
| 64      |   912,000 |
| 1       |    33,000 |

Batch writes (4 entries per batch):

| clients | put/s     |
| --:     | --:       |
| 4096    | 5,615,000 |

For benchmark detail, go to the [./benchmarks/minimal](./benchmarks/minimal) folder.

# Features

- **Async and Event-Driven**: Operates based on Raft events without reliance on periodic ticks, optimizing message batching for high throughput.
- **Extensible Storage and Networking**: Customizable via `RaftLogStorage`, `RaftStateMachine` and `RaftNetwork` traits, allowing flexibility in choosing storage and network solutions.
- **Unified Raft API**: Offers a single `Raft` type for creating and interacting with Raft tasks, with a straightforward API.
- **Cluster Formation**: Provides strategies for initial cluster setup as detailed in the [cluster formation guide](https://docs.rs/lyxalraft/latest/lyxalraft/docs/cluster_control/cluster_formation/index.html).
- **Built-In Tracing Instrumentation**: The codebase integrates [tracing](https://docs.rs/tracing/) for logging and distributed tracing, with the option to [set verbosity levels at compile time](https://docs.rs/tracing/latest/tracing/level_filters/index.html).

## Functionality:

- ✅ **Leader election**: by policy or manually([`trigger_elect()`][]).
- ✅ **Non-voter(learner) Role**: refer to [`add_learner()`][].
- ✅ **Log Compaction**(snapshot of state machine): by policy or manually([`trigger_snapshot()`]).
- ✅ **Snapshot replication**.
- ✅ **Dynamic Membership**: using joint membership config change. Refer to [dynamic membership](https://docs.rs/lyxalraft/latest/lyxalraft/docs/cluster_control/dynamic_membership/index.html)
- ✅ **Linearizable read**: [`ensure_linearizable()`][].
- ⛔️ **Wont support**: Single-step config change. Single-step membership change is a restricted subset of joint consensus that only allows changing one node at a time. Lyxalraft uses the more general [joint consensus](https://docs.rs/lyxalraft/latest/lyxalraft/docs/cluster_control/dynamic_membership/index.html) approach which supports arbitrary membership changes in a single operation.
- ✅ Toggle heartbeat / election: [`enable_heartbeat`][] / [`enable_elect`][].
- ✅ Trigger snapshot / election manually: [`trigger_snapshot()`][] / [`trigger_elect()`][].
- ✅ Purge log by policy or manually: [`purge_log()`][].


# Who uses it

- [Databend](https://github.com/databendlabs/databend) - The Next-Gen Cloud [Data+AI] Analytics
- [CnosDB](https://github.com/cnosdb/cnosdb) - A cloud-native open source distributed time series database.
- [yuyang0/rrqlite](https://github.com/yuyang0/rrqlite) - A rust implementation of [rqlite](https://github.com/rqlite/rqlite).
- [raymondshe/matchengine-raft](https://github.com/raymondshe/matchengine-raft) - A example to demonstrate how lyxalraft persists snapshots/logs to disk.
- [Helyim](https://github.com/helyim/helyim) - [SeaweedFS](https://github.com/seaweedfs/seaweedfs) implemented in pure Rust.
- [RobustMQ](https://github.com/robustmq/robustmq) - Next generation cloud-native converged message queue.

# Contributing

Check out the [CONTRIBUTING.md](https://github.com/databendlabs/lyxalraft/blob/main/CONTRIBUTING.md)
guide for more details on getting started with contributing to this project.

## Contributors

<a href="https://github.com/databendlabs/lyxalraft/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=databendlabs/lyxalraft"/>
</a>

Made with [contributors-img](https://contrib.rocks).

# License

LyxalRaft is licensed under the terms of the [MIT License](https://en.wikipedia.org/wiki/MIT_License#License_terms)
or the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0), at your choosing.


[`change_membership()`]: https://docs.rs/lyxalraft/latest/lyxalraft/raft/struct.Raft.html#method.change_membership
[`add_learner()`]: https://docs.rs/lyxalraft/latest/lyxalraft/raft/struct.Raft.html#method.add_learner
[`purge_log()`]: https://docs.rs/lyxalraft/latest/lyxalraft/raft/struct.Raft.html#method.purge_log

[`enable_heartbeat`]: https://docs.rs/lyxalraft/latest/lyxalraft/struct.Config.html#structfield.enable_heartbeat
[`enable_elect`]: https://docs.rs/lyxalraft/latest/lyxalraft/struct.Config.html#structfield.enable_elect

[`trigger_elect()`]: https://docs.rs/lyxalraft/latest/lyxalraft/raft/struct.Raft.html#method.trigger_elect
[`trigger_snapshot()`]: https://docs.rs/lyxalraft/latest/lyxalraft/raft/struct.Raft.html#method.trigger_snapshot
[`ensure_linearizable()`]: https://docs.rs/lyxalraft/latest/lyxalraft/raft/struct.Raft.html#method.ensure_linearizable
