use crate::capabilities::Capabilities;
use crate::error::SocialResult;
use crate::providers::Provider;
use crate::types::{ProviderAccountKey, ProviderKind};

pub struct GoogleBusinessProvider;

impl Provider for GoogleBusinessProvider {
	fn kind(&self) -> ProviderKind {
		ProviderKind::GoogleBusiness
	}

	fn capabilities(&self, _account: &ProviderAccountKey) -> SocialResult<Capabilities> {
		Ok(Capabilities {
			publish: true,
			messages: false,
			comments: true,
			stats: true,
			scheduling: false,
		})
	}
}


