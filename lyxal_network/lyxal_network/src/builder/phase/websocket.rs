use std::marker::PhantomData;

#[cfg(all(not(target_arch = "wasm32"), feature = "websocket"))]
use lyxal_network_core::muxing::{StreamMuxer, StreamMuxerBox};
use lyxal_network_core::upgrade::{InboundConnectionUpgrade, OutboundConnectionUpgrade};
#[cfg(all(not(target_arch = "wasm32"), feature = "websocket"))]
use lyxal_network_core::Transport;
#[cfg(any(
    all(not(target_arch = "wasm32"), feature = "websocket"),
    feature = "relay"
))]
use lyxal_network_core::{InboundUpgrade, Negotiated, OutboundUpgrade, UpgradeInfo};
#[cfg(any(
    all(not(target_arch = "wasm32"), feature = "websocket"),
    feature = "relay"
))]
use lyxal_network_identity::PeerId;

use super::*;
use crate::SwarmBuilder;

pub struct WebsocketPhase<T> {
    pub(crate) transport: T,
}

macro_rules! impl_websocket_builder {
    ($providerKebabCase:literal, $providerPascalCase:ty, $dnsTcp:expr, $websocketStream:ty) => {
        /// Adds a websocket client transport.
        ///
        /// Note that both `security_upgrade` and `multiplexer_upgrade` take function pointers,
        /// i.e. they take the function themselves (without the invocation via `()`), not the
        /// result of the function invocation. See example below.
        ///
        /// ``` rust
        /// # use lyxal_network::SwarmBuilder;
        /// # use std::error::Error;
        /// # async fn build_swarm() -> Result<(), Box<dyn Error>> {
        /// let swarm = SwarmBuilder::with_new_identity()
        ///     .with_tokio()
        ///     .with_websocket(
        ///         (lyxal_network_tls::Config::new, lyxal_network_noise::Config::new),
        ///         lyxal_network_yamux::Config::default,
        ///     )
        ///     .await?
        /// # ;
        /// # Ok(())
        /// # }
        /// ```
        #[cfg(all(not(target_arch = "wasm32"), feature = $providerKebabCase, feature = "websocket"))]
        impl<T> SwarmBuilder<$providerPascalCase, WebsocketPhase<T>> {
            pub async fn with_websocket<
                SecUpgrade,
                SecStream,
                SecError,
                MuxUpgrade,
                MuxStream,
                MuxError,
            >(
                self,
                security_upgrade: SecUpgrade,
                multiplexer_upgrade: MuxUpgrade,
            ) -> Result<
                SwarmBuilder<
                    $providerPascalCase,
                    RelayPhase<impl AuthenticatedMultiplexedTransport>,
                >,
                WebsocketError<SecUpgrade::Error>,
            >

            where
                T: AuthenticatedMultiplexedTransport,

                SecStream: futures::AsyncRead + futures::AsyncWrite + Unpin + Send + 'static,
                SecError: std::error::Error + Send + Sync + 'static,
                SecUpgrade: IntoSecurityUpgrade<$websocketStream>,
                SecUpgrade::Upgrade: InboundConnectionUpgrade<Negotiated<$websocketStream>, Output = (PeerId, SecStream), Error = SecError> + OutboundConnectionUpgrade<Negotiated<$websocketStream>, Output = (PeerId, SecStream), Error = SecError> + Clone + Send + 'static,
                <SecUpgrade::Upgrade as InboundConnectionUpgrade<Negotiated<$websocketStream>>>::Future: Send,
                <SecUpgrade::Upgrade as OutboundConnectionUpgrade<Negotiated<$websocketStream>>>::Future: Send,
                <<<SecUpgrade as IntoSecurityUpgrade<$websocketStream>>::Upgrade as UpgradeInfo>::InfoIter as IntoIterator>::IntoIter: Send,
                <<SecUpgrade as IntoSecurityUpgrade<$websocketStream>>::Upgrade as UpgradeInfo>::Info: Send,

                MuxStream: StreamMuxer + Send + 'static,
                MuxStream::Substream: Send + 'static,
                MuxStream::Error: Send + Sync + 'static,
                MuxUpgrade: IntoMultiplexerUpgrade<SecStream>,
                MuxUpgrade::Upgrade: InboundConnectionUpgrade<Negotiated<SecStream>, Output = MuxStream, Error = MuxError> + OutboundConnectionUpgrade<Negotiated<SecStream>, Output = MuxStream, Error = MuxError> + Clone + Send + 'static,
                <MuxUpgrade::Upgrade as InboundConnectionUpgrade<Negotiated<SecStream>>>::Future: Send,
                <MuxUpgrade::Upgrade as OutboundConnectionUpgrade<Negotiated<SecStream>>>::Future: Send,
                MuxError: std::error::Error + Send + Sync + 'static,
                <<<MuxUpgrade as IntoMultiplexerUpgrade<SecStream>>::Upgrade as UpgradeInfo>::InfoIter as IntoIterator>::IntoIter: Send,
                <<MuxUpgrade as IntoMultiplexerUpgrade<SecStream>>::Upgrade as UpgradeInfo>::Info: Send,

            {
                let security_upgrade = security_upgrade.into_security_upgrade(&self.keypair)
                    .map_err(WebsocketErrorInner::SecurityUpgrade)?;
                let websocket_transport = lyxal_network_websocket::Config::new(
                    $dnsTcp.await.map_err(WebsocketErrorInner::Dns)?,
                )
                    .upgrade(lyxal_network_core::upgrade::Version::V1Lazy)
                    .authenticate(security_upgrade)
                    .multiplex(multiplexer_upgrade.into_multiplexer_upgrade())
                    .map(|(p, c), _| (p, StreamMuxerBox::new(c)));

                Ok(SwarmBuilder {
                    keypair: self.keypair,
                    phantom: PhantomData,
                    phase: RelayPhase {
                        transport: websocket_transport
                            .or_transport(self.phase.transport)
                            .map(|either, _| either.into_inner()),
                    },
                })
            }
        }
    };
}

