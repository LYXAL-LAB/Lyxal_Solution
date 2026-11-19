use crate::error::RuntimeError;
use serde::{Deserialize, Serialize};
use std::fmt;

/// Longueur maximale d'un nom d'hôte.
const HOST_ID_MAX_LENGTH: usize = 64;

/// Hôte : le rôle d'un binaire (`lyxal_server`, `lyxal_groupware`). Le nom est une constante du
/// binaire, le même pour toutes ses copies ; il n'est pas réglable par configuration (deux noms
/// pour un même binaire donneraient deux propriétaires aux mêmes abonnements).
///
/// À ne pas confondre avec le nœud ([`crate::NodeId`]) : un processus en cours, dont
/// l'identifiant est tiré au sort à chaque démarrage et sert aux baux.
#[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
pub struct HostId(String);

impl HostId {
    /// Crée un nom d'hôte au format d'un identifiant de module : une minuscule, puis des
    /// minuscules, chiffres ou tirets bas, 64 caractères au plus.
    pub fn new(host: &str) -> Result<Self, RuntimeError> {
        let invalid = |reason: &str| RuntimeError::HostInvalid {
            host: host.to_string(),
            reason: reason.to_string(),
        };
        if host.len() > HOST_ID_MAX_LENGTH {
            return Err(invalid("more than 64 characters"));
        }
        let mut chars = host.chars();
        if !chars.next().is_some_and(|c| c.is_ascii_lowercase()) {
            return Err(invalid("must start with a lowercase letter"));
        }
        if !chars.all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '_') {
            return Err(invalid(
                "only lowercase letters, digits and underscores are allowed",
            ));
        }
        Ok(Self(host.to_string()))
    }

    /// Retourne le nom de l'hôte.
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl AsRef<str> for HostId {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for HostId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn host_id_accepts_module_identifier_format() {
        for host in ["lyxal_server", "lyxal_groupware", "a", "h2_b"] {
            assert_eq!(HostId::new(host).unwrap().as_str(), host);
        }
        assert!(HostId::new(&"a".repeat(64)).is_ok());
    }

    #[test]
    fn host_id_refuses_any_other_format() {
        let too_long = "a".repeat(65);
        for host in [
            "",
            "Lyxal",
            "lyxal-server",
            "1host",
            "_host",
            "lyxal server",
            " lyxal",
            "hôte",
            too_long.as_str(),
        ] {
            let err = HostId::new(host).unwrap_err();
            assert_eq!(err.code(), "RUNTIME_HOST_INVALID", "{host:?}");
        }
    }
}
