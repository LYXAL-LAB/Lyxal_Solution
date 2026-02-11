use ed25519_dalek::Verifier;
use rand::rngs::OsRng; // Pour la crypto et nonce
use rand::RngCore; // Pour fill_bytes
use tokio::time::{timeout, Duration, Instant};

use crate::connection::LspConnection; // Explicit import
use crate::crypto::{generate_ephemeral, SessionCipher};
use crate::error::{NetError, Result};
use crate::identity::{self, NodeIdentity}; // Use the new Identity module
use crate::metrics::get_metrics;
use crate::provider::{CancellationToken, SyncProvider, TransferGuard};
use crate::status::{PeerContext, PeerHealth, PeerStatus};
use crate::store::SyncStore;
use crate::trust::TrustDecision;
use blake3;
use lyxal_sync::clock::{NodeId, VectorClock};
use lyxal_sync::protocol::{Capabilities, LspMessage};
use std::net::SocketAddr;
use std::sync::atomic::Ordering;
use std::sync::Arc;
use zstd;

// Statics moved to DynamicConfig in SyncProvider

#[derive(Debug, Clone, Copy, PartialEq, serde::Serialize)]
enum State {
	Handshaking,
	Idle,
	#[allow(dead_code)]
	Syncing,
	Disconnected,
}

pub struct SyncPeer {
	connection: LspConnection,
	state: State,
	addr: SocketAddr,

	// Mes infos
	local_node_id: NodeId,
	identity: Arc<NodeIdentity>,
	store: Arc<dyn SyncStore + Send + Sync>,
	provider: Arc<SyncProvider>,
	cancel: CancellationToken,

	// Ses infos (découvertes au Handshake)
	remote_node_id: Option<NodeId>,
	remote_capabilities: Option<Capabilities>,

	// P9.2: Per-peer Rate limiting
	last_offer_time: Option<Instant>,

	// P10.2: Per-peer Stats & Health
	last_seen: Instant,
	health: PeerHealth,
	watermark_lag: u64,
	trigger_rx: tokio::sync::mpsc::Receiver<()>,
	trigger_tx: tokio::sync::mpsc::Sender<()>,
	slot_guard: Option<crate::quotas::PeerSlotGuard>,
	connect_at: Instant,
}

impl SyncPeer {
	/// Crée un Peer avec une identité chargée.
	pub fn new(
		stream: tokio::net::TcpStream,
		addr: SocketAddr,
		local_node_id: NodeId,
		identity: Arc<NodeIdentity>,
		store: Arc<dyn SyncStore + Send + Sync>,
		provider: Arc<SyncProvider>,
		cancel: CancellationToken,
		trigger_rx: tokio::sync::mpsc::Receiver<()>,
		trigger_tx: tokio::sync::mpsc::Sender<()>,
	) -> Self {
		Self {
			connection: LspConnection::new(stream),
			addr,
			state: State::Handshaking,
			local_node_id,
			identity,
			store,
			provider,
			cancel,
			remote_node_id: None,
			remote_capabilities: None,
			last_offer_time: None,
			last_seen: Instant::now(),
			health: PeerHealth::Healthy,
			watermark_lag: 0,
			trigger_rx,
			trigger_tx,
			slot_guard: None,
			connect_at: Instant::now(),
		}
	}

	pub async fn run(&mut self) -> Result<()> {
		log::info!("Peer started, entering Handshake state.");

		let mut final_res = Ok(());

		while self.state != State::Disconnected {
			if self.cancel.is_cancelled() {
				log::info!("Peer task cancelled by provider.");
				self.state = State::Disconnected;
				break;
			}

			let res = self.step().await;
			if let Err(e) = res {
				log::error!("Peer step error: {:?}", e);
				self.state = State::Disconnected;
				final_res = Err(e);
			}
		}

		log::info!("Peer main loop terminated.");

		// Decr metrics
		let m = get_metrics();
		m.peer_count.fetch_sub(1, Ordering::Relaxed);
		match self.health {
			PeerHealth::Healthy => {
				m.healthy_peers.fetch_sub(1, Ordering::Relaxed);
			}
			PeerHealth::Lagging => {
				m.lagging_peers.fetch_sub(1, Ordering::Relaxed);
			}
			PeerHealth::Syncing => {
				m.syncing_peers.fetch_sub(1, Ordering::Relaxed);
			}
			PeerHealth::NeedsSnapshot => {
				m.needs_snapshot_peers.fetch_sub(1, Ordering::Relaxed);
			}
			_ => {}
		};

		// Unregister on exit
		if let Some(remote_id) = self.remote_node_id {
			log::info!("Unregistering peer {}", remote_id);
			let duration = self.connect_at.elapsed().as_millis() as u64;
			if let Some(obs) = &self.provider.observer {
				obs.on_peer_disconnected(
					self.provider.static_config().realm_id,
					remote_id,
					duration,
				);
			}
			self.provider.unregister_peer(remote_id).await;
		}

		final_res
	}

