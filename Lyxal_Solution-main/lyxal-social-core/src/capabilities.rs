#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Capabilities {
	pub publish: bool,
	pub messages: bool,
	pub comments: bool,
	pub stats: bool,
	pub scheduling: bool,
}

impl Capabilities {
	pub const fn none() -> Self {
		Self {
			publish: false,
			messages: false,
			comments: false,
			stats: false,
			scheduling: false,
		}
	}

	pub const fn discord_messages_only() -> Self {
		Self {
			publish: false,
			messages: true,
			comments: false,
			stats: false,
			scheduling: false,
		}
	}

	pub const fn tiktok(publish: bool, stats: bool) -> Self {
		Self {
			publish,
			messages: false,
			comments: false,
			stats,
			scheduling: false,
		}
	}
}

