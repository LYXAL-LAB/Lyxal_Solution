//! Mots de passe : politique, hachage Argon2id (`lyxal_crypto::password`), historique, empreinte
//! scellée par identité, vérification en temps comparable pour un identifiant inconnu.
//!
//! La partie secrète enregistrée (`auth_credential.secret_data`) est l'objet JSON
//! `{ "current": <PHC>, "history": [<PHC>…] }` scellé sous
//! `with_tenant("lyxal_installation", "lyxal_auth", "auth_credential", <identité>, "secret_data")` :
//! une empreinte recopiée sur une autre identité ne s'ouvre pas.

use lyxal_crypto::{
    hash_password, verify_password, CryptoEngine, EncryptedEnvelope, KeyResolver, PasswordHash,
    PasswordVerification, SecretBytes, SecretContext, SecretString,
};
use std::sync::{Arc, OnceLock};
use zeroize::Zeroizing;

use crate::error::{AuthError, AuthResult};

/// Longueur maximale d'un mot de passe (caractères), contre les abus de calcul.
pub const PASSWORD_MAX_CHARS: usize = 128;

/// Politique de mot de passe (thème `password` de `fn::auth_policy_get`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PasswordPolicy {
    /// Longueur minimale.
    pub min_length: usize,
    /// Nombre de classes exigées parmi minuscules, majuscules, chiffres, autres.
    pub require_classes: usize,
    /// Nombre d'anciens mots de passe refusés.
    pub history: usize,
}

impl Default for PasswordPolicy {
    fn default() -> Self {
        Self {
            min_length: 12,
            require_classes: 0,
            history: 5,
        }
    }
}

impl PasswordPolicy {
    /// Politique lue dans la politique effective (valeurs absentes : défauts).
    pub fn from_policy(policy: &serde_json::Value) -> Self {
        let read = |key: &str, default: usize| {
            policy["password"][key]
                .as_u64()
                .map(|v| v as usize)
                .unwrap_or(default)
        };
        let defaults = Self::default();
        Self {
            min_length: read("min_length", defaults.min_length),
            require_classes: read("require_classes", defaults.require_classes),
            history: read("history", defaults.history),
        }
    }

    /// Contrôle un mot de passe (`AUTH_PASSWORD_POLICY_VIOLATION`).
    pub fn check(&self, password: &SecretString) -> AuthResult<()> {
        let text = password.expose_secret();
        let length = text.chars().count();
        if length < self.min_length || length > PASSWORD_MAX_CHARS {
            return Err(AuthError::Rejected("AUTH_PASSWORD_POLICY_VIOLATION"));
        }
        let classes = [
            text.chars().any(|c| c.is_lowercase()),
            text.chars().any(|c| c.is_uppercase()),
            text.chars().any(|c| c.is_ascii_digit()),
            text.chars().any(|c| !c.is_alphanumeric()),
        ]
        .iter()
        .filter(|present| **present)
        .count();
        if classes < self.require_classes {
            return Err(AuthError::Rejected("AUTH_PASSWORD_POLICY_VIOLATION"));
        }
        Ok(())
    }
}

/// Résultat d'une vérification.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PasswordCheck {
    /// Mot de passe correct ; l'empreinte doit être recalculée (paramètres plus faibles).
    Valid {
        /// Recalcul conseillé.
        needs_rehash: bool,
    },
    /// Mot de passe incorrect (ou identifiant inconnu).
    Invalid,
}

/// Service des mots de passe, sur le trousseau applicatif.
pub struct PasswordService<R: KeyResolver> {
    crypto: Arc<CryptoEngine<R>>,
}