	async fn step(&mut self) -> Result<()> {
		match self.state {
			State::Handshaking => self.handle_handshake().await?,
			State::Idle => self.handle_idle().await?,
			State::Syncing => self.handle_syncing().await?,
			State::Disconnected => {}
		}
		Ok(())
	}

	async fn handle_handshake(&mut self) -> Result<()> {
		// P21: Enforce Max Peers Quota
		// We acquire the slot here and hold it for the duration of the connection.
		// It will be dropped automatically when SyncPeer is dropped (via struct field if we store it,
		// OR we can make it part of the function scope if run() holds it?
		// Wait, run() calls step(). If we acquire it here, it drops at end of invalid scope.
		// We must store it in self.

		let slot_guard = self.provider.try_acquire_peer_slot()?;
		self.slot_guard = Some(slot_guard);

		log::debug!("Starting Secure Handshake (Slot Acquired)...");

		let capabilities = Capabilities {
			supports_push: true,
			supports_snapshot: true,
			supports_compression_zstd: true,
			supports_delta_patch: true,
			max_chunk_bytes: 1024 * 1024,

			// P19: OS-Level Capabilities
			protocol_version: 1,
			os_version: "lyxal-os-0.1.0".to_string(),
			node_features: 0b0000_0001, // Feature 1: Core
			required_features: 0b0000_0000,
		};

		// 1. Prepare Local Crypto
		let my_nonce = {
			let mut n = vec![0u8; 32];
			OsRng.fill_bytes(&mut n);
			n
		};
		let my_ephemeral = generate_ephemeral(); // X25519 (Secret, Public)
		let my_pub_bytes = self.identity.keypair.verifying_key().to_bytes().to_vec(); // Ed25519

		let protocol_version: u32 = 1;

		// Capabilities serialization for signature
		let mut caps_bytes = Vec::new();
		caps_bytes.push(if capabilities.supports_push {
			1
		} else {
			0
		});
		caps_bytes.push(if capabilities.supports_snapshot {
			1
		} else {
			0
		});
		caps_bytes.push(if capabilities.supports_compression_zstd {
			1
		} else {
			0
		});
		caps_bytes.push(if capabilities.supports_delta_patch {
			1
		} else {
			0
		});
		caps_bytes.extend_from_slice(&capabilities.max_chunk_bytes.to_le_bytes());
		// P19 Hash Extension
		caps_bytes.extend_from_slice(&capabilities.protocol_version.to_le_bytes());
		caps_bytes.extend_from_slice(capabilities.os_version.as_bytes());
		caps_bytes.extend_from_slice(&capabilities.node_features.to_le_bytes());
		caps_bytes.extend_from_slice(&capabilities.required_features.to_le_bytes());
		let caps_hash = blake3::hash(&caps_bytes);

		// Sign payload: protocol_version(4) || node_id(16) || nonce(32) || caps_hash(32)
		let mut sign_payload = Vec::new();
		sign_payload.extend_from_slice(&protocol_version.to_le_bytes()); // u32 LE
		sign_payload.extend_from_slice(&self.local_node_id.to_le_bytes()); // u128 LE
		sign_payload.extend_from_slice(&my_nonce);
		sign_payload.extend_from_slice(caps_hash.as_bytes());

		let signature = self.identity.sign(&sign_payload).to_bytes().to_vec();

		// 2. Send HELLO
		let my_realm_id = self.provider.static_config().realm_id;
		let hello = LspMessage::Hello {
			protocol_version: 1,
			node_id: self.local_node_id,
			realm_id: my_realm_id,
			nonce: my_nonce.clone(),
			public_key: my_pub_bytes,
			ephemeral_key: my_ephemeral.1.to_vec(),
			signature,
			capabilities: capabilities.clone(),
		};
		self.connection.send(&hello).await?;

		// 3. Receive HELLO
		let msg = match timeout(Duration::from_secs(5), self.connection.recv()).await {
			Ok(Ok(m)) => m,
			Ok(Err(e)) => return Err(e),
			Err(_) => return Err(NetError::Timeout("Handshake timeout".into())),
		};

		if let LspMessage::Hello {
			node_id,
			realm_id: remote_realm_id,
			protocol_version: pv,
			nonce,
			public_key,
			ephemeral_key,
			signature,
			capabilities: caps,
		} = msg
		{
			// P16/P21: DoS Protection - Enforce strict length limits on vectors
			if nonce.len() != 32
				|| public_key.len() != 32
				|| ephemeral_key.len() != 32
				|| signature.len() != 64
				|| caps.os_version.len() > 128
			{
				log::error!("DoS Protection: Invalid field lengths in HELLO from {}", self.addr);
				return Err(NetError::HandshakeFailed);
			}

			// P20.4 Protocol Realm-Aware Validation
			if remote_realm_id != my_realm_id {
				log::error!(
					"Realm Violation: Peer {} belongs to realm {:x}, expected {:x}",
					self.addr,
					remote_realm_id,
					my_realm_id
				);
				// P20.7: Increment Metric
				get_metrics().realm_mismatch_rejects.fetch_add(1, Ordering::Relaxed);
				// Strict Isolation: Terminate connection immediately.
				return Err(NetError::HandshakeFailed);
			}
			log::debug!("Realm Match: {}", my_realm_id);
			// P16 Strict Validation

			// 1. Verify NodeID derivation
			let pubkey_obj =
				ed25519_dalek::VerifyingKey::from_bytes(&public_key.try_into().unwrap())
					.map_err(|_| NetError::HandshakeFailed)?;

			let derived = identity::derive_node_id(&pubkey_obj);
			if derived != node_id {
				log::error!(
					"SECURITY: Peer {} NodeID mismatch (asserted {:x}, derived {:x})",
					self.addr,
					node_id,
					derived
				);
				get_metrics().identity_mismatch_rejections.fetch_add(1, Ordering::Relaxed);
				return Err(NetError::HandshakeFailed);
			}

			// 2. Verify Signature
			let mut remote_caps_bytes = Vec::new();
			remote_caps_bytes.push(if caps.supports_push {
				1
			} else {
				0
			});
			remote_caps_bytes.push(if caps.supports_snapshot {
				1
			} else {
				0
			});
			remote_caps_bytes.push(if caps.supports_compression_zstd {
				1
			} else {
				0
			});
			remote_caps_bytes.push(if caps.supports_delta_patch {
				1
			} else {
				0
			});
			remote_caps_bytes.extend_from_slice(&caps.max_chunk_bytes.to_le_bytes());
			// P19 Hash Extension
			remote_caps_bytes.extend_from_slice(&caps.protocol_version.to_le_bytes());
			remote_caps_bytes.extend_from_slice(caps.os_version.as_bytes());
			remote_caps_bytes.extend_from_slice(&caps.node_features.to_le_bytes());
			remote_caps_bytes.extend_from_slice(&caps.required_features.to_le_bytes());
			let remote_caps_hash = blake3::hash(&remote_caps_bytes);

			let mut verify_payload = Vec::new();
			verify_payload.extend_from_slice(&pv.to_le_bytes());
			verify_payload.extend_from_slice(&node_id.to_le_bytes());
			verify_payload.extend_from_slice(&nonce);
			verify_payload.extend_from_slice(remote_caps_hash.as_bytes());

			// Verify signature (NodeIdentity over Context)
			// If signature vec len is wrong, from_bytes might fail if we checked len. Here we slice/try_into.
			let sig_arr: [u8; 64] =
				signature.as_slice().try_into().map_err(|_| NetError::HandshakeFailed)?;
			let sig = ed25519_dalek::Signature::from_bytes(&sig_arr);

			if let Err(_) = pubkey_obj.verify(&verify_payload, &sig) {
				log::error!("SECURITY: Invalid signature from peer {}", self.addr);
				get_metrics().identity_mismatch_rejections.fetch_add(1, Ordering::Relaxed);
				return Err(NetError::HandshakeFailed);
			}

			// Verify Trust Logic (P16)
			let trust_decision = self.provider.trust_store.check(node_id, &pubkey_obj);
			match trust_decision {
				TrustDecision::Allow => {
					log::info!("Peer {} trust approved.", self.addr);
				}
				TrustDecision::Deny(reason) => {
					log::error!(
						"Peer {} rejected by TrustStore (Realm {}): {}",
						self.addr,
						my_realm_id,
						reason
					);
					get_metrics().trust_rejections.fetch_add(1, Ordering::Relaxed);
					return Err(NetError::HandshakeFailed);
				}
			}
			// P19: Strict Capability & Version Negotiation
			if caps.protocol_version < 1 {
				log::error!(
					"Incompatible Protocol Version: {}. Required >= 1.",
					caps.protocol_version
				);
				return Err(NetError::HandshakeFailed);
			}
			if (caps.node_features & capabilities.required_features)
				!= capabilities.required_features
			{
				log::error!(
					"Peer missing required features! Peer: {:x}, Required: {:x}",
					caps.node_features,
					capabilities.required_features
				);
				return Err(NetError::HandshakeFailed);
			}
			log::info!(
				"Capabilities Negotiated: OS={}, Ver={}",
				caps.os_version,
				caps.protocol_version
			);

			self.remote_node_id = Some(node_id);
			self.remote_capabilities = Some(caps.clone());

			// Derive session key
			// Start Session
			// `my_ephemeral` is StaticSecret (x25519_dalek).
			let remote_ephemeral_bytes: [u8; 32] = ephemeral_key
				.try_into()
				.map_err(|_| NetError::Protocol("Invalid Ephemeral len".into()))?;
			let remote_ephemeral_obj = x25519_dalek::PublicKey::from(remote_ephemeral_bytes);

			let shared_secret = my_ephemeral.0.diffie_hellman(&remote_ephemeral_obj);

			// Derive session salt (P20.7 Mutual Determinism)
			let mut nonces = vec![my_nonce.clone(), nonce.clone()];
			nonces.sort();
			let mut combined_salt = Vec::new();
			combined_salt.extend_from_slice(&nonces[0]);
			combined_salt.extend_from_slice(&nonces[1]);
			let final_salt = blake3::hash(&combined_salt);

			// Derive session key
			let session_cipher =
				SessionCipher::new(shared_secret.as_bytes(), final_salt.as_bytes());
			self.connection.set_cipher(session_cipher);

			log::info!("Handshake success with node {}", node_id);

			let m = get_metrics();
			m.healthy_peers.fetch_add(1, Ordering::Relaxed);

			self.state = State::Idle;

			// P14: Register Peer
			let ctx = PeerContext {
				addr: self.addr,
				status: PeerStatus {
					health: self.health,
					lag: self.watermark_lag,
					rtt_ms: 0, // Mock RTT for now
				},
				trigger_tx: self.trigger_tx.clone(),
			};
			self.provider.register_peer(node_id, ctx).await;
			log::info!("Registered peer {} in registry", node_id);

			if let Some(obs) = &self.provider.observer {
				obs.on_peer_connected(self.provider.static_config().realm_id, node_id);
			}

			Ok(())
		} else {
			log::error!("Expected HELLO, got {:?}", msg);
			self.state = State::Disconnected;
			Err(NetError::HandshakeFailed)
		}
	}

