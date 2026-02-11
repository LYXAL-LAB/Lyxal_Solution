use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum SystemEvent {
	SchedulerDefined {
		ns: String,
		db: String,
		name: String,
		enabled: bool,
	},
	SchedulerRemoved {
		ns: String,
		db: String,
		name: String,
	},
}

