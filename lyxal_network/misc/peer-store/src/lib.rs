//! Implementation of peer store that stores address information
//! about foreign peers.
//!
//! ## Important Discrepancies
//! - **PeerStore is a local**: The peer store itself doesn't facilitate any information exchange
//!   between peers. You will need other protocols like `lyxal_network-kad` to share addresses you know
//!   across the network.
//! - **PeerStore is a standalone**: Other protocols cannot expect the existence of PeerStore, and
//!   need to be manually hooked up to PeerStore in order to obtain information it provides.
//!
//! ## Usage
//! Compose [`Behaviour`] with other [`NetworkBehaviour`](lyxal_network_swarm::NetworkBehaviour),
//! and the PeerStore will automatically track addresses from
//! [`FromSwarm::NewExternalAddrOfPeer`](lyxal_network_swarm::FromSwarm)
//! and provide addresses when dialing peers(require `extend_addresses_through_behaviour` in
//! [`DialOpts`](lyxal_network_swarm::dial_opts::DialOpts) when dialing).  
//! Other protocols need to be manually hooked up to obtain information from
//! or provide information to PeerStore.

mod behaviour;
pub mod memory_store;
mod store;

pub use behaviour::Behaviour;
pub use store::Store;
