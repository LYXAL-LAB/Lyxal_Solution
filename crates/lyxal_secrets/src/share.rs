//! Partages à usage unique : une copie d'une valeur (celle d'un secret, ou un texte saisi),
//! scellée par une clé aléatoire que seul le lien porte.
//!
//! ```text
//! création : clé du lien (32 octets, OsRng) ──► copie scellée (CryptoEngine::seal)
//!            la base reçoit : enveloppe, empreinte SHA-256 de la clé, hachage Argon2id du
//!            mot de passe ; la clé n'est rendue qu'à l'auteur, en base64url, dans le lien
//! ouverture : chargement (session système) ► empreinte (temps constant) ► mot de passe
//!            ► organisation (lien réservé) ► ouverture consommée ► copie ouverte
//! ```
//!
//! Une clé ou un mot de passe faux compte un essai (`fn::secrets_share_fail`, cinq et le partage
//! est détruit) ; tout refus rend la même erreur, `SECRETS_SHARE_UNAVAILABLE`, sans dire ce qui
//! est faux.

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::password::{hash_password, verify_password, PasswordHash, PasswordVerification};
use lyxal_crypto::{
    sha256_hex, CryptoEngine, CryptoError, EncryptedEnvelope, EncryptionKey, KeyId, KeyRingBuilder,
    KeyUse, SecretBytes, SecretString, StaticKeyResolver,
};
use lyxal_surreal::ToSql;
use rand_core::{OsRng, RngCore};
use std::sync::Arc;

use crate::error::{SecretsError, SecretsResult};
use crate::keys::Scope;
use crate::models::{
    SecretsDuration, SettingsGetParams, Share, ShareConsumeParams, ShareCreateParams,
    ShareRefParams,
};
use crate::service::{RevealRequest, SecretsService};

/// Longueur de la clé d'un lien (AES-256).
const SHARE_KEY_BYTES: usize = 32;
/// Identifiant de la clé d'un lien dans son trousseau d'une seule clé (et dans l'enveloppe).
const SHARE_KEY_ID: &str = "share";

/// Ce qui est partagé : une copie, qui ne suit pas les changements ultérieurs du secret.
#[derive(Debug)]
pub enum ShareSource {
    /// Valeur d'un secret, révélée à l'auteur par le chemin habituel (droits, double facteur,
    /// journal) : version par numéro, sinon par étiquette (`current` par défaut).
    Secret {
        /// Secret (`secrets_secret:<clé>`).
        secret: String,
        /// Étiquette de version.
        label: Option<String>,
        /// Numéro de version.
        number: Option<i64>,
    },
    /// Texte saisi (effacé de la mémoire à la libération).
    Text(SecretBytes),
}

/// Partage demandé ; `Debug` masque la valeur et le mot de passe.
#[derive(Debug)]
pub struct ShareRequest {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation ; pour un secret,
    /// celle du secret.
    pub tenant: Option<String>,
    /// Ce qui est partagé.
    pub source: ShareSource,
    /// Ouvertures permises (1 par défaut ; 10 et les réglages au plus).
    pub max_views: Option<u8>,
    /// Durée (24 heures par défaut ; réglages au plus).
    pub ttl: Option<SecretsDuration>,
    /// Mot de passe demandé en plus de la clé, facultatif (haché par Argon2id).
    pub passphrase: Option<SecretString>,
    /// Ouverture réservée à un membre connecté de l'organisation.
    pub members_only: bool,
    /// Note de l'auteur (destinataire, motif), jamais une valeur.
    pub note: Option<String>,
}

/// Partage créé : sa fiche et la clé de son lien, rendue cette seule fois ; `Debug` masque la
/// clé.
#[derive(Debug)]
pub struct ShareCreated {
    /// Fiche, sans élément scellé.
    pub share: Share,
    /// Clé du lien, en base64url sans remplissage. Elle n'est gardée nulle part.
    pub key: SecretString,
}

/// Appelant connecté qui ouvre un lien, d'après son jeton contrôlé par l'hôte.
#[derive(Debug, Clone, Default)]
pub struct OpenerContext {
    /// Identité (`auth_identity:<clé>`), absente pour un programme.
    pub identity: Option<String>,
    /// Organisation active de la session (`auth_organization:<clé>`).
    pub organization: Option<String>,
}

/// Ouverture d'un lien ; `Debug` masque la clé et le mot de passe.
#[derive(Debug)]
pub struct ShareOpen {
    /// Partage (`secrets_share:<clé>`).
    pub share: String,
    /// Clé du lien (base64url sans remplissage).
    pub key: SecretString,
    /// Mot de passe, si le partage en demande un.
    pub passphrase: Option<SecretString>,
    /// Appelant connecté, s'il y en a un (obligatoire pour un lien réservé à l'organisation).
    pub opener: Option<OpenerContext>,
}

