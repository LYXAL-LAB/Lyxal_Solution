use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Label {
    pub uid: String,
    pub name: String,
    pub slug: String,
}

impl Label {
    pub fn new(uid: String, name: String, slug: String) -> Self {
        Self { uid, name, slug }
    }
}
