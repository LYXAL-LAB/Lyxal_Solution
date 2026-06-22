use lyxal_types_core::{SqlFormat, ToSql, write_sql};
use serde::{Deserialize, Serialize};
use std::fmt::{Display, Formatter, Result};

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct RemoveConnectorStatement {
    pub name: String,
}

impl ToSql for RemoveConnectorStatement {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        write_sql!(f, _sql_fmt, "REMOVE CONNECTOR {}", self.name);
    }
}

impl Display for RemoveConnectorStatement {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        Display::fmt(&self.name, f)
    }
}
