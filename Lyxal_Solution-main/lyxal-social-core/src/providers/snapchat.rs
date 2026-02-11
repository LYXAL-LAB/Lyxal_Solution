use crate::capabilities::Capabilities;
use crate::providers::Provider;
use crate::types::{ProviderAccountKey, ProviderKind};
use crate::error::SocialResult;

pub struct SnapchatProvider;

impl Provider for SnapchatProvider {
	fn kind(&self) -> ProviderKind {
		ProviderKind::Snapchat
	}

	fn capabilities(&self, _account: &ProviderAccountKey) -> SocialResult<Capabilities> {
		Ok(Capabilities {
			publish: true,
			messages: false,
			comments: false,
			stats: true,
			scheduling: false,
		})
	}
}


