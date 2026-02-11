use crate::types::{StoredAnalytics, StorageMode};
use gloo_storage::{LocalStorage, Storage};

/// Storage handler for analytics data
#[derive(Debug, Clone)]
pub struct AnalyticsStorage {
    storage_key: String,
    storage_mode: StorageMode,
}

impl AnalyticsStorage {
    /// Create a new storage handler
    pub fn new(storage_key: String, storage_mode: StorageMode) -> Self {
        Self {
            storage_key,
            storage_mode,
        }
    }

    /// Load analytics from storage
    pub fn load(&self) -> Option<StoredAnalytics> {
        match self.storage_mode {
            StorageMode::MemoryOnly => None,
            StorageMode::LocalStorage | StorageMode::Hybrid => {
                self.load_from_local_storage()
            }
        }
    }

    /// Save analytics to storage
    pub fn save(&self, analytics: &StoredAnalytics) -> Result<(), StorageError> {
        match self.storage_mode {
            StorageMode::MemoryOnly => Ok(()),
            StorageMode::LocalStorage | StorageMode::Hybrid => {
                self.save_to_local_storage(analytics)
            }
        }
    }

    /// Clear analytics from storage
    pub fn clear(&self) -> Result<(), StorageError> {
        match self.storage_mode {
            StorageMode::MemoryOnly => Ok(()),
            StorageMode::LocalStorage | StorageMode::Hybrid => {
                self.clear_local_storage()
            }
        }
    }

    /// Load from localStorage
    fn load_from_local_storage(&self) -> Option<StoredAnalytics> {
        LocalStorage::get::<StoredAnalytics>(&self.storage_key).ok()
    }

    /// Save to localStorage
    fn save_to_local_storage(&self, analytics: &StoredAnalytics) -> Result<(), StorageError> {
        LocalStorage::set(&self.storage_key, analytics)
            .map_err(|e| StorageError::SaveError(e.to_string()))
    }

    /// Clear localStorage
    fn clear_local_storage(&self) -> Result<(), StorageError> {
        LocalStorage::delete(&self.storage_key);
        Ok(())
    }

    /// Export analytics as JSON string
    pub fn export_json(&self, analytics: &StoredAnalytics) -> Result<String, StorageError> {
        serde_json::to_string_pretty(analytics)
            .map_err(|e: serde_json::Error| StorageError::SerializationError(e.to_string()))
    }

    /// Import analytics from JSON string
    pub fn import_json(&self, json: &str) -> Result<StoredAnalytics, StorageError> {
        serde_json::from_str(json)
            .map_err(|e: serde_json::Error| StorageError::DeserializationError(e.to_string()))
    }
}

/// Errors that can occur during storage operations
#[derive(Debug, Clone, PartialEq)]
pub enum StorageError {
    /// Error saving to storage
    SaveError(String),
    /// Error loading from storage
    LoadError(String),
    /// Error serializing data
    SerializationError(String),
    /// Error deserializing data
    DeserializationError(String),
    /// Storage quota exceeded
    QuotaExceeded,
    /// Storage not available
    NotAvailable,
}

impl std::fmt::Display for StorageError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            StorageError::SaveError(msg) => write!(f, "Failed to save: {}", msg),
            StorageError::LoadError(msg) => write!(f, "Failed to load: {}", msg),
            StorageError::SerializationError(msg) => {
                write!(f, "Failed to serialize: {}", msg)
            }
            StorageError::DeserializationError(msg) => {
                write!(f, "Failed to deserialize: {}", msg)
            }
            StorageError::QuotaExceeded => write!(f, "Storage quota exceeded"),
            StorageError::NotAvailable => write!(f, "Storage not available"),
        }
    }
}

/// Check if localStorage is available
pub fn is_local_storage_available() -> bool {
    // Try to access localStorage
    if let Some(window) = web_sys::window() {
        if let Ok(Some(_storage)) = window.local_storage() {
            return true;
        }
    }
    false
}

/// Get the estimated size of analytics data in bytes
pub fn estimate_storage_size(analytics: &StoredAnalytics) -> usize {
    serde_json::to_string(analytics)
        .map(|s: String| s.len())
        .unwrap_or(0)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_storage_mode_default() {
        let mode = StorageMode::default();
        assert_eq!(mode, StorageMode::MemoryOnly);
    }
}
