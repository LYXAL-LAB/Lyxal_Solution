use crate::config::DynamicConfig;
use crate::error::Result;
use crate::provider::SyncProvider;
use crate::status::DrainReport;
use crate::status::{PeerContext, SyncStatus};
use std::collections::HashMap;
use std::sync::{Arc, Weak};

use lyxal_sync::protocol::LspMessage;
use std::time::Duration;

#[derive(Clone)]
pub struct SyncController {
	provider: Weak<SyncProvider>,
}

impl SyncController {
	/// Create a new controller for the given provider
	pub fn new(provider: &Arc<SyncProvider>) -> Self {
		Self {
			provider: Arc::downgrade(provider),
		}
	}

	/// Check if the provider is still alive
	pub fn is_alive(&self) -> bool {
		self.provider.strong_count() > 0
	}

	/// Get the current status of the sync service
	pub fn status(&self) -> Option<SyncStatus> {
		self.provider.upgrade().map(|p| p.status())
	}

	/// Get details of all connected peers (Registry Snapshot)
	pub async fn peers(&self) -> Option<HashMap<u128, PeerContext>> {
		if let Some(provider) = self.provider.upgrade() {
			Some(provider.peers_map().await)
		} else {
			None
		}
	}

	/// Update the dynamic configuration
	pub async fn update_config(&self, config: DynamicConfig) -> Result<()> {
		if let Some(provider) = self.provider.upgrade() {
			provider.update_config(config).await
		} else {
			Ok(())
		}
	}

	/// Force a drain of the sync service
	pub async fn force_drain(&self) -> Option<DrainReport> {
		if let Some(provider) = self.provider.upgrade() {
			Some(provider.drain(Duration::from_secs(30)).await)
		} else {
			None
		}
	}

	/// Force a snapshot for a specific peer
	/// This is an async action that returns immediately
	pub async fn force_snapshot(&self, peer_id: u128) -> Result<()> {
		if let Some(provider) = self.provider.upgrade() {
			provider.force_snapshot(peer_id).await
		} else {
			Ok(())
		}
	}

	// P23 Control Plane
	pub async fn broadcast(&self, msg: LspMessage) {
		if let Some(provider) = self.provider.upgrade() {
			provider.broadcast_control_message(msg).await;
		}
	}

	/// Send a control message to a specific peer
	pub async fn send_to(&self, peer_id: u128, msg: LspMessage) {
		if let Some(provider) = self.provider.upgrade() {
			provider.send_control_message(peer_id, msg).await;
		}
	}

	/// Update the current Raft leader knowledge
	pub async fn set_leader(&self, leader_id: Option<u128>) {
		if let Some(provider) = self.provider.upgrade() {
			provider.update_leader(leader_id).await;
		}
	}
}
