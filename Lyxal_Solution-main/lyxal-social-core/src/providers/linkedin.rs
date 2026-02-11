use crate::capabilities::Capabilities;
use crate::providers::Provider;
use crate::types::{ProviderAccountKey, ProviderKind};
use crate::error::SocialResult;

pub struct LinkedInProvider;

impl Provider for LinkedInProvider {
	fn kind(&self) -> ProviderKind {
		ProviderKind::LinkedIn
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

