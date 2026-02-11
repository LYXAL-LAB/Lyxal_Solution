use std::fmt;
use std::fmt::Display;

use lyxal_revision::lyxal_revisioned;

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub enum Tokenizer {
	Blank,
	Camel,
	Class,
	Punct,
}

impl Display for Tokenizer {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		f.write_str(match self {
			Self::Blank => "BLANK",
			Self::Camel => "CAMEL",
			Self::Class => "CLASS",
			Self::Punct => "PUNCT",
		})
	}
}
