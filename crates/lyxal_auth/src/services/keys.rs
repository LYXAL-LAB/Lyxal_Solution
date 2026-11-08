//! Clés de signature des jetons d'accès et clé de condensation des codes.
//!
//! Clés générées ici (`OsRng`), scellées par `lyxal_crypto` (`SecretContext::global`) et
//! conservées par `fn::auth_signing_key_*`. Deux accès SurrealDB en alternance
//! (`lyxal_auth_a`, `lyxal_auth_b`) vérifient les jetons : la base refuse d'écraser un
//! emplacement tant que des jetons signés par lui peuvent être valides (garde de réutilisation).

use lyxal_crypto::{
    CryptoEngine, EncryptedEnvelope, HmacKey, KeyResolver, SecretBytes, SecretContext, SecretString,
};
use rand_core::{OsRng, RngCore};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::sync::Mutex;
use zeroize::Zeroizing;

use crate::error::{AuthError, AuthResult};
use crate::models::{SigningKeyGetParams, SigningKeyRecord, SigningKeyRotateParams};
use crate::store::AuthStore;

/// Durée pendant laquelle une instance garde la clé active en mémoire.
pub const SIGNING_KEY_CACHE: Duration = Duration::from_secs(30);
/// Longueur d'une clé d'accès (caractères `A-Z a-z 0-9 _ -`, 192 bits).
const ACCESS_KEY_LEN: usize = 32;
const ALPHABET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-";

/// Nom de l'accès SurrealDB d'un emplacement.
pub fn access_name(slot: &str) -> String {
    format!("lyxal_auth_{slot}")
}

/// Clé active de signature des jetons d'accès.
pub struct ActiveSigningKey {
    /// Emplacement (`a` ou `b`) : l'accès `lyxal_auth_<slot>` vérifie les jetons signés.
    pub slot: String,
    key: SecretString,
}

impl ActiveSigningKey {
    /// Clé HMAC (les 32 caractères de la clé, comme l'accès SurrealDB).
    pub fn hmac_key(&self) -> AuthResult<HmacKey> {
        Ok(HmacKey::import(SecretBytes::new(
            self.key.expose_secret().as_bytes().to_vec(),
        )?)?)
    }
}

impl std::fmt::Debug for ActiveSigningKey {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ActiveSigningKey")
            .field("slot", &self.slot)
            .finish_non_exhaustive()
    }
}

/// Clés de `lyxal_auth`, sur la session système de l'hôte et le trousseau applicatif.
pub struct SigningKeyService<R: KeyResolver> {
    store: AuthStore,
    crypto: Arc<CryptoEngine<R>>,
    cache: Mutex<Option<(Instant, Arc<ActiveSigningKey>)>>,
    pepper: Mutex<Option<Arc<HmacKey>>>,
}

impl<R: KeyResolver> SigningKeyService<R> {
    /// Service sur la session système et le moteur cryptographique de l'hôte.
    pub fn new(store: AuthStore, crypto: Arc<CryptoEngine<R>>) -> Self {
        Self {
            store,
            crypto,
            cache: Mutex::new(None),
            pepper: Mutex::new(None),
        }
    }

    /// Crée les clés absentes (première installation) puis définit les accès SurrealDB.
    pub async fn ensure(&self) -> AuthResult<()> {
        match self.active_record("access_token").await {
            Ok(_) => {}
            Err(error) if error.is("AUTH_SIGNING_KEY_UNAVAILABLE") => {
                self.rotate(false).await?;
            }
            Err(error) => return Err(error),
        }
        // Créée une seule fois : sans effet si elle existe déjà
        let pepper = random_bytes(32)?;
        let sealed = self.seal(&pepper, "code_pepper")?;
        self.store
            .signing_key_rotate(SigningKeyRotateParams {
                purpose: "code_pepper".to_string(),
                secret: sealed,
                force: false,
                cache_seconds: SIGNING_KEY_CACHE.as_secs() as i64,
            })
            .await?;
        self.define_accesses().await
    }

    /// Active une nouvelle clé dans l'emplacement inactif et redéfinit les accès. `force` écrase
    /// un emplacement dont des jetons peuvent encore être valides (clé compromise).
    pub async fn rotate(&self, force: bool) -> AuthResult<String> {
        let key = generate_access_key()?;
        let sealed = self.seal(
            &SecretBytes::new(key.expose_secret().as_bytes().to_vec())?,
            "access_token",
        )?;
        let rotated = self
            .store
            .signing_key_rotate(SigningKeyRotateParams {
                purpose: "access_token".to_string(),
                secret: sealed,
                force,
                cache_seconds: SIGNING_KEY_CACHE.as_secs() as i64,
            })
            .await?;
        *self.cache.lock().await = None;
        self.define_accesses().await?;
        rotated
            .slot
            .ok_or(AuthError::Rejected("AUTH_SIGNING_KEY_UNAVAILABLE"))
    }

    /// Clé active (relue au plus toutes les 30 s).
    pub async fn signing_key(&self) -> AuthResult<Arc<ActiveSigningKey>> {
        let mut cache = self.cache.lock().await;
        if let Some((at, key)) = cache.as_ref() {
            if at.elapsed() < SIGNING_KEY_CACHE {
                return Ok(key.clone());
            }
        }
        let record = self.active_record("access_token").await?.0;
        let key = Arc::new(ActiveSigningKey {
            slot: record
                .slot
                .clone()
                .ok_or(AuthError::Rejected("AUTH_SIGNING_KEY_UNAVAILABLE"))?,
            key: self.open_text(&record.secret, "access_token")?,
        });
        *cache = Some((Instant::now(), key.clone()));
        Ok(key)
    }

