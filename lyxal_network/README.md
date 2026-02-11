# Central repository for work on lyxal_network

<a href="http://lyxal_network.io/"><img src="https://img.shields.io/badge/project-lyxal_network-yellow.svg?style=flat-square" /></a>
[![dependency status](https://deps.rs/repo/github/lyxal_network/lyxal_network/status.svg?style=flat-square)](https://deps.rs/repo/github/lyxal_network/lyxal_network)
[![Crates.io](https://img.shields.io/crates/v/lyxal_network.svg)](https://crates.io/crates/lyxal_network)
[![docs.rs](https://img.shields.io/badge/api-rustdoc-blue.svg)](https://docs.rs/lyxal_network)
[![docs.rs master](https://img.shields.io/badge/docs-master-blueviolet)](https://lyxal_network.github.io/lyxal_network/lyxal_network/)

This repository is the central place for Rust development of the [lyxal_network](https://lyxal_network.io) spec.

## Getting started

- **Main documentation** can be found on https://docs.rs/lyxal_network.

- The **[examples](examples)** folder contains small binaries showcasing the
  many protocols in this repository.

- For **security related issues** please [file a private security vulnerability
  report](https://github.com/lyxal_network/lyxal_network/security/advisories/new) . Please do not file a
  public issue on GitHub.

- To **report bugs, suggest improvements or request new features** please open a
  GitHub issue on this repository.

- For **lyxal_network specific questions** please use the GitHub _Discussions_
  forum https://github.com/lyxal_network/lyxal_network/discussions.

- For **discussions and questions related to multiple lyxal_network implementations**
  please use the lyxal_network _Discourse_ forum https://discuss.lyxal_network.io.

- For synchronous discussions join the [open lyxal_network maintainer
  calls](https://github.com/lyxal_network/lyxal_network/discussions?discussions_q=open+maintainers+call+)
  or the [biweekly lyxal_network community calls](https://discuss.lyxal_network.io/t/lyxal_network-community-calls/1157).

## Repository Structure

The main components of this repository are structured as follows:

  * `core/`: The implementation of `lyxal_network-core` with its `Transport` and
    `StreamMuxer` API on which almost all other crates depend.

  * `transports/`: Implementations of transport protocols (e.g. TCP) and protocol upgrades
    (e.g. for authenticated encryption, compression, ...) based on the `lyxal_network-core` `Transport`
    API.

  * `muxers/`: Implementations of the `StreamMuxer` interface of `lyxal_network-core`,
    e.g. (sub)stream multiplexing protocols on top of (typically TCP) connections.
    Multiplexing protocols are (mandatory) `Transport` upgrades.

  * `swarm/`: The implementation of `lyxal_network-swarm` building on `lyxal_network-core`
    with the central interfaces `NetworkBehaviour` and `ConnectionHandler` used
    to implement application protocols (see `protocols/`).

  * `protocols/`: Implementations of application protocols based on the
    `lyxal_network-swarm` APIs.

  * `misc/`: Utility libraries.

  * `lyxal_network/examples/`: Worked examples of built-in application protocols (see `protocols/`)
    with common `Transport` configurations.

## Community Guidelines

The lyxal_network project operates under the [IPFS Code of
Conduct](https://github.com/ipfs/community/blob/master/code-of-conduct.md).

> tl;dr
>
> - Be respectful.
> - We're here to help: abuse@ipfs.io
> - Abusive behavior is never tolerated.
> - Violations of this code may result in swift and permanent expulsion from the
>   IPFS [and lyxal_network] community.
> - "Too long, didn't read" is not a valid excuse for not knowing what is in
>   this document.

## Maintainers

(In alphabetical order.)

- João Oliveira ([@jxs](https://github.com/jxs))

## Notable users

(open a pull request if you want your project to be added here)

- [COMIT](https://github.com/comit-network/xmr-btc-swap) - Bitcoin–Monero Cross-chain Atomic Swap.
- [Forest](https://github.com/ChainSafe/forest) - An implementation of Filecoin written in Rust.
- [fuel-core](https://github.com/FuelLabs/fuel-core) - A Rust implementation of the Fuel protocol.
- [HotShot](https://github.com/EspressoSystems/HotShot) - Decentralized sequencer in Rust developed by [Espresso Systems](https://www.espressosys.com/).
- [ipfs-embed](https://github.com/ipfs-rust/ipfs-embed) - A small embeddable ipfs implementation used and maintained by [Actyx](https://www.actyx.com).
- [Homestar](https://github.com/ipvm-wg/homestar) - An InterPlanetary Virtual Machine (IPVM) implementation used and maintained by Fission.
- [beetle](https://github.com/n0-computer/beetle) - Next-generation implementation of IPFS for Cloud & Mobile platforms.
- [Lighthouse](https://github.com/sigp/lighthouse) - Ethereum consensus client in Rust.
- [Locutus](https://github.com/freenet/locutus) - Global, observable, decentralized key-value store.
- [OpenMina](https://github.com/openmina/openmina) - In-browser Mina Rust implementation.
- [qaul قول](https://github.com/qaul/qaul.net) - Internet Independent Wireless Mesh Communication App
- [rust-ipfs](https://github.com/rs-ipfs/rust-ipfs) - IPFS implementation in Rust.
- [Safe Network](https://github.com/maidsafe/safe_network) - Safe Network implementation in Rust.
- [SQD Network](https://github.com/subsquid/sqd-network) - A decentralized storage for Web3 data.
- [Starcoin](https://github.com/starcoinorg/starcoin) - A smart contract blockchain network that scales by layering.
- [Subspace](https://github.com/subspace/subspace) - Subspace Network reference implementation
- [Substrate](https://github.com/paritytech/substrate) - Framework for blockchain innovation,
used by [Polkadot](https://www.parity.io/technologies/polkadot/).
- [Swarm NL](https://github.com/algorealmInc/SwarmNL) - A library that makes it easy to configure the networking requirements for any distributed application.
- [Taple](https://github.com/opencanarias/taple-core) - Sustainable DLT for asset and process traceability by [OpenCanarias](https://www.opencanarias.com/en/).
- [Ceylon](https://github.com/ceylonai/ceylon) - A Multi-Agent System (MAS) Development Framework.
- [Fungi](https://github.com/enbop/fungi) - A platform built for seamless multi-device integration.