	async fn handle_idle(&mut self) -> Result<()> {
		log::debug!("Peer Entering Idle state.");
		let m = get_metrics();
		m.healthy_peers.fetch_add(1, Ordering::Relaxed);

		let mut interval = tokio::time::interval(Duration::from_secs(5));

		loop {
			let idle_timeout = self.provider.dynamic_cfg().read().await.idle_timeout;
			tokio::select! {
				_ = self.cancel.cancelled() => {
					self.state = State::Disconnected;
					return Ok(());
				}
				_ = interval.tick() => {
					let clock = self.store.get_clock();
					let hints = self.provider.get_gossip_hints().await;
					let summary = LspMessage::StateSummary {
						stream_id: 0u128,
						my_clock: clock.clocks,
						hints,
					};
					self.connection.send(&summary).await?;

					// P14: Update Stats
					if let Some(id) = self.remote_node_id {
						let status = PeerStatus {
							health: self.health,
							lag: self.watermark_lag,
							rtt_ms: 10, // Mock RTT until P14.3
						};
						self.provider.update_peer_status(id, status).await;
					}
				}
				_ = self.trigger_rx.recv() => {
					log::debug!("Manual sync trigger for peer {}", self.addr);
					let _ = self.trigger_sync().await;
				}
				res = timeout(idle_timeout, self.connection.recv()) => {
					self.last_seen = Instant::now();
					match res {
						Ok(Ok(msg)) => self.process_message(msg).await?,
						Ok(Err(NetError::ConnectionClosed)) => {
							log::info!("Connection closed by remote.");
							self.state = State::Disconnected;
							return Ok(());
						}
						Ok(Err(e)) => {
							log::error!("Error in idle: {}", e);
							self.state = State::Disconnected;
							return Err(e);
						}
						Err(_) => {
							 log::warn!("Idle Timeout reached");
							 return Err(NetError::Protocol("Idle Timeout".into()));
						}
					}
				}
			}
		}
	}

