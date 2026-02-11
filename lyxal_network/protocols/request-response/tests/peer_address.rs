#[cfg(feature = "cbor")]
use lyxal_network_core::ConnectedPoint;
#[cfg(feature = "cbor")]
use lyxal_network_request_response as request_response;
#[cfg(feature = "cbor")]
use lyxal_network_request_response::ProtocolSupport;
#[cfg(feature = "cbor")]
use lyxal_network_swarm::{StreamProtocol, Swarm, SwarmEvent};
#[cfg(feature = "cbor")]
use lyxal_network_swarm_test::SwarmExt;

#[cfg(feature = "cbor")]
use tracing_subscriber::EnvFilter;

#[tokio::test]
#[cfg(feature = "cbor")]
async fn dial_succeeds_after_adding_peers_address() {
    let _ = tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .try_init();

    let protocols = iter::once((StreamProtocol::new("/ping/1"), ProtocolSupport::Full));
    let config = request_response::Config::default();

    let mut swarm = Swarm::new_ephemeral_tokio(|_| {
        request_response::cbor::Behaviour::<Ping, Pong>::new(protocols.clone(), config.clone())
    });

    let mut swarm2 = Swarm::new_ephemeral_tokio(|_| {
        request_response::cbor::Behaviour::<Ping, Pong>::new(protocols.clone(), config.clone())
    });

    let peer_id2 = *swarm2.local_peer_id();

    let (listen_addr, _) = swarm2.listen().with_memory_addr_external().await;

    swarm.add_peer_address(peer_id2, listen_addr.clone());

    swarm.dial(peer_id2).unwrap();

    tokio::spawn(swarm2.loop_on_next());

    let (connected_peer_id, connected_address) = swarm
        .wait(|event| match event {
            SwarmEvent::ConnectionEstablished {
                peer_id, endpoint, ..
            } => {
                let address = match endpoint {
                    ConnectedPoint::Dialer { address, .. } => Some(address),
                    _ => None,
                };
                Some((peer_id, address))
            }
            _ => None,
        })
        .await;
    let expected_address = listen_addr.with_p2p(peer_id2).unwrap();

    assert_eq!(connected_peer_id, peer_id2);
    assert_eq!(expected_address, connected_address.unwrap());
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg(feature = "cbor")]
struct Ping(Vec<u8>);
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg(feature = "cbor")]
struct Pong(Vec<u8>);
