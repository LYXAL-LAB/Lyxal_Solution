use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum SubjectType {
    Person,
    Thing,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Subject {
    pub uid: String,
    pub name: String,
    pub alias: Option<String>,
    pub subject_type: SubjectType,
    pub hidden: bool,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Person {
    pub subject: Subject,
}

impl Subject {
    pub fn new(uid: String, name: String) -> Self {
        Self {
            uid,
            name,
            alias: None,
            subject_type: SubjectType::Person,
            hidden: false,
        }
    }
}
