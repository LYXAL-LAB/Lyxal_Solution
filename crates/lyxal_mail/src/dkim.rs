// SPDX-License-Identifier: AGPL-3.0-only

//! Signature DKIM des messages sortants (plan du lot 6, §9 ; décision E18).
//!
//! * [`DkimKeyCache`] : clés privées lues dans `lyxal_secrets` (organisation du domaine, chemin
//!   `mail/dkim/<domaine>/<sélecteur>`), gardées 10 minutes dans le nœud, 1 024 au plus ; une clé
//!   qui n'est plus `active` n'est jamais servie (état relu par `fn::mail_dkim_signers` à chaque
//!   message).
//! * [`sign_headers`] : en-têtes `DKIM-Signature` (`relaxed/relaxed`, `t=` posé, ni `x=`, ni
//!   `l=`, ni `i=`) sur la liste d'en-têtes de Mox (`mox-/config.go`) étendue, sur-signée ;
//!   octets signés et signature par `lyxal_crypto::dkim` (règle 13 du §11.3), écriture des
//!   balises et repliement ici.
//! * [`DkimProvisioner`] : tâche `mail.dkim_provision` (toutes les 10 minutes) : deux clés par
//!   domaine actif (RSA 2 048 bits, générée hors de la boucle asynchrone, et Ed25519), rangées
//!   par `export_pkcs8` dans `lyxal_secrets` seulement, fiche publique `pending`, puis activation
//!   quand le DNS montre l'enregistrement publié.
//! * [`ReturnToken`] : jeton de l'adresse de retour `rp=<jeton>@<domaine>` (§11), 128 bits tirés
//!   par `OsRng`, base 32 de Crockford en minuscules.

use base64::engine::general_purpose::STANDARD;
use base64::Engine as _;
use lyxal_crypto::{
    DkimCanonicalization, DkimHeaderCanonicalizer, DkimSigningKey, Ed25519SigningKey,
    RsaModulusBits, RsaSigningKey,
};
use lyxal_secrets::models::{SecretCreateParams, Stage};
use lyxal_secrets::{ClientRead, ClientWrite, SecretsClient, SecretsStore};
use lyxal_surreal::ToSql;
use rand_core::{OsRng, RngCore};
use std::collections::HashMap;
use std::fmt;
use std::sync::{Arc, Mutex, PoisonError};
use std::time::{Duration, Instant};

use crate::auth::HeaderField;
use crate::dns::MailResolver;
use crate::error::{MailError, MailResult};
use crate::models::{
    DkimAlgorithm, DkimKeyActivateParams, DkimKeyCreateParams, DkimPendingParams, DkimSignerKey,
};
use crate::store::MailStore;
use crate::MODULE_ID;

/// En-têtes signés quand ils sont présents (Mox, étendu de `List-*` : RFC 8058).
pub const SIGNED_HEADERS: [&str; 16] = [
    "From",
    "To",
    "Cc",
    "Reply-To",
    "Subject",
    "Date",
    "Message-ID",
    "In-Reply-To",
    "References",
    "Content-Type",
    "MIME-Version",
    "Content-Transfer-Encoding",
    "Sender",
    "List-Id",
    "List-Unsubscribe",
    "List-Unsubscribe-Post",
];
/// En-têtes sur-signés : nommés une fois de plus que leurs occurrences dans `h=` (un en-tête
/// ajouté en chemin casse la signature).
pub const OVERSIGNED_HEADERS: [&str; 9] = [
    "From",
    "To",
    "Cc",
    "Subject",
    "Date",
    "Message-ID",
    "Reply-To",
    "Content-Type",
    "MIME-Version",
];
/// Durée de garde d'une clé ouverte.
pub const KEY_CACHE_TTL: Duration = Duration::from_secs(600);
/// Clés gardées au plus.
pub const KEY_CACHE_ENTRIES: usize = 1_024;
/// Colonne de repliement des en-têtes écrits.
const FOLD_COLUMN: usize = 72;

