use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use crate::error::{SocialError, SocialErrorCode, SocialResult};
use crate::types::{ProviderKind, SocialAction};

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct SecretKey {
	pub provider: ProviderKind,
	pub logical_account: String,
	pub label: String,
}

impl SecretKey {
	pub fn new(provider: ProviderKind, logical_account: impl Into<String>, label: impl Into<String>) -> Self {
		Self {
			provider,
			logical_account: logical_account.into(),
			label: label.into(),
		}
	}
}

pub trait SecretStore: Send + Sync {
	fn put(&self, key: SecretKey, value: String) -> SocialResult<()>;
	fn get(&self, key: &SecretKey) -> SocialResult<Option<String>>;
	fn delete(&self, key: &SecretKey) -> SocialResult<()>;
}

#[derive(Debug, Default, Clone)]
pub struct InMemorySecretStore {
	data: Arc<Mutex<HashMap<SecretKey, String>>>,
}

impl SecretStore for InMemorySecretStore {
	fn put(&self, key: SecretKey, value: String) -> SocialResult<()> {
		let mut guard = self.data.lock().map_err(|_| {
			SocialError::new(
				SocialErrorCode::SOCIAL_INTERNAL_ERROR,
				Some(key.provider),
				SocialAction::Connect,
				"mutex empoisonné",
			)
		})?;
		guard.insert(key, value);
		Ok(())
	}

	fn get(&self, key: &SecretKey) -> SocialResult<Option<String>> {
		let guard = self.data.lock().map_err(|_| {
			SocialError::new(
				SocialErrorCode::SOCIAL_INTERNAL_ERROR,
				Some(key.provider),
				SocialAction::Connect,
				"mutex empoisonné",
			)
		})?;
		Ok(guard.get(key).cloned())
	}

	fn delete(&self, key: &SecretKey) -> SocialResult<()> {
		let mut guard = self.data.lock().map_err(|_| {
			SocialError::new(
				SocialErrorCode::SOCIAL_INTERNAL_ERROR,
				Some(key.provider),
				SocialAction::Connect,
				"mutex empoisonné",
			)
		})?;
		guard.remove(key);
		Ok(())
	}
}

