use std::str::FromStr;

use serde::{Deserialize, Serialize};

#[derive(Copy, Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum LyxalMode {
    Auto,
    Approve,
    SmartApprove,
    Chat,
}

impl FromStr for LyxalMode {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "auto" => Ok(LyxalMode::Auto),
            "approve" => Ok(LyxalMode::Approve),
            "smart_approve" => Ok(LyxalMode::SmartApprove),
            "chat" => Ok(LyxalMode::Chat),
            _ => Err(format!("invalid mode: {}", s)),
        }
    }
}
