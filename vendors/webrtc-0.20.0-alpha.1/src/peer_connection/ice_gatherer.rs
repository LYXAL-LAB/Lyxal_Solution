//! ICE Candidate Gathering (Sans-I/O)
//!
//! This module provides RTCIceGatherer for gathering ICE candidates in a Sans-I/O manner.

use crate::runtime;
use rtc::ice::candidate::CandidateConfig;
use rtc::peer_connection::configuration::{RTCIceServer, RTCIceTransportPolicy};
use rtc::peer_connection::transport::{
    CandidateHostConfig, CandidateServerReflexiveConfig, CandidateRelayConfig, RTCIceCandidate, RTCIceCandidateInit,
};
use rtc::sansio::Protocol;
use rtc::shared::error::Error;
use rtc::shared::{FourTuple, TaggedBytesMut, TransportProtocol};
use rtc::stun::{
    client::Client as StunClient, client::ClientBuilder as StunClientBuilder,
    message::BINDING_REQUEST, message::Message as StunMessage, message::TransactionId,
};
use rtc::turn::client::{
    Client as TurnClient, ClientConfig as TurnClientConfig, Event as TurnEvent,
};
use log::{error, info};
use rtc::peer_connection::state::RTCIceGatheringState;
use rtc::stun::agent::StunEvent;
use rtc::stun::message::Getter;
use rtc::stun::xoraddr::XorMappedAddress;
use std::collections::{HashSet, VecDeque};
use std::net::SocketAddr;
use std::time::Instant;

/// ICEGatherOptions provides options relating to the gathering of ICE candidates.
#[derive(Default, Debug, Clone)]
pub(crate) struct RTCIceGatherOptions {
    pub(crate) ice_servers: Vec<RTCIceServer>,
    pub(crate) ice_gather_policy: RTCIceTransportPolicy,
}

#[derive(Debug)]
pub enum RTCIceGathererEvent {
    LocalIceCandidate(RTCIceCandidateInit),
    IceGatheringComplete,
}

/// RTCIceGatherer gathers local host, server reflexive and relay candidates
/// in a Sans-I/O manner.
pub(crate) struct RTCIceGatherer {
    local_addrs: Vec<SocketAddr>,
    ice_servers: Vec<RTCIceServer>,
    gather_policy: RTCIceTransportPolicy,
    state: RTCIceGatheringState,

    stun_clients: Vec<StunClient>,
    turn_clients: Vec<TurnClient>,
    gathering_clients: HashSet<FourTuple>,

    wouts: VecDeque<TaggedBytesMut>,
    events: VecDeque<RTCIceGathererEvent>,
}

impl RTCIceGatherer {
    pub(crate) fn new(local_addrs: Vec<SocketAddr>, opts: RTCIceGatherOptions) -> Self {
        Self {
            local_addrs,
            ice_servers: opts.ice_servers,
            gather_policy: opts.ice_gather_policy,
            state: RTCIceGatheringState::New,

            stun_clients: Vec::new(),
            turn_clients: Vec::new(),
            gathering_clients: HashSet::new(),

            wouts: VecDeque::new(),
            events: VecDeque::new(),
        }
    }

    pub(crate) fn state(&self) -> RTCIceGatheringState {
        self.state
    }

    pub(crate) fn is_ice_message(&self, msg: &TaggedBytesMut) -> bool {
        for stun_client in &self.stun_clients {
            if stun_client.peer_addr() == msg.transport.peer_addr
                && stun_client.local_addr() == msg.transport.local_addr
            {
                return true;
            }
        }
        for turn_client in &self.turn_clients {
            if turn_client.peer_addr() == msg.transport.peer_addr
                && turn_client.local_addr() == msg.transport.local_addr
            {
                return true;
            }
        }
        false
    }

    pub(crate) async fn gather(&mut self) -> Result<(), Error> {
        self.state = RTCIceGatheringState::Gathering;
        self.gather_host_candidates()?;
        self.gather_srflx_candidates().await?;
        self.gather_relay_candidates().await?;
        
        if self.gathering_clients.is_empty() && self.state != RTCIceGatheringState::Complete {
            self.state = RTCIceGatheringState::Complete;
            self.events.push_back(RTCIceGathererEvent::IceGatheringComplete);
        }
        Ok(())
    }

    fn gather_host_candidates(&mut self) -> Result<(), Error> {
        for local_addr in &self.local_addrs {
            let candidate = CandidateHostConfig {
                base_config: CandidateConfig {
                    network: "udp".to_owned(),
                    address: local_addr.ip().to_string(),
                    port: local_addr.port(),
                    component: 1,
                    ..Default::default()
                },
                ..Default::default()
            }.new_candidate_host()?;

            let candidate_init = RTCIceCandidate::from(&candidate).to_json()?;
            self.events.push_back(RTCIceGathererEvent::LocalIceCandidate(candidate_init));
        }
        Ok(())
    }