	async fn process_message(&mut self, msg: LspMessage) -> Result<()> {
		match msg {
			LspMessage::StateSummary {
				my_clock: remote_clock_map,
				hints,
				..
			} => {
				log::debug!(
					"Received Summary from Node {} (with {} hints)",
					self.remote_node_id.unwrap_or(0u128),
					hints.len()
				);

				// P20.8 / P17.4: Add hints to discovery
				if !hints.is_empty() {
					self.provider.add_discovery_hints(hints).await;
				}

				let my_clock = self.store.get_clock();
				let mut ranges = Vec::new();
				let mut remote_is_ahead_too_far = false;

				let cfg = self.provider.dynamic_cfg().read().await;
				let log_sync_threshold = cfg.delta_threshold;

				// 1. Check if REMOTE is AHEAD (Pull Logic)
				let mut total_lag = 0;
				let m = get_metrics();
				for (node_id, remote_seq) in &remote_clock_map {
					let local_seq = my_clock.get(node_id);
					if *remote_seq > local_seq {
						let diff = *remote_seq - local_seq;
						total_lag += diff;
						if diff > log_sync_threshold {
							remote_is_ahead_too_far = true;
							if self.health != PeerHealth::NeedsSnapshot {
								self.health = PeerHealth::NeedsSnapshot;
								m.needs_snapshot_peers.fetch_add(1, Ordering::Relaxed);
							}
							log::info!(
								"Remote Ahead by {} > Threshold. Waiting for Snapshot.",
								diff
							);
							// Do not request delta.
						} else {
							// We need [local_seq + 1 .. remote_seq]
							ranges.push((*node_id, local_seq, *remote_seq));
						}
					}
				}

				self.watermark_lag = total_lag;
				if self.health != PeerHealth::NeedsSnapshot && self.health != PeerHealth::Syncing {
					let new_health = if total_lag > 0 {
						PeerHealth::Lagging
					} else {
						PeerHealth::Healthy
					};
					if new_health != self.health {
						match self.health {
							PeerHealth::Healthy => m.healthy_peers.fetch_sub(1, Ordering::Relaxed),
							PeerHealth::Lagging => m.lagging_peers.fetch_sub(1, Ordering::Relaxed),
							_ => 0,
						};
						match new_health {
							PeerHealth::Healthy => m.healthy_peers.fetch_add(1, Ordering::Relaxed),
							PeerHealth::Lagging => m.lagging_peers.fetch_add(1, Ordering::Relaxed),
							_ => 0,
						};
						self.health = new_health;
					}
				}

				if !remote_is_ahead_too_far && !ranges.is_empty() {
					log::info!("Detected lag, requesting delta for {} ranges", ranges.len());
					let req = LspMessage::RequestDelta {
						stream_id: 0u128,
						ranges,
					};
					self.connection.send(&req).await?;
				}

				// 2. Check if LOCAL is AHEAD (Push Logic / Offer Snapshot)
				let mut offer_snapshot = false;
				for (node_id, local_seq) in my_clock.clocks.iter() {
					let remote_seq = remote_clock_map.get(node_id).unwrap_or(&0);
					if *local_seq > *remote_seq {
						let diff = *local_seq - *remote_seq;
						if diff > log_sync_threshold {
							offer_snapshot = true;
							log::info!("Local Ahead by {} > Threshold. Offering Snapshot.", diff);
							break;
						}
					}
				}

				if offer_snapshot {
					// P9.2: Per-peer rate limit for offering
					let cfg = self.provider.dynamic_cfg().read().await;
					let now = Instant::now();
					let should_offer = match self.last_offer_time {
						Some(t) => now.duration_since(t) > cfg.snapshot_rate_peer,
						None => true,
					};

					if should_offer {
						self.last_offer_time = Some(now);
						let m = get_metrics();
						m.snapshots_generated.fetch_add(1, Ordering::Relaxed);

						let (header, _) = self.store.get_snapshot().await?;
						let offer = LspMessage::SnapshotOffer {
							header,
						};
						self.connection.send(&offer).await?;
					} else {
						log::debug!(
							"Skipping SnapshotOffer to Node {} (Rate-limit peer)",
							self.remote_node_id.unwrap_or(0)
						);
					}
				}
			}
			LspMessage::SnapshotOffer {
				header,
			} => {
				log::info!("Received Snapshot Offer. Size: {}", header.size_bytes);
				let cfg = self.provider.dynamic_cfg().read().await;
				if header.size_bytes > cfg.max_snapshot_bytes {
					log::error!("Snapshot too large: {}", header.size_bytes);
					return Ok(()); // Reject (or send NACK in future)
				}

				// Check clocks: header.covers_clock must provide newer state than my_clock
				let my_clock = self.store.get_clock();
				let mut useful = false;
				for (nid, seq) in &header.covers_clock {
					if *seq > my_clock.get(nid) {
						useful = true;
						break;
					}
				}

				if useful {
					log::info!("Accepting Snapshot {:?}", header.snapshot_id);
					// Prepare store
					self.store.apply_snapshot_begin(header.clone()).await?;

					let req = LspMessage::RequestSnapshot {
						snapshot_id: header.snapshot_id,
					};
					self.connection.send(&req).await?;
				} else {
					log::info!("Ignoring Useless Snapshot");
				}
			}
			LspMessage::RequestSnapshot {
				snapshot_id,
			} => {
				log::info!("Streaming Snapshot {:?}", snapshot_id);
				let _guard = TransferGuard::new(self.provider.active_transfers().clone());
				let (_header, data) = self.store.get_snapshot().await?;

				// Chunking logic
				let chunk_size = 64 * 1024; // 64KB
				let mut offset = 0;
				let use_zstd = self
					.remote_capabilities
					.as_ref()
					.map_or(false, |c| c.supports_compression_zstd);

				let mut chunk_hashes = Vec::new();

				while offset < data.len() {
					let end = std::cmp::min(offset + chunk_size, data.len());
					let raw_data = data[offset..end].to_vec();
					let raw_len = raw_data.len() as u32;

					// Hash raw data
					let hash = blake3::hash(&raw_data);
					let chunk_hash: [u8; 32] = hash.into();
					chunk_hashes.push(chunk_hash);

					let (codec, compressed_data) = if use_zstd {
						let compressed = zstd::encode_all(&raw_data[..], 3)
							.map_err(|e| NetError::Protocol(format!("Zstd Error: {}", e)))?;
						(1u8, compressed)
					} else {
						(0u8, raw_data)
					};

					let compressed_len = compressed_data.len() as u32;
					let is_last = end == data.len();

					let msg = LspMessage::SnapshotChunk {
						snapshot_id: snapshot_id.clone(),
						offset: offset as u64,
						data: compressed_data,
						is_last,
						codec,
						raw_len,
						compressed_len,
						chunk_hash,
					};

					let m = get_metrics();
					m.snapshot_raw_bytes.fetch_add(raw_len as u64, Ordering::Relaxed);
					m.snapshot_compressed_bytes.fetch_add(compressed_len as u64, Ordering::Relaxed);

					self.connection.send(&msg).await?;
					offset = end;
				}

				// root_hash validation (optional but good to log)
				let mut root_hasher = blake3::Hasher::new();
				for h in chunk_hashes {
					root_hasher.update(&h);
				}
				log::info!("Snapshot Sent. Root Hash: {}", root_hasher.finalize().to_hex());
			}
			LspMessage::SnapshotChunk {
				snapshot_id,
				offset,
				data,
				is_last,
				codec,
				raw_len,
				compressed_len: _,
				chunk_hash,
			} => {
				// 1. Decompress if needed
				let raw_data = if codec == 1 {
					zstd::decode_all(&data[..])
						.map_err(|e| NetError::Protocol(format!("Zstd decode error: {}", e)))?
				} else {
					data
				};

				// 2. Verify hash
				let actual_hash: [u8; 32] = blake3::hash(&raw_data).into();
				if actual_hash != chunk_hash {
					log::error!("Snapshot Chunk Hash Mismatch! Offset: {}", offset);
					return Err(NetError::Protocol(
						"Snapshot chunk corruption (hash mismatch)".into(),
					));
				}

				// 3. Length checks
				if raw_data.len() != raw_len as usize {
					return Err(NetError::Protocol("Snapshot chunk length mismatch".into()));
				}

				self.store.apply_snapshot_chunk(&snapshot_id, offset, raw_data).await?;

				if is_last {
					self.store.apply_snapshot_commit(&snapshot_id).await?;
					log::info!("Snapshot Committed!");
				}
			}
			LspMessage::RequestDelta {
				ranges,
				..
			} => {
				log::info!("Received RequestDelta for {} ranges", ranges.len());
				let _guard = TransferGuard::new(self.provider.active_transfers().clone());

				let mut requester_clock = VectorClock::new(0u128); // dummy
				for (nid, start, _) in ranges {
					requester_clock.update(nid, start);
				}

				let cfg = self.provider.dynamic_cfg().read().await;
				let items =
					self.store.get_delta(&requester_clock, cfg.max_delta_items as usize).await?;
				if !items.is_empty() {
					log::info!("Sending {} delta items", items.len());
					let chunk = LspMessage::DeltaChunk {
						items: items.clone(),
						next_cursor: None,
					};
					self.connection.send(&chunk).await?;

					// P26 hook: Estimate size
					let mut total_bytes = 0;
					for item in &items {
						total_bytes += (item.envelope.payload.len() + 128) as u64; // Envelope payload + Header overhead
					}
					self.provider.on_delta_sent(total_bytes);
				}
			}
			LspMessage::DeltaChunk {
				items,
				..
			} => {
				// Apply ops
				self.store.apply_delta(items).await?;
				log::info!("Applied Delta Chunk");
			}
			LspMessage::Heartbeat {
				..
			} => {
				log::trace!("Received Heartbeat from {}", self.remote_node_id.unwrap_or(0));
				self.provider.notify_control(msg).await;
			}
			LspMessage::Raft {
				from,
				message,
			} => {
				log::debug!("Received Raft message from {}", from);
				self.provider
					.notify_control(LspMessage::Raft {
						from,
						message,
					})
					.await;
			}
			_ => {}
		}
		Ok(())
	}