impl_websocket_builder!(
    "tokio",
    super::provider::Tokio,
    // Note this is an unnecessary await for Tokio Websocket (i.e. tokio dns) in order to be
    // consistent with above AsyncStd construction.
    futures::future::ready(lyxal_network_dns::tokio::Transport::system(
        lyxal_network_tcp::tokio::Transport::new(lyxal_network_tcp::Config::default())
    )),
    rw_stream_sink::RwStreamSink<lyxal_network_websocket::BytesConnection<lyxal_network_tcp::tokio::TcpStream>>
);

impl<Provider, T: AuthenticatedMultiplexedTransport> SwarmBuilder<Provider, WebsocketPhase<T>> {
    pub(crate) fn without_websocket(self) -> SwarmBuilder<Provider, RelayPhase<T>> {
        SwarmBuilder {
            keypair: self.keypair,
            phantom: PhantomData,
            phase: RelayPhase {
                transport: self.phase.transport,
            },
        }
    }
}

// Shortcuts
#[cfg(feature = "relay")]
impl<T: AuthenticatedMultiplexedTransport, Provider> SwarmBuilder<Provider, WebsocketPhase<T>> {
    /// See [`SwarmBuilder::with_relay_client`].
    pub fn with_relay_client<SecUpgrade, SecStream, SecError, MuxUpgrade, MuxStream, MuxError>(
        self,
        security_upgrade: SecUpgrade,
        multiplexer_upgrade: MuxUpgrade,
    ) -> Result<
        SwarmBuilder<
            Provider,
            BandwidthMetricsPhase<impl AuthenticatedMultiplexedTransport, lyxal_network_relay::client::Behaviour>,
        >,
        SecUpgrade::Error,
        > where