    async fn gather_srflx_candidates(&mut self) -> Result<(), Error> {
        for ice_server in &self.ice_servers {
            for url in &ice_server.urls {
                if !url.starts_with("stun:") { continue; }
                for local_addr in &self.local_addrs {
                    match RTCIceGatherer::gather_from_stun_server(*local_addr, url).await {
                        Ok(stun_client) => {
                            self.gathering_clients.insert(FourTuple {
                                local_addr: stun_client.local_addr(),
                                peer_addr: stun_client.peer_addr(),
                            });
                            self.stun_clients.push(stun_client);
                        }
                        Err(err) => error!("Failed to gather stun client: {}", err),
                    }
                }
            }
        }
        Ok(())
    }

    async fn gather_relay_candidates(&mut self) -> Result<(), Error> {
        for ice_server in &self.ice_servers {
            for url in &ice_server.urls {
                if !url.starts_with("turn:") && !url.starts_with("turns:") { continue; }
                for local_addr in &self.local_addrs {
                    match self.create_turn_client(*local_addr, ice_server, url).await {
                        Ok(mut turn_client) => {
                            info!("Initiating TURN allocation for {}", url);
                            turn_client.allocate()?;
                            self.gathering_clients.insert(FourTuple {
                                local_addr: turn_client.local_addr(),
                                peer_addr: turn_client.peer_addr(),
                            });
                            self.turn_clients.push(turn_client);
                        }
                        Err(err) => error!("Failed to create turn client: {}", err),
                    }
                }
            }
        }
        Ok(())
    }

    async fn create_turn_client(&self, local_addr: SocketAddr, server: &RTCIceServer, url: &str) -> Result<TurnClient, Error> {
        let server_addr_str = url.strip_prefix("turn:").or_else(|| url.strip_prefix("turns:")).unwrap_or(url);
        let server_addr_str = if server_addr_str.contains(':') { server_addr_str.to_string() } else { format!("{}:3478", server_addr_str) };
        
        let resolved_addrs = runtime::resolve_host(&server_addr_str).await?;
        let server_addr = resolved_addrs.into_iter().find(|addr| addr.is_ipv4() == local_addr.is_ipv4())
            .ok_or_else(|| Error::Other("Failed to resolve TURN server".into()))?;

        let config = TurnClientConfig {
            local_addr,
            turn_serv_addr: server_addr.to_string(),
            username: server.username.clone(),
            password: server.credential.clone(),
            ..TurnClientConfig::new(local_addr, server_addr, TransportProtocol::UDP)
        };
        
        TurnClient::new(config)
    }

    async fn gather_from_stun_server(local_addr: SocketAddr, stun_url: &str) -> Result<StunClient, Error> {
        let stun_addr_str = stun_url.strip_prefix("stun:").unwrap_or(stun_url);
        let stun_addr_str = if stun_addr_str.contains(':') { stun_addr_str.to_string() } else { format!("{}:3478", stun_addr_str) };
        
        let resolved_addrs = runtime::resolve_host(&stun_addr_str).await?;
        let stun_server_addr = resolved_addrs.into_iter().find(|addr| addr.is_ipv4() == local_addr.is_ipv4())
            .ok_or_else(|| Error::Other("Failed to resolve STUN server".into()))?;

        let mut stun_client = StunClientBuilder::new().build(local_addr, stun_server_addr, TransportProtocol::UDP)?;
        let mut msg = StunMessage::new();
        msg.build(&[Box::<TransactionId>::default(), Box::new(BINDING_REQUEST)])?;
        stun_client.handle_write(msg)?;
        Ok(stun_client)
    }
}

impl Protocol<TaggedBytesMut, (), ()> for RTCIceGatherer {
    type Rout = ();
    type Wout = TaggedBytesMut;
    type Eout = RTCIceGathererEvent;
    type Error = Error;
    type Time = Instant;

    fn handle_read(&mut self, msg: TaggedBytesMut) -> Result<(), Self::Error> {
        for stun_client in &mut self.stun_clients {
            if stun_client.peer_addr() == msg.transport.peer_addr && stun_client.local_addr() == msg.transport.local_addr {
                return stun_client.handle_read(msg);
            }
        }
        for turn_client in &mut self.turn_clients {
            if turn_client.peer_addr() == msg.transport.peer_addr && turn_client.local_addr() == msg.transport.local_addr {
                return turn_client.handle_read(msg);
            }
        }
        Ok(())
    }

    fn poll_read(&mut self) -> Option<Self::Rout> { None }
    fn handle_write(&mut self, _msg: ()) -> Result<(), Self::Error> { Ok(()) }

