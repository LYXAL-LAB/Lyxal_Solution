use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum Relation {
    Viewers, Editors, Builders, Administrators
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AuthToken {
    pub id: String,
    pub project_id: String,
    pub relation: Relation,
    pub can_clone: bool,
    pub can_copy: bool,
    pub can_publish: bool,
}

impl AuthToken {
    pub fn apply_permissions(mut self) -> Self {
        match self.relation {
            Relation::Viewers => {
                self.can_publish = false;
            },
            Relation::Builders => {
                self.can_publish = false;
                self.can_clone = true;
                self.can_copy = true;
            },
            Relation::Editors | Relation::Administrators => {
                self.can_clone = true;
                self.can_copy = true;
                self.can_publish = self.relation == Relation::Administrators;
            }
        }
        self
    }
}