impl SecretsService {
    /// Crée un partage à usage unique avec les droits de l'appelant
    /// (`secrets.share.create` ; pour un secret, droit de lire sa valeur).
    ///
    /// Pour un secret, la valeur est d'abord révélée à l'appelant (droits, double facteur
    /// récent, journal) et le numéro de la version révélée est enregistré. La copie est scellée
    /// par une clé de 32 octets tirée par `OsRng`, dans un trousseau d'une seule clé
    /// (`share`), sous le contexte
    /// `with_tenant(<organisation ou lyxal_installation>, "lyxal_secrets", "secrets_share",
    /// <empreinte>, "value")`.
    ///
    /// L'identifiant du partage n'existe qu'après sa création par `fn::secrets_share_create` :
    /// le contexte désigne donc le partage par l'**empreinte** de sa clé (SHA-256 en
    /// hexadécimal) au lieu de son identifiant. L'empreinte est propre à chaque clé tirée, la
    /// base la garde et le service la recalcule à l'ouverture : l'AAD n'est jamais vide, lie la
    /// copie à son organisation et à ce partage, et une enveloppe recopiée vers un autre partage
    /// ne s'ouvre pas.
    ///
    /// La base ne reçoit que l'enveloppe, l'empreinte et le hachage Argon2id du mot de passe ;
    /// la clé n'est rendue qu'ici ([`ShareCreated::key`]).
    pub async fn share_create(&self, request: ShareRequest) -> SecretsResult<ShareCreated> {
        let ShareRequest {
            tenant,
            source,
            max_views,
            ttl,
            passphrase,
            members_only,
            note,
        } = request;
        let scope = Scope::from_text(tenant.as_deref())?;
        let (value, secret, number) = match source {
            ShareSource::Text(value) => {
                let max = self
                    .keys
                    .system()
                    .settings_get(SettingsGetParams {
                        tenant: scope.tenant().map(str::to_string),
                    })
                    .await?
                    .effective
                    .max_value_bytes;
                let size = value.len();
                if i64::try_from(size).map_or(true, |size| size > max) {
                    return Err(SecretsError::ValueTooLarge { size, max });
                }
                (value, None, None)
            }
            ShareSource::Secret {
                secret,
                label,
                number,
            } => {
                let revealed = self
                    .reveal(RevealRequest {
                        secret: secret.clone(),
                        label,
                        number,
                    })
                    .await?;
                (revealed.value, Some(secret), Some(revealed.number))
            }
        };

        let mut material = vec![0u8; SHARE_KEY_BYTES];
        OsRng
            .try_fill_bytes(&mut material)
            .map_err(|_| CryptoError::RandomUnavailable)?;
        let material = SecretBytes::new(material)?;
        let fingerprint = sha256_hex(material.expose_secret());
        let key = SecretString::new(URL_SAFE_NO_PAD.encode(material.expose_secret()))?;
        let envelope = share_engine(material)?.seal(&value, &scope.share_context(&fingerprint)?)?;
        drop(value);

        let passphrase_hash = match passphrase {
            None => None,
            Some(passphrase) => Some(
                tokio::task::spawn_blocking(move || hash_password(&passphrase))
                    .await
                    .map_err(|_| SecretsError::CryptoUnavailable)??
                    .expose_phc()
                    .to_string(),
            ),
        };
        let share = self
            .caller
            .share_create(ShareCreateParams {
                tenant: scope.tenant().map(str::to_string),
                secret,
                number,
                envelope: envelope.encode(),
                key_fingerprint: fingerprint,
                passphrase_hash,
                max_views: max_views.map(i64::from),
                ttl,
                members_only,
                note,
            })
            .await?;
        Ok(ShareCreated { share, key })
    }

