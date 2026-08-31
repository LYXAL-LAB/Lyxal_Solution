use crate::error::CryptoError;

/// Contexte d'authentification lié (AAD - Additional Authenticated Data)
/// pour lier un secret chiffré à son tenant, son module, sa ressource et son identifiant.
///
/// Les champs sont encapsulés et validés lors de la construction pour empêcher les valeurs vides.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SecretContext {
    tenant: String,
    module: String,
    resource: String,
    record_id: String,
    field: String,
}

impl SecretContext {
    /// Crée un nouveau contexte d'authentification canonique avec tenant par défaut (utilitaire mono-tenant / tests).
    pub fn new(module: impl AsRef<str>, resource: impl AsRef<str>, record_id: impl AsRef<str>, field: impl AsRef<str>) -> Result<Self, CryptoError> {
        Self::with_tenant("default", module, resource, record_id, field)
    }

    /// Crée un nouveau contexte d'authentification canonique avec tenant explicite et validation stricte.
    pub fn with_tenant(tenant: impl AsRef<str>, module: impl AsRef<str>, resource: impl AsRef<str>, record_id: impl AsRef<str>, field: impl AsRef<str>) -> Result<Self, CryptoError> {
        let t = tenant.as_ref().trim();
        let m = module.as_ref().trim();
        let r = resource.as_ref().trim();
        let id = record_id.as_ref().trim();
        let f = field.as_ref().trim();

        if t.is_empty() {
            return Err(CryptoError::InvalidContext("tenant cannot be empty".to_string()));
        }
        if m.is_empty() {
            return Err(CryptoError::InvalidContext("module cannot be empty".to_string()));
        }
        if r.is_empty() {
            return Err(CryptoError::InvalidContext("resource cannot be empty".to_string()));
        }
        if id.is_empty() {
            return Err(CryptoError::InvalidContext("record_id cannot be empty".to_string()));
        }
        if f.is_empty() {
            return Err(CryptoError::InvalidContext("field cannot be empty".to_string()));
        }

        Ok(Self {
            tenant: t.to_lowercase(),
            module: m.to_lowercase(),
            resource: r.to_lowercase(),
            record_id: id.to_string(),
            field: f.to_lowercase(),
        })
    }

    pub fn tenant(&self) -> &str {
        &self.tenant
    }

    pub fn module(&self) -> &str {
        &self.module
    }

    pub fn resource(&self) -> &str {
        &self.resource
    }

    pub fn record_id(&self) -> &str {
        &self.record_id
    }

    pub fn field(&self) -> &str {
        &self.field
    }

    /// Génère le buffer AAD canonique et déterministe sous un format préfixé par la longueur
    /// garantissant l'absence totale de collisions (anti-ambiguïté) :
    /// `lyxal:v1:<len_tenant>:<tenant>:<len_module>:<module>:<len_resource>:<resource>:<len_record>:<record_id>:<len_field>:<field>`
    pub fn to_aad_bytes(&self) -> Vec<u8> {
        format!(
            "lyxal:v1:{}:{}:{}:{}:{}:{}:{}:{}:{}:{}",
            self.tenant.len(),
            self.tenant,
            self.module.len(),
            self.module,
            self.resource.len(),
            self.resource,
            self.record_id.len(),
            self.record_id,
            self.field.len(),
            self.field
        )
        .into_bytes()
    }
}
