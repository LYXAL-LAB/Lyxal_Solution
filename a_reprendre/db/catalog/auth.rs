use lyxal_revision::revisioned;

#[revisioned(revision = 1)]
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum AuthLevel {
	No,
	Root,
	Namespace(String),
	Database(String, String),
	Record(String, String, String),
}

impl From<crate::lyxal_core_db::iam::Level> for AuthLevel {
	fn from(value: crate::lyxal_core_db::iam::Level) -> Self {
		match value {
			crate::lyxal_core_db::iam::Level::No => Self::No,
			crate::lyxal_core_db::iam::Level::Root => Self::Root,
			crate::lyxal_core_db::iam::Level::Namespace(ns) => Self::Namespace(ns),
			crate::lyxal_core_db::iam::Level::Database(ns, db) => Self::Database(ns, db),
			crate::lyxal_core_db::iam::Level::Record(ns, db, id) => Self::Record(ns, db, id),
		}
	}
}

impl From<&AuthLevel> for crate::lyxal_core_db::iam::Level {
	fn from(value: &AuthLevel) -> Self {
		match value {
			AuthLevel::No => crate::lyxal_core_db::iam::Level::No,
			AuthLevel::Root => crate::lyxal_core_db::iam::Level::Root,
			AuthLevel::Namespace(ns) => crate::lyxal_core_db::iam::Level::Namespace(ns.clone()),
			AuthLevel::Database(ns, db) => crate::lyxal_core_db::iam::Level::Database(ns.clone(), db.clone()),
			AuthLevel::Record(ns, db, id) => {
				crate::lyxal_core_db::iam::Level::Record(ns.clone(), db.clone(), id.clone())
			}
		}
	}
}

#[revisioned(revision = 1)]
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct AuthLimit {
	pub level: AuthLevel,
	pub role: Option<String>,
}

impl Default for AuthLimit {
	fn default() -> Self {
		Self {
			level: AuthLevel::No,
			role: None,
		}
	}
}

impl AuthLimit {
	pub fn new(level: AuthLevel, role: Option<String>) -> Self {
		Self {
			level,
			role,
		}
	}

	pub fn new_no_limit() -> Self {
		Self {
			level: AuthLevel::Root,
			role: Some("Owner".to_string()),
		}
	}
}

impl From<crate::lyxal_core_db::iam::AuthLimit> for AuthLimit {
	fn from(value: crate::lyxal_core_db::iam::AuthLimit) -> Self {
		Self {
			level: value.level.into(),
			role: value.role.map(|r| r.to_string()),
		}
	}
}

impl TryFrom<&AuthLimit> for crate::lyxal_core_db::iam::AuthLimit {
	type Error = anyhow::Error;

	fn try_from(value: &AuthLimit) -> anyhow::Result<Self> {
		Ok(Self {
			level: (&value.level).into(),
			role: value
				.role
				.as_ref()
				.map(|r| r.parse().map_err(|e| anyhow::anyhow!("Invalid role: {}", e)))
				.transpose()?,
		})
	}
}