/// Clé de signature d'un domaine et son sélecteur.
#[derive(Clone)]
pub struct SigningIdentity {
    /// Domaine signataire (`d=`).
    pub domain: String,
    /// Sélecteur (`s=`).
    pub selector: String,
    /// Clé.
    pub key: Arc<DkimSigningKey>,
}

impl fmt::Debug for SigningIdentity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("SigningIdentity")
            .field("selector", &self.selector)
            .field("key", &"[REDACTED]")
            .finish_non_exhaustive()
    }
}

/// Clés DKIM ouvertes du nœud.
#[derive(Default)]
pub struct DkimKeyCache {
    entries: Mutex<HashMap<String, (Arc<DkimSigningKey>, Instant)>>,
}

impl DkimKeyCache {
    /// Cache vide.
    pub fn new() -> Self {
        Self::default()
    }

    /// Clé d'un signataire actif (`fn::mail_dkim_signers`) de l'organisation `tenant` : depuis le
    /// cache, sinon lue dans le coffre-fort (lecture tracée) et ouverte.
    pub async fn key(
        &self,
        secrets: &SecretsClient,
        tenant: &str,
        signer: &DkimSignerKey,
    ) -> MailResult<Arc<DkimSigningKey>> {
        let cache_key = format!("{tenant}|{}", signer.secret_path);
        {
            let entries = self.entries.lock().unwrap_or_else(PoisonError::into_inner);
            if let Some((key, loaded)) = entries.get(&cache_key) {
                if loaded.elapsed() < KEY_CACHE_TTL {
                    return Ok(key.clone());
                }
            }
        }
        let revealed = secrets
            .read(ClientRead {
                tenant: Some(tenant.to_string()),
                path: signer.secret_path.clone(),
                label: None,
            })
            .await?;
        let key = Arc::new(match signer.algorithm {
            DkimAlgorithm::RsaSha256 => {
                DkimSigningKey::Rsa(RsaSigningKey::import_pkcs8(revealed.value)?)
            }
            DkimAlgorithm::Ed25519Sha256 => {
                DkimSigningKey::Ed25519(Ed25519SigningKey::import_pkcs8(revealed.value)?)
            }
        });
        let mut entries = self.entries.lock().unwrap_or_else(PoisonError::into_inner);
        entries.retain(|_, (_, loaded)| loaded.elapsed() < KEY_CACHE_TTL);
        if entries.len() >= KEY_CACHE_ENTRIES {
            entries.clear();
        }
        entries.insert(cache_key, (key.clone(), Instant::now()));
        Ok(key)
    }

    /// Clés gardées.
    pub fn len(&self) -> usize {
        self.entries
            .lock()
            .unwrap_or_else(PoisonError::into_inner)
            .len()
    }

    /// Vrai si aucune clé n'est gardée.
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
}

