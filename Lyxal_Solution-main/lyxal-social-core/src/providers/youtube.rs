use crate::capabilities::Capabilities;
use crate::error::SocialResult;
use crate::providers::Provider;
use crate::types::{ProviderAccountKey, ProviderKind};

pub struct YouTubeProvider;

impl Provider for YouTubeProvider {
	fn kind(&self) -> ProviderKind {
		ProviderKind::YouTube
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