    /// Clé HMAC de condensation des codes à usage unique.
    pub async fn code_pepper(&self) -> AuthResult<Arc<HmacKey>> {
        let mut pepper = self.pepper.lock().await;
        if let Some(key) = pepper.as_ref() {
            return Ok(key.clone());
        }
        let record = self.active_record("code_pepper").await?.0;
        let key = Arc::new(HmacKey::import(self.open(&record.secret, "code_pepper")?)?);
        *pepper = Some(key.clone());
        Ok(key)
    }

    /// Définit l'accès de chaque emplacement avec sa clé ; supprime l'accès d'un emplacement vide.
    pub async fn define_accesses(&self) -> AuthResult<()> {
        let (active, previous) = self.active_record("access_token").await?;
        let mut defined = Vec::new();
        for record in std::iter::once(&active).chain(previous.as_ref()) {
            let Some(slot) = record.slot.as_deref() else {
                continue;
            };
            let key = self.open_text(&record.secret, "access_token")?;
            // Clé contrôlée par generate_access_key (A-Z a-z 0-9 _ -) : aucun caractère à échapper
            if !is_access_key(key.expose_secret()) {
                return Err(AuthError::Rejected("AUTH_SIGNING_KEY_UNAVAILABLE"));
            }
            let statement = Zeroizing::new(format!(
                "DEFINE ACCESS OVERWRITE {} ON DATABASE TYPE RECORD WITH JWT ALGORITHM HS256 KEY '{}' \
                 AUTHENTICATE {{ IF !fn::auth_session_valid({{}}).valid {{ THROW \"AUTH_SESSION_REVOKED\" }}; RETURN $auth; }} \
                 DURATION FOR SESSION 15m;",
                access_name(slot),
                key.expose_secret()
            ));
            self.execute(&statement).await?;
            defined.push(slot.to_string());
        }
        for slot in ["a", "b"] {
            if !defined.iter().any(|s| s == slot) {
                self.execute(&format!(
                    "REMOVE ACCESS IF EXISTS {} ON DATABASE;",
                    access_name(slot)
                ))
                .await?;
            }
        }
        Ok(())
    }

    async fn active_record(
        &self,
        purpose: &str,
    ) -> AuthResult<(SigningKeyRecord, Option<SigningKeyRecord>)> {
        let keys = self
            .store
            .signing_key_get_active(SigningKeyGetParams {
                purpose: purpose.to_string(),
            })
            .await?;
        Ok((keys.active, keys.previous))
    }

    async fn execute(&self, statement: &str) -> AuthResult<()> {
        self.store
            .client()
            .query(statement)
            .await
            .and_then(|response| response.check())
            .map(|_| ())
            .map_err(|error| AuthError::from(lyxal_surreal::LyxalSurrealError::from(error)))
    }

    fn context(purpose: &str) -> AuthResult<SecretContext> {
        Ok(SecretContext::global(&format!("lyxal_auth.{purpose}"))?)
    }

    fn seal(&self, secret: &SecretBytes, purpose: &str) -> AuthResult<String> {
        Ok(self.crypto.seal(secret, &Self::context(purpose)?)?.encode())
    }

    fn open(&self, sealed: &str, purpose: &str) -> AuthResult<SecretBytes> {
        Ok(self
            .crypto
            .open(&EncryptedEnvelope::parse(sealed)?, &Self::context(purpose)?)?)
    }

    fn open_text(&self, sealed: &str, purpose: &str) -> AuthResult<SecretString> {
        let bytes = self.open(sealed, purpose)?;
        let text = std::str::from_utf8(bytes.expose_secret())
            .map_err(|_| AuthError::Rejected("AUTH_SIGNING_KEY_UNAVAILABLE"))?;
        Ok(SecretString::new(text.to_string())?)
    }
}

/// Clé d'accès aléatoire : 32 caractères `A-Z a-z 0-9 _ -` (`OsRng`).
pub fn generate_access_key() -> AuthResult<SecretString> {
    let raw = random_bytes(ACCESS_KEY_LEN)?;
    let text: String = raw
        .expose_secret()
        .iter()
        .map(|b| ALPHABET[(b & 63) as usize] as char)
        .collect();
    Ok(SecretString::new(text)?)
}

fn is_access_key(key: &str) -> bool {
    key.len() == ACCESS_KEY_LEN && key.bytes().all(|b| ALPHABET.contains(&b))
}

/// Octets aléatoires (`OsRng`).
pub(crate) fn random_bytes(len: usize) -> AuthResult<SecretBytes> {
    let mut raw = Zeroizing::new(vec![0u8; len]);
    OsRng
        .try_fill_bytes(&mut raw)
        .map_err(|_| AuthError::Crypto(lyxal_crypto::CryptoError::RandomUnavailable))?;
    Ok(SecretBytes::new(raw.to_vec())?)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn access_keys_are_random_and_use_the_access_alphabet() {
        let a = generate_access_key().expect("clé");
        let b = generate_access_key().expect("clé");
        assert!(is_access_key(a.expose_secret()));
        assert_ne!(a.expose_secret(), b.expose_secret());
        assert!(!is_access_key("trop-court"));
        assert!(!is_access_key("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'"));
        assert_eq!(access_name("a"), "lyxal_auth_a");
    }
}