        SecStream: futures::AsyncRead + futures::AsyncWrite + Unpin + Send + 'static,
        SecError: std::error::Error + Send + Sync + 'static,
        SecUpgrade: IntoSecurityUpgrade<lyxal_network_relay::client::Connection>,
        SecUpgrade::Upgrade: InboundConnectionUpgrade<Negotiated<lyxal_network_relay::client::Connection>, Output = (PeerId, SecStream), Error = SecError> + OutboundConnectionUpgrade<Negotiated<lyxal_network_relay::client::Connection>, Output = (PeerId, SecStream), Error = SecError> + Clone + Send + 'static,
    <SecUpgrade::Upgrade as InboundConnectionUpgrade<Negotiated<lyxal_network_relay::client::Connection>>>::Future: Send,
    <SecUpgrade::Upgrade as OutboundConnectionUpgrade<Negotiated<lyxal_network_relay::client::Connection>>>::Future: Send,
    <<<SecUpgrade as IntoSecurityUpgrade<lyxal_network_relay::client::Connection>>::Upgrade as UpgradeInfo>::InfoIter as IntoIterator>::IntoIter: Send,
    <<SecUpgrade as IntoSecurityUpgrade<lyxal_network_relay::client::Connection>>::Upgrade as UpgradeInfo>::Info: Send,

        MuxStream: lyxal_network_core::muxing::StreamMuxer + Send + 'static,
        MuxStream::Substream: Send + 'static,
        MuxStream::Error: Send + Sync + 'static,
        MuxUpgrade: IntoMultiplexerUpgrade<SecStream>,
        MuxUpgrade::Upgrade: InboundConnectionUpgrade<Negotiated<SecStream>, Output = MuxStream, Error = MuxError> + OutboundConnectionUpgrade<Negotiated<SecStream>, Output = MuxStream, Error = MuxError> + Clone + Send + 'static,
    <MuxUpgrade::Upgrade as InboundConnectionUpgrade<Negotiated<SecStream>>>::Future: Send,
    <MuxUpgrade::Upgrade as OutboundConnectionUpgrade<Negotiated<SecStream>>>::Future: Send,
        MuxError: std::error::Error + Send + Sync + 'static,
    <<<MuxUpgrade as IntoMultiplexerUpgrade<SecStream>>::Upgrade as UpgradeInfo>::InfoIter as IntoIterator>::IntoIter: Send,
    <<MuxUpgrade as IntoMultiplexerUpgrade<SecStream>>::Upgrade as UpgradeInfo>::Info: Send,
    {
        self.without_websocket()
            .with_relay_client(security_upgrade, multiplexer_upgrade)
    }
}
#[cfg(feature = "metrics")]
impl<Provider, T: AuthenticatedMultiplexedTransport> SwarmBuilder<Provider, WebsocketPhase<T>> {
    pub fn with_bandwidth_metrics(
        self,
        registry: &mut lyxal_network_metrics::Registry,
    ) -> SwarmBuilder<
        Provider,
        BehaviourPhase<impl AuthenticatedMultiplexedTransport, NoRelayBehaviour>,
    > {
        self.without_websocket()
            .without_relay()
            .with_bandwidth_metrics(registry)
    }
}
impl<Provider, T: AuthenticatedMultiplexedTransport> SwarmBuilder<Provider, WebsocketPhase<T>> {
    pub fn with_behaviour<B, R: TryIntoBehaviour<B>>(
        self,
        constructor: impl FnOnce(&lyxal_network_identity::Keypair) -> R,
    ) -> Result<SwarmBuilder<Provider, SwarmPhase<T, B>>, R::Error> {
        self.without_websocket()
            .without_relay()
            .with_behaviour(constructor)
    }
}

#[derive(Debug, thiserror::Error)]
#[error(transparent)]
#[cfg(all(not(target_arch = "wasm32"), feature = "websocket"))]
pub struct WebsocketError<Sec>(#[from] WebsocketErrorInner<Sec>);

#[derive(Debug, thiserror::Error)]
#[cfg(all(not(target_arch = "wasm32"), feature = "websocket"))]
enum WebsocketErrorInner<Sec> {
    #[error("SecurityUpgrade")]
    SecurityUpgrade(Sec),
    #[cfg(feature = "dns")]
    #[error("Dns")]
    Dns(#[from] std::io::Error),
}
