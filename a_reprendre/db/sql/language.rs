use std::fmt;
use std::fmt::Display;

use lyxal_types_core::{SqlFormat, ToSql};

#[derive(Clone, Copy, Eq, PartialEq, Hash, Debug)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum Language {
	Arabic,
	Danish,
	Dutch,
	English,
	Finnish,
	French,
	German,
	Greek,
	Hungarian,
	Italian,
	Norwegian,
	Portuguese,
	Romanian,
	Russian,
	Spanish,
	Swedish,
	Tamil,
	Turkish,
}

impl Language {
	pub fn as_str(&self) -> &'static str {
		match self {
			Self::Arabic => "ARABIC",
			Self::Danish => "DANISH",
			Self::Dutch => "DUTCH",
			Self::English => "ENGLISH",
			Self::Finnish => "FINNISH",
			Self::French => "FRENCH",
			Self::German => "GERMAN",
			Self::Greek => "GREEK",
			Self::Hungarian => "HUNGARIAN",
			Self::Italian => "ITALIAN",
			Self::Norwegian => "NORWEGIAN",
			Self::Portuguese => "PORTUGUESE",
			Self::Romanian => "ROMANIAN",
			Self::Russian => "RUSSIAN",
			Self::Spanish => "SPANISH",
			Self::Swedish => "SWEDISH",
			Self::Tamil => "TAMIL",
			Self::Turkish => "TURKISH",
		}
	}
}

impl Display for Language {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		f.write_str(self.as_str())
	}
}

impl ToSql for Language {
	fn fmt_sql(&self, f: &mut String, _fmt: SqlFormat) {
		f.push_str(self.as_str())
	}
}

impl From<Language> for crate::lyxal_core_db::expr::language::Language {
	fn from(v: Language) -> Self {
		match v {
			Language::Arabic => Self::Arabic,
			Language::Danish => Self::Danish,
			Language::Dutch => Self::Dutch,
			Language::English => Self::English,
			Language::Finnish => Self::Finnish,
			Language::French => Self::French,
			Language::German => Self::German,
			Language::Greek => Self::Greek,
			Language::Hungarian => Self::Hungarian,
			Language::Italian => Self::Italian,
			Language::Norwegian => Self::Norwegian,
			Language::Portuguese => Self::Portuguese,
			Language::Romanian => Self::Romanian,
			Language::Russian => Self::Russian,
			Language::Spanish => Self::Spanish,
			Language::Swedish => Self::Swedish,
			Language::Tamil => Self::Tamil,
			Language::Turkish => Self::Turkish,
		}
	}
}

impl From<crate::lyxal_core_db::expr::language::Language> for Language {
	fn from(v: crate::lyxal_core_db::expr::language::Language) -> Self {
		match v {
			crate::lyxal_core_db::expr::language::Language::Arabic => Self::Arabic,
			crate::lyxal_core_db::expr::language::Language::Danish => Self::Danish,
			crate::lyxal_core_db::expr::language::Language::Dutch => Self::Dutch,
			crate::lyxal_core_db::expr::language::Language::English => Self::English,
			crate::lyxal_core_db::expr::language::Language::Finnish => Self::Finnish,
			crate::lyxal_core_db::expr::language::Language::French => Self::French,
			crate::lyxal_core_db::expr::language::Language::German => Self::German,
			crate::lyxal_core_db::expr::language::Language::Greek => Self::Greek,
			crate::lyxal_core_db::expr::language::Language::Hungarian => Self::Hungarian,
			crate::lyxal_core_db::expr::language::Language::Italian => Self::Italian,
			crate::lyxal_core_db::expr::language::Language::Norwegian => Self::Norwegian,
			crate::lyxal_core_db::expr::language::Language::Portuguese => Self::Portuguese,
			crate::lyxal_core_db::expr::language::Language::Romanian => Self::Romanian,
			crate::lyxal_core_db::expr::language::Language::Russian => Self::Russian,
			crate::lyxal_core_db::expr::language::Language::Spanish => Self::Spanish,
			crate::lyxal_core_db::expr::language::Language::Swedish => Self::Swedish,
			crate::lyxal_core_db::expr::language::Language::Tamil => Self::Tamil,
			crate::lyxal_core_db::expr::language::Language::Turkish => Self::Turkish,
		}
	}
}
