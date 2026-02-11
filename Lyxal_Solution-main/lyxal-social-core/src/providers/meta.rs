use crate::capabilities::Capabilities;
use crate::providers::Provider;
use crate::types::{ProviderAccountKey, ProviderKind};
use crate::error::SocialResult;

pub struct MetaProvider;

impl Provider for MetaProvider {
	fn kind(&self) -> ProviderKind {
		ProviderKind::Meta
	}

	fn capabilities(&self, _account: &ProviderAccountKey) -> SocialResult<Capabilities> {
		Ok(Capabilities {
			publish: true,
			messages: true,
			comments: true,
			stats: true,
			scheduling: true,
		})
	}
}

