use crate::capabilities::Capabilities;
use crate::error::SocialResult;
use crate::providers::Provider;
use crate::types::{ProviderAccountKey, ProviderKind};

pub struct XProvider;

impl Provider for XProvider {
	fn kind(&self) -> ProviderKind {
		ProviderKind::X
	}

	fn capabilities(&self, _account: &ProviderAccountKey) -> SocialResult<Capabilities> {
		Ok(Capabilities {
			publish: true,
			messages: true,
			comments: true,
			stats: true,
			scheduling: false,
		})
	}
}


