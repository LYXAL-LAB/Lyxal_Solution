use crate::Scope;

pub struct AccessControl;

impl AccessControl {
    pub fn has_scope(required_scope: &str, user_scopes: &[String]) -> bool {
        user_scopes.iter().any(|s| s == required_scope)
    }

    pub fn validate_resource_access(resource_indicator: &str, user_resources: &[String]) -> bool {
        user_resources.iter().any(|r| r == resource_indicator)
    }
}