impl<R: KeyResolver + 'static> PasswordService<R> {
    /// Service sur le moteur cryptographique de l'hôte.
    pub fn new(crypto: Arc<CryptoEngine<R>>) -> Self {
        Self { crypto }
    }

    /// Vérifie un mot de passe contre l'empreinte scellée d'une identité ; sans empreinte
    /// (identifiant inconnu, pas de mot de passe), vérification contre une empreinte factice pour
    /// une durée comparable.
    pub async fn verify(
        &self,
        password: &SecretString,
        identity: Option<&str>,
        sealed: Option<&str>,
    ) -> AuthResult<PasswordCheck> {
        let stored = match (identity, sealed) {
            (Some(identity), Some(sealed)) => Some(self.open(identity, sealed)?),
            _ => None,
        };
        let candidate = SecretString::new(password.expose_secret().to_string())?;
        let current = match &stored {
            Some(secret) => Some(PasswordHash::parse(&secret.current)?),
            None => None,
        };
        let verification =
            tokio::task::spawn_blocking(move || -> AuthResult<PasswordVerification> {
                let hash = match current {
                    Some(hash) => hash,
                    None => {
                        // Empreinte factice : même coût Argon2id, résultat toujours négatif
                        let _ = verify_password(&candidate, dummy_hash()?)?;
                        return Ok(PasswordVerification::Mismatch);
                    }
                };
                Ok(verify_password(&candidate, &hash)?)
            })
            .await
            .map_err(|_| AuthError::Rejected("AUTH_CRYPTO_ERROR"))??;
        Ok(match verification {
            PasswordVerification::Verified { needs_rehash } => {
                PasswordCheck::Valid { needs_rehash }
            }
            PasswordVerification::Mismatch => PasswordCheck::Invalid,
        })
    }

    /// Nouvelle empreinte scellée : politique contrôlée, mot de passe absent de l'historique
    /// (`AUTH_PASSWORD_REUSED`), historique tenu à jour.
    pub async fn seal_new(
        &self,
        identity: &str,
        password: &SecretString,
        policy: PasswordPolicy,
        previous: Option<&str>,
    ) -> AuthResult<String> {
        policy.check(password)?;
        let mut history: Vec<String> = Vec::new();
        if let Some(sealed) = previous {
            let stored = self.open(identity, sealed)?;
            let mut known = vec![stored.current.clone()];
            known.extend(stored.history.iter().cloned());
            known.truncate(policy.history.max(1));
            for phc in &known {
                let candidate = SecretString::new(password.expose_secret().to_string())?;
                let hash = PasswordHash::parse(phc)?;
                let reused =
                    tokio::task::spawn_blocking(move || verify_password(&candidate, &hash))
                        .await
                        .map_err(|_| AuthError::Rejected("AUTH_CRYPTO_ERROR"))??;
                if matches!(reused, PasswordVerification::Verified { .. }) && policy.history > 0 {
                    return Err(AuthError::Rejected("AUTH_PASSWORD_REUSED"));
                }
            }
            history = known;
            history.truncate(policy.history);
        }
        let candidate = SecretString::new(password.expose_secret().to_string())?;
        let hash = tokio::task::spawn_blocking(move || hash_password(&candidate))
            .await
            .map_err(|_| AuthError::Rejected("AUTH_CRYPTO_ERROR"))??;
        let document = Zeroizing::new(
            serde_json::json!({ "current": hash.expose_phc(), "history": history }).to_string(),
        );
        let secret = SecretBytes::new(document.as_bytes().to_vec())?;
        Ok(self.crypto.seal(&secret, &context(identity)?)?.encode())
    }

    fn open(&self, identity: &str, sealed: &str) -> AuthResult<StoredPassword> {
        let bytes = self
            .crypto
            .open(&EncryptedEnvelope::parse(sealed)?, &context(identity)?)?;
        let value: serde_json::Value = serde_json::from_slice(bytes.expose_secret())
            .map_err(|_| AuthError::Rejected("AUTH_CRYPTO_ERROR"))?;
        let current = value["current"]
            .as_str()
            .ok_or(AuthError::Rejected("AUTH_CRYPTO_ERROR"))?
            .to_string();
        let history = value["history"]
            .as_array()
            .map(|items| {
                items
                    .iter()
                    .filter_map(|item| item.as_str().map(str::to_string))
                    .collect()
            })
            .unwrap_or_default();
        Ok(StoredPassword { current, history })
    }
}

struct StoredPassword {
    current: String,
    history: Vec<String>,
}

impl Drop for StoredPassword {
    fn drop(&mut self) {
        use zeroize::Zeroize;
        self.current.zeroize();
        for phc in &mut self.history {
            phc.zeroize();
        }
    }
}

/// Contexte de scellement de la partie secrète d'une identité.
pub fn context(identity: &str) -> AuthResult<SecretContext> {
    Ok(SecretContext::with_tenant(
        "lyxal_installation",
        "lyxal_auth",
        "auth_credential",
        identity,
        "secret_data",
    )?)
}

/// Empreinte factice calculée une fois par processus.
fn dummy_hash() -> AuthResult<&'static PasswordHash> {
    static DUMMY: OnceLock<PasswordHash> = OnceLock::new();
    if let Some(hash) = DUMMY.get() {
        return Ok(hash);
    }
    let hash = hash_password(&SecretString::new("lyxal-empreinte-factice".to_string())?)?;
    Ok(DUMMY.get_or_init(|| hash))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn policy_checks_length_and_classes() {
        let secret = |s: &str| SecretString::new(s.to_string()).expect("secret");
        let policy = PasswordPolicy {
            min_length: 12,
            require_classes: 3,
            history: 5,
        };
        assert!(policy.check(&secret("court1A!")).is_err());
        assert!(policy.check(&secret("toutenminuscules")).is_err());
        assert!(policy.check(&secret("Assez-long-2026")).is_ok());
        assert!(
            policy.check(&secret(&"aA1!".repeat(40))).is_err(),
            "plus de 128 caractères"
        );
        let from =
            PasswordPolicy::from_policy(&serde_json::json!({ "password": { "min_length": 14 } }));
        assert_eq!(from.min_length, 14);
        assert_eq!(from.history, 5);
    }
}