/// Liste `h=` : chaque en-tête signé présent, autant de fois que ses occurrences, plus une fois
/// pour un en-tête sur-signé (présent ou non).
fn signed_names(fields: &[HeaderField<'_>]) -> Vec<&'static str> {
    let mut names = Vec::new();
    for name in SIGNED_HEADERS {
        let count = fields.iter().filter(|field| field.is(name)).count();
        let extra = usize::from(OVERSIGNED_HEADERS.contains(&name));
        names.extend(std::iter::repeat_n(name, count + extra));
    }
    names
}

/// Ajoute `value` à `out` replié : retour à la ligne avant une colonne de [`FOLD_COLUMN`]
/// (« \r\n\t »), seulement aux places de `breaks` (positions dans `value`).
fn fold_into(out: &mut String, column: &mut usize, piece: &str) {
    if *column + piece.len() > FOLD_COLUMN && *column > 1 {
        out.push_str("\r\n\t");
        *column = 1;
    }
    out.push_str(piece);
    *column += piece.len();
}

/// En-têtes `DKIM-Signature` (lignes CRLF) des identités `identities` sur un message dont les
/// champs d'en-tête sont `fields` (tels qu'envoyés) et dont l'empreinte du corps canonisé
/// `relaxed` est `body_hash`, à l'instant `timestamp` (secondes depuis 1970).
pub fn sign_headers(
    identities: &[SigningIdentity],
    fields: &[HeaderField<'_>],
    body_hash: &[u8; 32],
    timestamp: u64,
) -> MailResult<String> {
    let names = signed_names(fields);
    let bh = STANDARD.encode(body_hash);
    let mut headers = String::new();
    for identity in identities {
        let algorithm = identity.key.algorithm().as_tag();
        let mut value = format!(
            " v=1; a={algorithm}; c=relaxed/relaxed; d={}; s={};\r\n\tt={timestamp}; h=",
            identity.domain, identity.selector
        );
        let mut column = 1 + "t=; h=".len() + timestamp.to_string().len();
        for (index, name) in names.iter().enumerate() {
            let piece = if index + 1 == names.len() {
                format!("{name};")
            } else {
                format!("{name}:")
            };
            fold_into(&mut value, &mut column, &piece);
        }
        value.push_str("\r\n\tbh=");
        value.push_str(&bh);
        value.push_str(";\r\n\tb=");
        // Octets signés : en-têtes de h= (occurrences du bas vers le haut, RFC 6376 §5.4.2),
        // puis l'en-tête de signature, b= vide
        let mut canonicalizer = DkimHeaderCanonicalizer::new(DkimCanonicalization::Relaxed);
        let mut used: HashMap<&str, usize> = HashMap::new();
        for name in &names {
            let seen = used.entry(name).or_insert(0);
            let found = fields
                .iter()
                .rev()
                .filter(|field| field.is(name))
                .nth(*seen);
            *seen += 1;
            if let Some(field) = found {
                canonicalizer.push_header(field.name, field.value)?;
            }
        }
        let data = canonicalizer.finish(b"DKIM-Signature", value.as_bytes())?;
        let signature = STANDARD.encode(identity.key.sign(&data)?);
        let mut column = 3;
        for chunk in signature.as_bytes().chunks(64) {
            let piece = String::from_utf8_lossy(chunk);
            if column + piece.len() > FOLD_COLUMN {
                value.push_str("\r\n\t ");
                column = 2;
            }
            value.push_str(&piece);
            column += piece.len();
        }
        headers.push_str("DKIM-Signature:");
        headers.push_str(&value);
        headers.push_str("\r\n");
    }
    Ok(headers)
}

/// Jeton d'une adresse de retour : 26 caractères en base 32 de Crockford, minuscules (128 bits
/// tirés par `OsRng`). Le `Debug` le masque.
#[derive(Clone, PartialEq, Eq)]
pub struct ReturnToken(String);

/// Alphabet de Crockford, minuscules (sans `i`, `l`, `o`, `u`).
const CROCKFORD: &[u8; 32] = b"0123456789abcdefghjkmnpqrstvwxyz";

impl ReturnToken {
    /// Nouveau jeton.
    pub fn generate() -> MailResult<Self> {
        let mut bytes = [0u8; 16];
        OsRng
            .try_fill_bytes(&mut bytes)
            .map_err(|_| MailError::Unavailable("générateur aléatoire du système".into()))?;
        Ok(Self::from_bytes(bytes))
    }

    fn from_bytes(bytes: [u8; 16]) -> Self {
        let value = u128::from_be_bytes(bytes);
        let text = (0..26)
            .rev()
            .map(|index| {
                CROCKFORD[usize::try_from((value >> (index * 5)) & 31).unwrap_or(0)] as char
            })
            .collect();
        Self(text)
    }

    /// Texte du jeton.
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl fmt::Debug for ReturnToken {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("ReturnToken([REDACTED])")
    }
}

/// Bilan d'un passage de `mail.dkim_provision`.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct ProvisionReport {
    /// Clés créées (secret rangé, fiche `pending`).
    pub created: u64,
    /// Clés activées (enregistrement publié trouvé).
    pub activated: u64,
    /// Clés toujours en attente de publication.
    pub pending: u64,
    /// Domaines en échec ce passage (repris au suivant).
    pub failed: u64,
}

/// Tâche `mail.dkim_provision` : clés des domaines actifs, activation par le DNS.
#[derive(Clone)]
pub struct DkimProvisioner {
    store: MailStore,
    secrets_store: SecretsStore,
    secrets: SecretsClient,
    resolver: Arc<dyn MailResolver>,
    batch: i64,
}

/// Sélecteur d'un mois et d'un algorithme (`lyx<aaaamm>r`, `lyx<aaaamm>e`).
pub fn selector_for(year: i32, month: u8, algorithm: DkimAlgorithm) -> String {
    let suffix = match algorithm {
        DkimAlgorithm::RsaSha256 => 'r',
        DkimAlgorithm::Ed25519Sha256 => 'e',
    };
    format!("lyx{year:04}{month:02}{suffix}")
}

impl DkimProvisioner {
    /// Tâche sur la session système de l'hôte (`store`, `secrets_store`), coffre-fort
    /// `secrets` (consommateur `lyxal_mail`), résolveur du nœud.
    pub fn new(
        store: MailStore,
        secrets_store: SecretsStore,
        secrets: SecretsClient,
        resolver: Arc<dyn MailResolver>,
        batch: u32,
    ) -> Self {
        Self {
            store,
            secrets_store,
            secrets,
            resolver,
            batch: i64::from(batch.clamp(1, 1_000)),
        }
    }

    /// Un passage : clés manquantes créées, clés en attente activées si le DNS les montre.
    pub async fn run(&self) -> MailResult<ProvisionReport> {
        let work = self
            .store
            .dkim_pending(DkimPendingParams {
                limit: Some(self.batch),
            })
            .await?;
        let mut report = ProvisionReport::default();
        let now = time::OffsetDateTime::now_utc();
        for missing in &work.missing {
            let selector = selector_for(now.year(), u8::from(now.month()), missing.algorithm);
            match self
                .create(
                    &missing.tenant.to_sql(),
                    &missing.domain.to_sql(),
                    &missing.name,
                    &selector,
                    missing.algorithm,
                )
                .await
            {
                Ok(()) => report.created += 1,
                Err(error) => {
                    report.failed += 1;
                    tracing::warn!(code = %error.code(), "clé DKIM non créée : reprise au passage suivant");
                }
            }
        }
        for pending in &work.pending {
            let name = format!("{}._domainkey.{}", pending.selector, pending.name);
            let published = match self.resolver.txt(&name).await {
                Ok(answer) => answer.records.iter().any(|record| {
                    record_key(record).as_deref() == Some(pending.public_key.as_str())
                }),
                Err(_) => false,
            };
            if !published {
                report.pending += 1;
                continue;
            }
            match self
                .store
                .dkim_key_activate(DkimKeyActivateParams {
                    key: pending.key.to_sql(),
                })
                .await
            {
                Ok(_) => report.activated += 1,
                Err(error) => {
                    report.failed += 1;
                    tracing::warn!(code = %MailError::from(error).code(), "clé DKIM non activée");
                }
            }
        }
        Ok(report)
    }

    async fn create(
        &self,
        tenant: &str,
        domain: &str,
        name: &str,
        selector: &str,
        algorithm: DkimAlgorithm,
    ) -> MailResult<()> {
        let key = match algorithm {
            // Génération RSA hors de la boucle asynchrone (règle 12 du §11.3), attendue aussitôt
            DkimAlgorithm::RsaSha256 => tokio::task::spawn_blocking(|| {
                RsaSigningKey::generate(RsaModulusBits::Rsa2048).map(DkimSigningKey::Rsa)
            })
            .await
            .map_err(|_| MailError::Unavailable("génération de clé interrompue".into()))??,
            DkimAlgorithm::Ed25519Sha256 => DkimSigningKey::Ed25519(Ed25519SigningKey::generate()?),
        };
        let path = format!("mail/dkim/{name}/{selector}");
        let mut fiche = SecretCreateParams::new(Some(tenant.to_string()), &path, "signing_key");
        fiche.description = Some("Clé privée DKIM d'un domaine de courrier".into());
        fiche.consumers = vec![MODULE_ID.to_string()];
        match self.secrets_store.secret_create(fiche).await {
            Ok(_) => {}
            // Arrêt entre le secret et la fiche publique au passage précédent : secret réécrit
            Err(error) if error.is_business_code("SECRETS_SECRET_EXISTS") => {}
            Err(error) => return Err(MailError::from(error)),
        }
        let pkcs8 = match &key {
            DkimSigningKey::Rsa(rsa) => rsa.export_pkcs8(),
            DkimSigningKey::Ed25519(ed) => ed.export_pkcs8(),
        };
        self.secrets
            .write(ClientWrite {
                tenant: Some(tenant.to_string()),
                path: path.clone(),
                value: pkcs8,
                stage: Stage::Current,
            })
            .await?;
        self.store
            .dkim_key_create(DkimKeyCreateParams {
                domain: domain.to_string(),
                selector: selector.to_string(),
                algorithm,
                bits: matches!(algorithm, DkimAlgorithm::RsaSha256).then_some(2048),
                public_key: STANDARD.encode(key.public_key_record_bytes()),
                secret_path: path,
            })
            .await?;
        Ok(())
    }
}

/// Valeur de `p=` d'un enregistrement TXT DKIM (espaces retirés), s'il y en a une.
fn record_key(record: &str) -> Option<String> {
    record.split(';').find_map(|tag| {
        let (name, value) = tag.split_once('=')?;
        (name.trim() == "p").then(|| value.chars().filter(|c| !c.is_whitespace()).collect())
    })
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;
    use crate::auth::MessageHeaders;

    #[test]
    fn return_tokens_are_26_crockford_characters() {
        let token = ReturnToken::from_bytes([0xff; 16]);
        assert_eq!(token.as_str().len(), 26);
        assert!(token.as_str().bytes().all(|b| CROCKFORD.contains(&b)));
        assert_eq!(ReturnToken::from_bytes([0; 16]).as_str(), "0".repeat(26));
        let drawn = ReturnToken::generate().unwrap();
        assert_ne!(drawn, ReturnToken::generate().unwrap());
        assert_eq!(format!("{drawn:?}"), "ReturnToken([REDACTED])");
    }

    #[test]
    fn signed_names_oversign_and_skip_unsigned_headers() {
        let raw = b"From: a@alpha.test\r\nTo: b@ailleurs.test\r\nTo: c@ailleurs.test\r\nReceived: x\r\nSubject: s\r\n\r\nbody";
        let headers = MessageHeaders::parse(raw).unwrap();
        let names = signed_names(&headers.fields);
        assert_eq!(names.iter().filter(|n| **n == "From").count(), 2);
        assert_eq!(names.iter().filter(|n| **n == "To").count(), 3);
        assert_eq!(names.iter().filter(|n| **n == "Reply-To").count(), 1);
        assert!(!names.contains(&"Received"));
        assert!(!names.contains(&"In-Reply-To"), "absent et non sur-signé");
    }

    #[test]
    fn selectors_and_record_keys() {
        assert_eq!(
            selector_for(2026, 11, DkimAlgorithm::RsaSha256),
            "lyx202611r"
        );
        assert_eq!(
            selector_for(2027, 1, DkimAlgorithm::Ed25519Sha256),
            "lyx202701e"
        );
        assert_eq!(
            record_key("v=DKIM1; k=ed25519; p=abc def").as_deref(),
            Some("abcdef")
        );
        assert_eq!(record_key("v=DKIM1"), None);
    }
}
