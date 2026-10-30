//! Immutable snapshots. Host publication and durable registry restoration are explicit.
use crate::{CryptoError, EncryptionKey, KeyId};
use std::{collections::HashMap, fmt, sync::Arc};
use subtle::ConstantTimeEq;
/// Maximum number of IDs, including irrevocable tombstones.
pub const MAX_KEY_IDS: usize = 64;
/// Allowed use when inserting material into a builder.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KeyUse {
    /// The unique key permitted to seal new envelopes.
    Active,
    /// Historical material permitted only to open envelopes.
    DecryptOnly,
}
/// Non-secret lifecycle state of one ID.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KeyState {
    /// The unique key permitted to seal new envelopes.
    Active,
    /// Historical material permitted only to open envelopes.
    DecryptOnly,
    /// A retained tombstone with no key material or cryptographic permission.
    Revoked,
}
#[derive(Clone)]
struct Entry {
    state: KeyState,
    key: Option<Arc<EncryptionKey>>,
}
/// Coherent identity/material pair. No raw key export.
pub struct ResolvedKey {
    pub(crate) id: KeyId,
    pub(crate) key: Arc<EncryptionKey>,
}
impl ResolvedKey {
    /// Explicit pairing for a trusted provider, checked on insertion into a builder.
    pub fn new(id: KeyId, key: Arc<EncryptionKey>) -> Self {
        Self { id, key }
    }
    /// Non-secret identity, not a new nonce budget.
    pub fn id(&self) -> &KeyId {
        &self.id
    }
}
impl fmt::Debug for ResolvedKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("ResolvedKey")
            .field("id", &self.id)
            .field("key", &"[REDACTED]")
            .finish()
    }
}
/// Mutable construction only; built snapshots never change.
#[derive(Default)]
pub struct KeyRingBuilder {
    entries: HashMap<KeyId, Entry>,
}
impl KeyRingBuilder {
    /// Start empty; build requires exactly one active key.
    pub fn new() -> Self {
        Self::default()
    }
    /// Share the existing material and preserve ALL tombstones.
    pub fn from_snapshot(snapshot: &KeyRing) -> Self {
        Self {
            entries: snapshot.entries.clone(),
        }
    }
    fn insert_entry(&mut self, id: KeyId, entry: Entry) -> Result<(), CryptoError> {
        if self.entries.contains_key(&id) {
            return Err(CryptoError::DuplicateKeyId);
        }
        if self.entries.len() >= MAX_KEY_IDS {
            return Err(CryptoError::KeyStoreUnavailable);
        }
        if entry.state == KeyState::Active
            && self.entries.values().any(|e| e.state == KeyState::Active)
        {
            return Err(CryptoError::MultipleActiveKeys);
        }
        self.entries
            .try_reserve(1)
            .map_err(|_| CryptoError::AllocationFailed)?;
        self.entries.insert(id, entry);
        Ok(())
    }
    /// Insert a new identity. Duplicate IDs never replace any entry, even for equal bytes.
    pub fn insert(
        &mut self,
        id: KeyId,
        key: EncryptionKey,
        use_: KeyUse,
    ) -> Result<(), CryptoError> {
        self.insert_resolved(ResolvedKey::new(id, Arc::new(key)), use_)
    }
    /// Transfer a provider's coherent pair without copying material.
    pub fn insert_resolved(&mut self, key: ResolvedKey, use_: KeyUse) -> Result<(), CryptoError> {
        self.insert_entry(
            key.id,
            Entry {
                state: match use_ {
                    KeyUse::Active => KeyState::Active,
                    KeyUse::DecryptOnly => KeyState::DecryptOnly,
                },
                key: Some(key.key),
            },
        )
    }
    /// Restore a trusted host-registry tombstone WITHOUT importing a destroyed key.
    /// Does not persist the registry; duplicates and capacity errors leave this builder unchanged.
    pub fn insert_revoked(&mut self, id: KeyId) -> Result<(), CryptoError> {
        self.insert_entry(
            id,
            Entry {
                state: KeyState::Revoked,
                key: None,
            },
        )
    }
    /// Select a known, non-revoked key and demote the previous active key.
    /// Reactivation never resets any host-maintained budget for its material.
    pub fn activate(&mut self, id: &KeyId) -> Result<(), CryptoError> {
        let target = self.entries.get(id).ok_or(CryptoError::KeyUnavailable)?;
        if target.state == KeyState::Revoked {
            return Err(CryptoError::KeyRevoked);
        }
        for (entry_id, entry) in &mut self.entries {
            if entry_id == id {
                entry.state = KeyState::Active;
            } else if entry.state == KeyState::Active {
                entry.state = KeyState::DecryptOnly;
            }
        }
        Ok(())
    }
    /// Revoke a non-active entry, keeping its ID forever within this lineage.
    pub fn revoke(&mut self, id: &KeyId) -> Result<(), CryptoError> {
        let entry = self
            .entries
            .get_mut(id)
            .ok_or(CryptoError::KeyUnavailable)?;
        if entry.state == KeyState::Active {
            return Err(CryptoError::ActiveKeyRevocation);
        }
        entry.state = KeyState::Revoked;
        entry.key = None;
        Ok(())
    }
    /// Consume the builder only when exactly one active and all invariants hold.
    pub fn build(self) -> Result<KeyRing, CryptoError> {
        let mut active = None;
        for (id, entry) in &self.entries {
            if (entry.state == KeyState::Revoked) != entry.key.is_none() {
                return Err(CryptoError::InvalidSnapshotTransition);
            }
            if entry.state == KeyState::Active {
                if active.is_some() {
                    return Err(CryptoError::MultipleActiveKeys);
                }
                active = Some(id.clone());
            }
        }
        Ok(KeyRing {
            active: active.ok_or(CryptoError::MissingActiveKey)?,
            entries: self.entries,
        })
    }
}
/// Validated immutable snapshot. Old Arcs are not remotely revoked by a new snapshot.
pub struct KeyRing {
    active: KeyId,
    entries: HashMap<KeyId, Entry>,
}
impl KeyRing {
    /// Read the active ID for host admission/monitoring, not a count of invocations.
    pub fn active_id(&self) -> &KeyId {
        &self.active
    }
    /// Inspect only non-secret lifecycle metadata.
    pub fn state(&self, id: &KeyId) -> Option<KeyState> {
        self.entries.get(id).map(|e| e.state)
    }
    pub(crate) fn resolve(&self, id: &KeyId) -> Result<Arc<EncryptionKey>, CryptoError> {
        let entry = self.entries.get(id).ok_or(CryptoError::KeyUnavailable)?;
        if entry.state == KeyState::Revoked {
            return Err(CryptoError::KeyRevoked);
        }
        entry
            .key
            .clone()
            .ok_or(CryptoError::InvalidSnapshotTransition)
    }
    pub(crate) fn active(&self) -> Result<ResolvedKey, CryptoError> {
        Ok(ResolvedKey::new(
            self.active.clone(),
            self.resolve(&self.active)?,
        ))
    }
    /// Host MUST invoke this under its publication lock against the current snapshot.
    /// Reject lost IDs/tombstones, resurrected keys, and changed material under an existing ID.
    pub fn validate_successor(&self, next: &Self) -> Result<(), CryptoError> {
        for (id, old) in &self.entries {
            let new = next
                .entries
                .get(id)
                .ok_or(CryptoError::InvalidSnapshotTransition)?;
            if old.state == KeyState::Revoked && new.state != KeyState::Revoked {
                return Err(CryptoError::InvalidSnapshotTransition);
            }
            if let (Some(a), Some(b)) = (&old.key, &new.key) {
                if !bool::from(a.expose().ct_eq(b.expose())) {
                    return Err(CryptoError::KeySubstitution);
                }
            }
        }
        Ok(())
    }
}
impl fmt::Debug for KeyRing {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("KeyRing")
            .field("active", &self.active)
            .field("ids", &self.entries.len())
            .finish()
    }
}
/// Capture ONE validated snapshot; the host may implement atomic publication here.
pub trait KeyResolver: Send + Sync {
    /// Return a stable snapshot for the complete cryptographic operation.
    fn snapshot(&self) -> Result<Arc<KeyRing>, CryptoError>;
}
impl<T: KeyResolver + ?Sized> KeyResolver for Arc<T> {
    fn snapshot(&self) -> Result<Arc<KeyRing>, CryptoError> {
        (**self).snapshot()
    }
}
/// Resolver for a fixed snapshot with no hidden IO/reloading.
pub struct StaticKeyResolver {
    keys: Arc<KeyRing>,
}
impl StaticKeyResolver {
    /// Share a snapshot. Changing files/environment afterward does not change this resolver.
    pub fn new(keys: Arc<KeyRing>) -> Self {
        Self { keys }
    }
}
impl KeyResolver for StaticKeyResolver {
    fn snapshot(&self) -> Result<Arc<KeyRing>, CryptoError> {
        Ok(Arc::clone(&self.keys))
    }
}
