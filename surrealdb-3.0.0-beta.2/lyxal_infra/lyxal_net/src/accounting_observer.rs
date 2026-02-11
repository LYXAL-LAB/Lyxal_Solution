pub trait AccountingObserver: Send + Sync {
    fn on_delta_sent(&self, realm_id: u128, bytes: u64);
    fn on_snapshot_sent(&self, realm_id: u128, bytes: u64);
    fn on_peer_connected(&self, realm_id: u128, peer_id: u128);
    fn on_peer_disconnected(&self, realm_id: u128, peer_id: u128, connected_ms: u64);
}
