use std::marker::PhantomData;

mod phase;
mod select_muxer;
mod select_security;

#[cfg(all(not(target_arch = "wasm32"), feature = "websocket"))]
pub use phase::WebsocketError;
pub use phase::{BehaviourError, TransportError};

/// Build a [`Swarm`](lyxal_network_swarm::Swarm) by combining an identity, a set of
/// [`Transport`](lyxal_network_core::Transport)s and a
/// [`NetworkBehaviour`](lyxal_network_swarm::NetworkBehaviour).
///
/// ```
/// # use lyxal_network::{swarm::NetworkBehaviour, SwarmBuilder};
/// # use lyxal_network::core::transport::dummy::DummyTransport;
/// # use lyxal_network::core::muxing::StreamMuxerBox;
/// # use lyxal_network::identity::PeerId;
/// # use std::error::Error;
/// #
/// # #[cfg(all(
/// #     not(target_arch = "wasm32"),
/// #     feature = "tokio",
/// #     feature = "tcp",
/// #     feature = "tls",
/// #     feature = "noise",
/// #     feature = "quic",
/// #     feature = "dns",
/// #     feature = "relay",
/// #     feature = "websocket",
/// # ))]
/// # async fn build_swarm() -> Result<(), Box<dyn Error>> {
/// #     #[derive(NetworkBehaviour)]
/// #     #[behaviour(prelude = "lyxal_network_swarm::derive_prelude")]
/// #     struct MyBehaviour {
/// #         relay: lyxal_network_relay::client::Behaviour,
/// #     }
///
/// let swarm = SwarmBuilder::with_new_identity()
///     .with_tokio()
///     .with_tcp(
///         Default::default(),
///         (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
///         lyxal_network_yamux::Config::default,
///     )?
///     .with_quic()
///     .with_other_transport(|_key| DummyTransport::<(PeerId, StreamMuxerBox)>::new())?
///     .with_dns()?
///     .with_websocket(
///         (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
///         lyxal_network_yamux::Config::default,
///     )
///     .await?
///     .with_relay_client(
///         (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
///         lyxal_network_yamux::Config::default,
///     )?
///     .with_behaviour(|_key, relay| MyBehaviour { relay })?
///     .with_swarm_config(|cfg| {
///         // Edit cfg here.
///         cfg
///     })
///     .build();
/// #
/// #     Ok(())
/// # }
/// ```
pub struct SwarmBuilder<Provider, Phase> {
    keypair: lyxal_network_identity::Keypair,
    phantom: PhantomData<Provider>,
    phase: Phase,
}

#[cfg(test)]
mod tests {
    use lyxal_network_core::{muxing::StreamMuxerBox, transport::dummy::DummyTransport};
    use lyxal_network_identity::PeerId;
    use lyxal_network_swarm::NetworkBehaviour;

    use crate::SwarmBuilder;