	async fn handle_syncing(&mut self) -> Result<()> {
		log::info!("Syncing with Node {}...", self.remote_node_id.unwrap_or(0));
		let m = get_metrics();
		m.syncing_peers.fetch_add(1, Ordering::Relaxed);
		self.health = PeerHealth::Syncing;
		loop {
			let sync_timeout = self.provider.dynamic_cfg().read().await.sync_timeout;
			let msg = tokio::select! {
				_ = self.cancel.cancelled() => {
					self.state = State::Disconnected;
					return Ok(());
				}
				res = timeout(sync_timeout, self.connection.recv()) => {
					res.map_err(|_| NetError::Protocol("Syncing Timeout".into()))??
				}
			};

			self.last_seen = Instant::now();
			self.process_message(msg).await?;
			if let State::Idle = self.state {
				m.syncing_peers.fetch_sub(1, Ordering::Relaxed);
				return Ok(());
			}
			if let State::Disconnected = self.state {
				m.syncing_peers.fetch_sub(1, Ordering::Relaxed);
				return Ok(());
			}
		}
	}

	async fn trigger_sync(&mut self) -> Result<()> {
		let my_clock = self.store.get_clock();
		let msg = LspMessage::StateSummary {
			stream_id: 0u128,
			my_clock: my_clock.clocks.clone(),
			hints: Vec::new(), // Explicit trigger doesn't need to carry hints usually, or we could add them
		};
		self.connection.send(&msg).await?;
		Ok(())
	}
}
