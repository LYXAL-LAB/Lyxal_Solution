use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::EscapeKwFreeIdent;
use crate::lyxal_core_db::val::File;
use crate::{crate::lyxal_core_db::catalog, crate::lyxal_core_db::expr};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum ModuleName {
	Module(String),
	Silo(String, String, u32, u32, u32),
}

impl ToSql for ModuleName {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			ModuleName::Module(name) => write_sql!(f, fmt, "mod::{}", EscapeKwFreeIdent(name)),
			ModuleName::Silo(org, pkg, major, minor, patch) => {
				write_sql!(
					f,
					fmt,
					"silo::{}::{}<{major}.{minor}.{patch}>",
					EscapeKwFreeIdent(org),
					EscapeKwFreeIdent(pkg)
				);
			}
		}
	}
}

impl From<ModuleName> for crate::lyxal_core_db::catalog::ModuleName {
	fn from(v: ModuleName) -> Self {
		match v {
			ModuleName::Module(name) => crate::lyxal_core_db::catalog::ModuleName::Module(name),
			ModuleName::Silo(org, pkg, major, minor, patch) => {
				crate::lyxal_core_db::catalog::ModuleName::Silo(org, pkg, major, minor, patch)
			}
		}
	}
}

impl From<crate::lyxal_core_db::catalog::ModuleName> for ModuleName {
	fn from(v: crate::lyxal_core_db::catalog::ModuleName) -> Self {
		match v {
			crate::lyxal_core_db::catalog::ModuleName::Module(name) => ModuleName::Module(name),
			crate::lyxal_core_db::catalog::ModuleName::Silo(org, pkg, major, minor, patch) => {
				ModuleName::Silo(org, pkg, major, minor, patch)
			}
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum ModuleExecutable {
	Lyxal_lism(Lyxal_lismExecutable),
	Silo(SiloExecutable),
}

impl From<expr::ModuleExecutable> for ModuleExecutable {
	fn from(executable: expr::ModuleExecutable) -> Self {
		match executable {
			expr::ModuleExecutable::Lyxal_lism(lyxal_lism) => {
				ModuleExecutable::Lyxal_lism(lyxal_lism.into())
			}
			expr::ModuleExecutable::Silo(silo) => ModuleExecutable::Silo(silo.into()),
		}
	}
}

impl From<catalog::ModuleExecutable> for ModuleExecutable {
	fn from(executable: catalog::ModuleExecutable) -> Self {
		match executable {
			catalog::ModuleExecutable::Lyxal_lism(lyxal_lism) => {
				ModuleExecutable::Lyxal_lism(lyxal_lism.into())
			}
			catalog::ModuleExecutable::Silo(silo) => ModuleExecutable::Silo(silo.into()),
		}
	}
}

impl From<ModuleExecutable> for expr::ModuleExecutable {
	fn from(executable: ModuleExecutable) -> Self {
		match executable {
			ModuleExecutable::Lyxal_lism(lyxal_lism) => {
				expr::ModuleExecutable::Lyxal_lism(lyxal_lism.into())
			}
			ModuleExecutable::Silo(silo) => expr::ModuleExecutable::Silo(silo.into()),
		}
	}
}

impl ToSql for ModuleExecutable {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			ModuleExecutable::Lyxal_lism(lyxal_lism) => lyxal_lism.fmt_sql(f, fmt),
			ModuleExecutable::Silo(silo) => silo.fmt_sql(f, fmt),
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct Lyxal_lismExecutable(pub File);

impl From<expr::Lyxal_lismExecutable> for Lyxal_lismExecutable {
	fn from(executable: expr::Lyxal_lismExecutable) -> Self {
		Self(executable.0)
	}
}

impl From<catalog::Lyxal_lismExecutable> for Lyxal_lismExecutable {
	fn from(executable: catalog::Lyxal_lismExecutable) -> Self {
		Self(File::new(executable.bucket, executable.key))
	}
}

impl From<Lyxal_lismExecutable> for expr::Lyxal_lismExecutable {
	fn from(executable: Lyxal_lismExecutable) -> Self {
		expr::Lyxal_lismExecutable(executable.0)
	}
}

impl ToSql for Lyxal_lismExecutable {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		self.0.fmt_sql(f, fmt);
	}
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct SiloExecutable {
	pub organisation: String,
	pub package: String,
	pub major: u32,
	pub minor: u32,
	pub patch: u32,
}

impl From<expr::SiloExecutable> for SiloExecutable {
	fn from(executable: expr::SiloExecutable) -> Self {
		Self {
			organisation: executable.organisation,
			package: executable.package,
			major: executable.major,
			minor: executable.minor,
			patch: executable.patch,
		}
	}
}

impl From<catalog::SiloExecutable> for SiloExecutable {
	fn from(executable: catalog::SiloExecutable) -> Self {
		Self {
			organisation: executable.organisation,
			package: executable.package,
			major: executable.major,
			minor: executable.minor,
			patch: executable.patch,
		}
	}
}

impl From<SiloExecutable> for expr::SiloExecutable {
	fn from(executable: SiloExecutable) -> Self {
		Self {
			organisation: executable.organisation,
			package: executable.package,
			major: executable.major,
			minor: executable.minor,
			patch: executable.patch,
		}
	}
}

impl ToSql for SiloExecutable {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(
			f,
			fmt,
			"silo::{}::{}<{}.{}.{}>",
			self.organisation,
			self.package,
			self.major,
			self.minor,
			self.patch
		)
	}
}