    #[test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "tls",
        feature = "noise",
        feature = "yamux",
    ))]
    fn tcp() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                lyxal_network_tls::Config::new,
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(all(feature = "tokio", feature = "quic"))]
    fn quic() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_quic()
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(all(feature = "tokio", feature = "quic"))]
    fn quic_config() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_quic_config(|config| config)
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(all(feature = "tokio", feature = "tcp", feature = "tls", feature = "yamux"))]
    fn tcp_yamux_mplex() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                lyxal_network_tls::Config::new,
                (lyxal_network_yamux::Config::default, lyxal_network_mplex::Config::default),
            )
            .unwrap()
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "tls",
        feature = "noise",
        feature = "yamux"
    ))]
    fn tcp_tls_noise() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
                (lyxal_network_yamux::Config::default, lyxal_network_mplex::Config::default),
            )
            .unwrap()
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "tls",
        feature = "noise",
        feature = "yamux",
        feature = "quic"
    ))]
    fn tcp_quic() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_quic()
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "tls",
        feature = "noise",
        feature = "yamux",
        feature = "quic"
    ))]
    fn tcp_quic_config() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_quic_config(|config| config)
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "tls",
        feature = "noise",
        feature = "yamux",
        feature = "relay"
    ))]
    fn tcp_relay() {
        #[derive(lyxal_network_swarm::NetworkBehaviour)]
        #[behaviour(prelude = "lyxal_network_swarm::derive_prelude")]
        struct Behaviour {
            dummy: lyxal_network_swarm::dummy::Behaviour,
            relay: lyxal_network_relay::client::Behaviour,
        }

        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                lyxal_network_tls::Config::new,
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_relay_client(lyxal_network_tls::Config::new, lyxal_network_yamux::Config::default)
            .unwrap()
            .with_behaviour(|_, relay| Behaviour {
                dummy: lyxal_network_swarm::dummy::Behaviour,
                relay,
            })
            .unwrap()
            .build();
    }

    #[tokio::test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "tls",
        feature = "noise",
        feature = "yamux",
        feature = "dns"
    ))]
    async fn tcp_dns() {
        SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_dns()
            .unwrap()
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[tokio::test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "noise",
        feature = "yamux",
        feature = "dns"
    ))]
    async fn tcp_dns_config() {
        SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_dns_config(
                lyxal_network_dns::ResolverConfig::default(),
                lyxal_network_dns::ResolverOpts::default(),
            )
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[tokio::test]
    #[cfg(all(feature = "tokio", feature = "quic", feature = "dns"))]
    async fn quic_dns_config() {
        SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_quic()
            .with_dns_config(
                lyxal_network_dns::ResolverConfig::default(),
                lyxal_network_dns::ResolverOpts::default(),
            )
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[tokio::test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "noise",
        feature = "yamux",
        feature = "quic",
        feature = "dns"
    ))]
    async fn tcp_quic_dns_config() {
        SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_quic()
            .with_dns_config(
                lyxal_network_dns::ResolverConfig::default(),
                lyxal_network_dns::ResolverOpts::default(),
            )
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    /// Showcases how to provide custom transports unknown to the lyxal_network crate, e.g. WebRTC.
    #[test]
    #[cfg(feature = "tokio")]
    fn other_transport() -> Result<(), Box<dyn std::error::Error>> {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            // Closure can either return a Transport directly.
            .with_other_transport(|_| DummyTransport::<(PeerId, StreamMuxerBox)>::new())?
            // Or a Result containing a Transport.
            .with_other_transport(|_| {
                if true {
                    Ok(DummyTransport::<(PeerId, StreamMuxerBox)>::new())
                } else {
                    Err(Box::from("test"))
                }
            })?
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();

        Ok(())
    }

    #[tokio::test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "tls",
        feature = "noise",
        feature = "yamux",
        feature = "dns",
        feature = "websocket",
    ))]
    async fn tcp_websocket() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_websocket(
                (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
                lyxal_network_yamux::Config::default,
            )
            .await
            .unwrap()
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[tokio::test]
    #[cfg(all(
        feature = "tokio",
        feature = "tcp",
        feature = "tls",
        feature = "noise",
        feature = "yamux",
        feature = "quic",
        feature = "dns",
        feature = "relay",
        feature = "websocket",
        feature = "metrics",
    ))]
    async fn all() {
        #[derive(NetworkBehaviour)]
        #[behaviour(prelude = "lyxal_network_swarm::derive_prelude")]
        struct MyBehaviour {
            relay: lyxal_network_relay::client::Behaviour,
        }

        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                lyxal_network_tls::Config::new,
                lyxal_network_yamux::Config::default,
            )
            .unwrap()
            .with_quic()
            .with_dns()
            .unwrap()
            .with_websocket(lyxal_network_tls::Config::new, lyxal_network_yamux::Config::default)
            .await
            .unwrap()
            .with_relay_client(lyxal_network_tls::Config::new, lyxal_network_yamux::Config::default)
            .unwrap()
            .with_bandwidth_metrics(&mut lyxal_network_metrics::Registry::default())
            .with_behaviour(|_key, relay| MyBehaviour { relay })
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(all(feature = "tokio", feature = "tcp", feature = "tls", feature = "yamux"))]
    fn tcp_bandwidth_metrics() -> Result<(), Box<dyn std::error::Error>> {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_tcp(
                Default::default(),
                lyxal_network_tls::Config::new,
                lyxal_network_yamux::Config::default,
            )?
            .with_bandwidth_metrics(&mut lyxal_network_metrics::Registry::default())
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();

        Ok(())
    }

    #[test]
    #[cfg(all(feature = "tokio", feature = "quic"))]
    fn quic_bandwidth_metrics() {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_quic()
            .with_bandwidth_metrics(&mut lyxal_network_metrics::Registry::default())
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();
    }

    #[test]
    #[cfg(feature = "tokio")]
    fn other_transport_bandwidth_metrics() -> Result<(), Box<dyn std::error::Error>> {
        let _ = SwarmBuilder::with_new_identity()
            .with_tokio()
            .with_other_transport(|_| DummyTransport::<(PeerId, StreamMuxerBox)>::new())?
            .with_bandwidth_metrics(&mut lyxal_network_metrics::Registry::default())
            .with_behaviour(|_| lyxal_network_swarm::dummy::Behaviour)
            .unwrap()
            .build();

        Ok(())
    }
}