    /// Ouvre un lien et rend la copie. Contrôles, dans l'ordre : partage actif et non échu
    /// (chargé par la session système), empreinte de la clé (comparée en temps constant), mot de
    /// passe (Argon2id), appartenance à l'organisation pour un lien réservé (l'`opener` vient du
    /// jeton contrôlé par l'hôte). Ensuite seulement, une ouverture est consommée, atomiquement,
    /// puis la copie est ouverte.
    ///
    /// Une clé ou un mot de passe faux compte un essai (cinq et le partage est détruit) ; tout
    /// refus est `SECRETS_SHARE_UNAVAILABLE`, sans détail. Une copie qui ne s'ouvre pas malgré
    /// une empreinte juste est `SECRETS_VALUE_CORRUPTED`. Une panne de la base est rendue telle
    /// quelle.
    pub async fn share_open(&self, request: ShareOpen) -> SecretsResult<SecretBytes> {
        let ShareOpen {
            share,
            key,
            passphrase,
            opener,
        } = request;
        let system = self.keys.system();
        let loaded = unavailable_if_refused(
            system
                .share_load(ShareRefParams {
                    share: share.clone(),
                })
                .await,
        )?;
        let share = loaded.id.to_sql();

        // Clé du lien : décodée, puis son empreinte comparée à celle de la base
        let material = match URL_SAFE_NO_PAD.decode(key.expose_secret()) {
            Ok(bytes) if bytes.len() == SHARE_KEY_BYTES => SecretBytes::new(bytes)?,
            _ => return self.share_refused(&share).await,
        };
        drop(key);
        let fingerprint = sha256_hex(material.expose_secret());
        if !same_fingerprint(fingerprint.as_bytes(), loaded.key_fingerprint.as_bytes()) {
            return self.share_refused(&share).await;
        }

        if let Some(phc) = &loaded.passphrase_hash {
            let Some(passphrase) = passphrase else {
                return self.share_refused(&share).await;
            };
            let hash = PasswordHash::parse(phc).map_err(|_| SecretsError::ValueCorrupted)?;
            let verified = tokio::task::spawn_blocking(move || verify_password(&passphrase, &hash))
                .await
                .map_err(|_| SecretsError::CryptoUnavailable)??;
            if matches!(verified, PasswordVerification::Mismatch) {
                return self.share_refused(&share).await;
            }
        }

        // Lien réservé : un appelant connecté de la même organisation (pas un essai faux)
        let tenant = loaded.tenant.as_ref().map(ToSql::to_sql);
        if loaded.members_only
            && !opener
                .as_ref()
                .is_some_and(|opener| opener.organization == tenant)
        {
            return Err(SecretsError::ShareUnavailable);
        }

        unavailable_if_refused(
            system
                .share_consume(ShareConsumeParams {
                    share,
                    opener: opener.and_then(|opener| opener.identity),
                })
                .await,
        )?;
        let scope = Scope::from_record(loaded.tenant.as_ref())?;
        let envelope =
            EncryptedEnvelope::parse(&loaded.envelope).map_err(|_| SecretsError::ValueCorrupted)?;
        share_engine(material)?
            .open(&envelope, &scope.share_context(&loaded.key_fingerprint)?)
            .map_err(|_| SecretsError::ValueCorrupted)
    }

    /// Essai faux compté, puis le refus sans détail. Une panne de la base est rendue telle
    /// quelle ; un partage fini entre-temps (refus de la base) rend le même refus.
    async fn share_refused<T>(&self, share: &str) -> SecretsResult<T> {
        match self
            .keys
            .system()
            .share_fail(ShareRefParams {
                share: share.to_string(),
            })
            .await
        {
            Ok(failed) if failed.destroyed => {
                tracing::info!(share = %share, "partage détruit après cinq essais faux");
            }
            Ok(_) => {}
            Err(error) => {
                let error = SecretsError::from(error);
                if !error.is_business() {
                    return Err(error);
                }
            }
        }
        Err(SecretsError::ShareUnavailable)
    }
}

/// Moteur d'une seule clé : celle du lien.
fn share_engine(material: SecretBytes) -> SecretsResult<CryptoEngine<StaticKeyResolver>> {
    let mut builder = KeyRingBuilder::new();
    builder.insert(
        KeyId::parse(SHARE_KEY_ID)?,
        EncryptionKey::import(material)?,
        KeyUse::Active,
    )?;
    Ok(CryptoEngine::new(StaticKeyResolver::new(Arc::new(
        builder.build()?,
    ))))
}

/// Refus de la base (partage inconnu, fini, échu, identifiant invalide) : le refus sans détail ;
/// une panne est rendue telle quelle.
fn unavailable_if_refused<T>(
    result: Result<T, lyxal_surreal::LyxalSurrealError>,
) -> SecretsResult<T> {
    result.map_err(|error| {
        let error = SecretsError::from(error);
        if error.is_business() {
            SecretsError::ShareUnavailable
        } else {
            error
        }
    })
}

/// Comparaison en temps constant de deux empreintes hexadécimales (64 octets chacune).
///
/// Écrite ici plutôt qu'avec la crate `subtle` (absente des dépendances directes du crate et
/// réservée à `lyxal_crypto`) : chaque octet est comparé par `XOR`, les différences sont
/// accumulées par `OR` sans sortie anticipée, et `black_box` empêche le compilateur de
/// raccourcir la boucle. La longueur, elle, n'est pas secrète (toujours 64).
fn same_fingerprint(left: &[u8], right: &[u8]) -> bool {
    if left.len() != right.len() {
        return false;
    }
    let mut difference = 0u8;
    for (a, b) in left.iter().zip(right) {
        difference |= std::hint::black_box(a ^ b);
    }
    std::hint::black_box(difference) == 0
}

#[cfg(test)]
mod tests {
    use super::same_fingerprint;

    #[test]
    fn fingerprints_are_compared_byte_by_byte() {
        assert!(same_fingerprint(b"abcd", b"abcd"));
        assert!(!same_fingerprint(b"abcd", b"abce"));
        assert!(!same_fingerprint(b"abcd", b"abc"));
        assert!(same_fingerprint(b"", b""));
    }
}