    fn poll_write(&mut self) -> Option<Self::Wout> {
        for stun_client in &mut self.stun_clients {
            while let Some(transmit) = stun_client.poll_write() {
                self.wouts.push_back(transmit);
            }
        }
        for turn_client in &mut self.turn_clients {
            while let Some(transmit) = turn_client.poll_write() {
                self.wouts.push_back(transmit);
            }
        }
        self.wouts.pop_front()
    }

    fn handle_event(&mut self, _evt: ()) -> Result<(), Self::Error> { Ok(()) }

    fn poll_event(&mut self) -> Option<Self::Eout> {
        // Process STUN events
        for stun_client in &mut self.stun_clients {
            let local_addr = stun_client.local_addr();
            let mut peer_addr = None;
            while let Some(event) = stun_client.poll_event() {
                peer_addr = Some(stun_client.peer_addr());
                if let StunEvent::Message(msg) = event {
                    let mut xor_addr = XorMappedAddress::default();
                    if let Ok(_) = xor_addr.get_from(&msg) {
                        let config = CandidateServerReflexiveConfig {
                            base_config: CandidateConfig {
                                network: "udp".to_owned(),
                                address: xor_addr.ip.to_string(),
                                port: xor_addr.port,
                                component: 1,
                                ..Default::default()
                            },
                            rel_addr: local_addr.ip().to_string(),
                            rel_port: local_addr.port(),
                            ..Default::default()
                        };
                        if let Ok(candidate) = config.new_candidate_server_reflexive() {
                            if let Ok(candidate_init) = RTCIceCandidate::from(&candidate).to_json() {
                                self.events.push_back(RTCIceGathererEvent::LocalIceCandidate(candidate_init));
                            }
                        }
                    }
                }
            }
            if let Some(pa) = peer_addr {
                self.gathering_clients.remove(&FourTuple { local_addr, peer_addr: pa });
            }
        }

        // Process TURN events
        for turn_client in &mut self.turn_clients {
            let local_addr = turn_client.local_addr();
            let server_addr = turn_client.peer_addr();
            while let Some(event) = turn_client.poll_event() {
                match event {
                    TurnEvent::AllocateResponse(_, relay_addr) => {
                        info!("TURN Allocation successful: relay={}", relay_addr);
                        let config = CandidateRelayConfig {
                            base_config: CandidateConfig {
                                network: "udp".to_owned(),
                                address: relay_addr.ip().to_string(),
                                port: relay_addr.port(),
                                component: 1,
                                ..Default::default()
                            },
                            rel_addr: local_addr.ip().to_string(),
                            rel_port: local_addr.port(),
                            ..Default::default()
                        };
                        if let Ok(candidate) = config.new_candidate_relay() {
                            if let Ok(candidate_init) = RTCIceCandidate::from(&candidate).to_json() {
                                self.events.push_back(RTCIceGathererEvent::LocalIceCandidate(candidate_init));
                            }
                        }
                        self.gathering_clients.remove(&FourTuple { local_addr, peer_addr: server_addr });
                    }
                    TurnEvent::AllocateError(_, _) => {
                        error!("TURN Allocation failed for {}", server_addr);
                        self.gathering_clients.remove(&FourTuple { local_addr, peer_addr: server_addr });
                    }
                    _ => {}
                }
            }
        }

        if self.gathering_clients.is_empty() && self.state == RTCIceGatheringState::Gathering {
            self.state = RTCIceGatheringState::Complete;
            self.events.push_back(RTCIceGathererEvent::IceGatheringComplete);
        }

        self.events.pop_front()
    }

    fn handle_timeout(&mut self, now: Self::Time) -> Result<(), Self::Error> {
        for stun_client in &mut self.stun_clients { stun_client.handle_timeout(now)?; }
        for turn_client in &mut self.turn_clients { turn_client.handle_timeout(now)?; }
        Ok(())
    }

    fn poll_timeout(&mut self) -> Option<Self::Time> {
        let mut eto: Option<Instant> = None;
        for stun_client in &mut self.stun_clients {
            if let Some(next) = stun_client.poll_timeout() {
                eto = Some(eto.map_or(next, |curr| std::cmp::min(curr, next)));
            }
        }
        for turn_client in &mut self.turn_clients {
            if let Some(next) = turn_client.poll_timeout() {
                eto = Some(eto.map_or(next, |curr| std::cmp::min(curr, next)));
            }
        }
        eto
    }

    fn close(&mut self) -> Result<(), Self::Error> {
        for mut stun_client in self.stun_clients.drain(..) { stun_client.close()?; }
        for mut turn_client in self.turn_clients.drain(..) { turn_client.close()?; }
        Ok(())
    }
}