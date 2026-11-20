//! Mots de passe d'application (lot 1 du programme courrier, agendas et contacts) : ce qui
//! relève du système — tirage du mot de passe (`OsRng`), normalisation de la saisie, empreinte
//! HMAC-SHA256 (clé `code_pepper`), empreintes BLAKE3 de l'adresse IP et de l'identifiant,
//! signature du jeton d'accès, mémoire courte des vérifications réussies (HTTP Basic). Les
//! règles (droits, politique, essais, révocations, session partagée) sont dans les fonctions
//! `fn::auth_app_password_*`.
//!
//! C'est l'API de l'hôte des protocoles (`lyxal-groupware`, lots 3 et suivants) :
//! [`AppPasswordService::authenticate`] après `AUTH PLAIN` / `AUTH LOGIN` / `LOGIN` /
//! `USER`+`PASS` / HTTP Basic, puis [`AppPasswordService::renew`] à l'expiration du jeton d'une
//! connexion longue. Tout refus est une [`AuthError`] (`AUTH_*`), que l'hôte traduit en réponse
//! d'échec du protocole sans détail pour le client.

use lyxal_crypto::{blake3_hex, sign_hmac_sha256_hex, KeyResolver, SecretString};
use lyxal_surreal::ToSql;
use rand_core::{OsRng, RngCore};
use std::collections::{BTreeMap, HashMap};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::sync::Mutex;
use zeroize::Zeroizing;

use crate::error::{AuthError, AuthResult};
use crate::models::{
    AppPasswordCreateParams, AppPasswordFailureParams, AppPasswordRevokeParams,
    AppPasswordSessionIssued, AppPasswordSessionRenewParams, AppPasswordSummary,
    AppPasswordVerifyParams, AuthDatetime, AuthRecordId, ClientInfo, SessionCaller, SessionIssued,
};
use crate::services::keys::SigningKeyService;
use crate::services::tokens::access_token;
use crate::store::AuthStore;

/// Alphabet du mot de passe : 31 signes sans ambiguïté (ni `0`/`o`, ni `1`/`l`/`i`), celui des
/// codes de secours.
const ALPHABET: &[u8] = b"23456789abcdefghjkmnpqrstuvwxyz";
/// Nombre de signes tirés (≈ 99 bits d'aléa).
const LENGTH: usize = 20;
/// Taille d'un groupe affiché.
const GROUP: usize = 5;
/// Séparation des usages de la clé `code_pepper` (codes de secours, codes à 6 chiffres).
const HASH_DOMAIN: &str = "lyxal_auth.app_password:";
/// Entrées au plus dans la mémoire courte des vérifications réussies.
pub const LOGIN_CACHE_CAPACITY: usize = 10_000;
/// Une vérification gardée en mémoire cesse de servir une minute avant l'expiration de son jeton.
const LOGIN_CACHE_MARGIN: Duration = Duration::from_secs(60);

/// Protocole qui présente le mot de passe (journal des connexions).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AppProtocol {
    /// Envoi de courrier (soumission SMTP).
    Smtp,
    /// Lecture de courrier IMAP.
    Imap,
    /// Lecture de courrier POP3.
    Pop3,
    /// Gestion des filtres Sieve.
    ManageSieve,
    /// Agendas et contacts (CalDAV, CardDAV).
    Dav,
    /// JMAP.
    Jmap,
}

impl AppProtocol {
    /// Nom enregistré (`smtp`, `imap`, `pop3`, `managesieve`, `dav`, `jmap`).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Smtp => "smtp",
            Self::Imap => "imap",
            Self::Pop3 => "pop3",
            Self::ManageSieve => "managesieve",
            Self::Dav => "dav",
            Self::Jmap => "jmap",
        }
    }
}

/// Tentative de connexion présentée par l'hôte des protocoles.
pub struct AppPasswordAttempt {
    /// Identifiant saisi dans le logiciel (adresse e-mail de connexion).
    pub username: String,
    /// Mot de passe saisi.
    pub password: SecretString,
    /// Protocole.
    pub protocol: AppProtocol,
    /// Appareil (adresse IP exigée).
    pub client: ClientInfo,
    /// Logiciel (en-tête `User-Agent` ou commande IMAP `ID`).
    pub client_name: Option<String>,
    /// Connexion chiffrée (TLS, ou HTTPS terminé par un proxy de confiance).
    pub secure: bool,
}

impl std::fmt::Debug for AppPasswordAttempt {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AppPasswordAttempt")
            .field("username", &"[REDACTED]")
            .field("password", &"[REDACTED]")
            .field("protocol", &self.protocol)
            .field("client", &self.client)
            .field("client_name", &self.client_name)
            .field("secure", &self.secure)
            .finish()
    }
}

/// Connexion réussie : jeton d'accès (au nom de l'utilisateur, jamais remis au logiciel),
/// session partagée, droits, expiration.
pub struct AppPasswordLogin {
    /// Jeton d'accès (JWT), accepté par l'accès SurrealDB `lyxal_auth_<emplacement>`.
    pub access_token: SecretString,
    /// Durée de validité du jeton (secondes).
    pub expires_in: i64,
    /// Session `app_password`.
    pub session: SessionIssued,
    /// Mot de passe d'application.
    pub app_password: AuthRecordId,
}

impl std::fmt::Debug for AppPasswordLogin {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AppPasswordLogin")
            .field("access_token", &"[REDACTED]")
            .field("expires_in", &self.expires_in)
            .field("session", &self.session.session)
            .field("permissions", &self.session.permissions)
            .field("app_password", &self.app_password)
            .finish()
    }
}

impl AppPasswordLogin {
    fn duplicate(&self) -> AuthResult<Self> {
        Ok(Self {
            access_token: SecretString::new(self.access_token.expose_secret().to_string())?,
            expires_in: self.expires_in,
            session: self.session.clone(),
            app_password: self.app_password.clone(),
        })
    }
}

/// Mot de passe d'application créé, affiché une seule fois.
pub struct AppPasswordIssued {
    /// Mot de passe (sans secret).
    pub summary: AppPasswordSummary,
    /// Identifiant à saisir dans le logiciel.
    pub username: String,
    /// Mot de passe en 4 groupes de 5 (`7kq2m-x9tab-hc4wp-3nrfe`), seule fois où il existe en
    /// clair.
    pub password: SecretString,
}

impl std::fmt::Debug for AppPasswordIssued {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AppPasswordIssued")
            .field("summary", &self.summary)
            .field("username", &self.username)
            .field("password", &"[REDACTED]")
            .finish()
    }
}

/// Mots de passe visés par une révocation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AppPasswordTarget {
    /// Un mot de passe (texte `auth_app_password:<clé>`).
    One(String),
    /// Tous ceux d'une identité, dans une organisation ou toutes.
    Identity {
        /// Identité (texte).
        identity: String,
        /// Organisation (texte) ; toutes si absente.
        organization: Option<String>,
    },
}

struct CachedLogin {
    valid_until: Instant,
    order: u64,
    login: AppPasswordLogin,
}

/// Mémoire courte des vérifications réussies (HTTP Basic renvoie le mot de passe à chaque
/// requête) : bornée, sans tâche de fond, entrées expirées retirées à la lecture, aucun échec
/// gardé. Clé : empreinte du mot de passe, identifiant, protocole et adresse IP.
#[derive(Default)]
struct LoginCache {
    entries: HashMap<String, CachedLogin>,
    arrivals: BTreeMap<u64, String>,
    next: u64,
}

impl LoginCache {
    fn get(&mut self, key: &str) -> Option<&AppPasswordLogin> {
        let expired = self
            .entries
            .get(key)
            .is_some_and(|entry| entry.valid_until <= Instant::now());
        if expired {
            self.remove(key);
        }
        self.entries.get(key).map(|entry| &entry.login)
    }

    fn insert(&mut self, key: String, login: AppPasswordLogin, valid_for: Duration) {
        if valid_for.is_zero() {
            return;
        }
        self.remove(&key);
        while self.entries.len() >= LOGIN_CACHE_CAPACITY {
            let Some((_, oldest)) = self.arrivals.pop_first() else {
                break;
            };
            self.entries.remove(&oldest);
        }
        let order = self.next;
        self.next += 1;
        self.arrivals.insert(order, key.clone());
        self.entries.insert(
            key,
            CachedLogin {
                valid_until: Instant::now() + valid_for,
                order,
                login,
            },
        );
    }

    fn remove(&mut self, key: &str) {
        if let Some(entry) = self.entries.remove(key) {
            self.arrivals.remove(&entry.order);
        }
    }

    /// Retire toute entrée dont le mot de passe ou l'identité est visé par une révocation.
    fn forget(&mut self, target: &AppPasswordTarget) {
        let stale: Vec<String> = self
            .entries
            .iter()
            .filter(|(_, entry)| match target {
                AppPasswordTarget::One(app_password) => {
                    entry.login.app_password.to_sql() == *app_password
                }
                AppPasswordTarget::Identity {
                    identity,
                    organization,
                } => {
                    entry.login.session.identity.as_ref().map(|i| i.to_sql())
                        == Some(identity.clone())
                        && organization.as_ref().is_none_or(|organization| {
                            entry
                                .login
                                .session
                                .organization
                                .as_ref()
                                .map(|o| o.to_sql())
                                == Some(organization.clone())
                        })
                }
            })
            .map(|(key, _)| key.clone())
            .collect();
        for key in stale {
            self.remove(&key);
        }
    }

    fn len(&self) -> usize {
        self.entries.len()
    }
}

/// Service des mots de passe d'application, sur la session système de l'hôte.
pub struct AppPasswordService<R: KeyResolver> {
    store: AuthStore,
    keys: Arc<SigningKeyService<R>>,
    namespace: String,
    database: String,
    cache: Mutex<LoginCache>,
}

impl<R: KeyResolver + 'static> AppPasswordService<R> {
    /// Service sur la session système, les clés de l'hôte et l'espace de noms et la base des
    /// jetons (claims `ns`, `db`).
    pub fn new(
        store: AuthStore,
        keys: Arc<SigningKeyService<R>>,
        namespace: String,
        database: String,
    ) -> Self {
        Self {
            store,
            keys,
            namespace,
            database,
            cache: Mutex::new(LoginCache::default()),
        }
    }

    /// Crée un mot de passe d'application pour l'utilisateur de la session interactive `caller`
    /// (action sensible, revérifiée par la base) ; le mot de passe n'est rendu qu'ici.
    pub async fn create(
        &self,
        caller: &SessionCaller,
        name: &str,
        permissions: Vec<String>,
        expires_at: Option<AuthDatetime>,
    ) -> AuthResult<AppPasswordIssued> {
        if caller.kind != "interactive" || caller.identity.is_none() {
            return Err(AuthError::Rejected("AUTH_PERMISSION_DENIED"));
        }
        let password = app_password()?;
        let normalized = normalize_app_password(password.expose_secret())
            .ok_or(AuthError::Rejected("AUTH_APP_PASSWORD_INVALID"))?;
        let created = self
            .store
            .app_password_create(AppPasswordCreateParams {
                session: caller.session.to_sql(),
                name: name.to_string(),
                permissions,
                expires_at,
                password_hash: self.password_hash(&normalized).await?,
            })
            .await?;
        Ok(AppPasswordIssued {
            summary: created.app_password,
            username: created.username,
            password,
        })
    }

    /// Vérifie une tentative de connexion d'un logiciel : connexion chiffrée exigée, saisie au
    /// mauvais format refusée sans recherche de l'empreinte (échec compté), mémoire courte, puis
    /// vérification en base (session `app_password` partagée, droits recalculés, journal).
    pub async fn authenticate(&self, attempt: AppPasswordAttempt) -> AuthResult<AppPasswordLogin> {
        // Une seule règle pour tous les protocoles, avant tout calcul (A13)
        if !attempt.secure {
            return Err(AuthError::Rejected("AUTH_APP_PASSWORD_INSECURE_TRANSPORT"));
        }
        let ip = attempt
            .client
            .ip
            .clone()
            .filter(|ip| !ip.is_empty())
            .ok_or(AuthError::Rejected("AUTH_INVALID_PARAMETERS"))?;
        let identifier = attempt.username.trim().to_lowercase();
        let identifier_hash = blake3_hex(identifier.as_bytes());
        let ip_hash = blake3_hex(ip.as_bytes());
        let Some(normalized) = normalize_app_password(attempt.password.expose_secret()) else {
            let status = self
                .store
                .app_password_failure_record(AppPasswordFailureParams {
                    ip_hash,
                    identifier_hash,
                })
                .await?;
            return Err(AuthError::Rejected(if status.locked {
                "AUTH_TOO_MANY_ATTEMPTS"
            } else {
                "AUTH_APP_PASSWORD_INVALID"
            }));
        };
        let password_hash = self.password_hash(&normalized).await?;
        let cache_key = blake3_hex(
            format!(
                "{password_hash}\u{0}{identifier}\u{0}{}\u{0}{ip}",
                attempt.protocol.as_str()
            )
            .as_bytes(),
        );
        if let Some(login) = self.cache.lock().await.get(&cache_key) {
            return login.duplicate();
        }
        let issued = self
            .store
            .app_password_verify(AppPasswordVerifyParams {
                password_hash,
                identifier,
                identifier_hash,
                protocol: attempt.protocol.as_str().to_string(),
                client: attempt.client,
                client_name: attempt.client_name,
                ip_hash,
                access_slot: self.keys.signing_key().await?.slot.clone(),
            })
            .await?;
        let login = self.login(issued).await?;
        let valid_for = Duration::from_secs(u64::try_from(login.expires_in).unwrap_or(0))
            .saturating_sub(LOGIN_CACHE_MARGIN);
        self.cache
            .lock()
            .await
            .insert(cache_key, login.duplicate()?, valid_for);
        Ok(login)
    }

    /// Nouveau jeton pour la même session (connexion longue), sans redemander le mot de passe :
    /// mot de passe et session revérifiés, droits recalculés. Session expirée :
    /// `AUTH_SESSION_EXPIRED`, le logiciel se reconnecte.
    pub async fn renew(&self, login: &AppPasswordLogin) -> AuthResult<AppPasswordLogin> {
        let issued = self
            .store
            .app_password_session_renew(AppPasswordSessionRenewParams {
                session: login.session.session.to_sql(),
                access_slot: self.keys.signing_key().await?.slot.clone(),
            })
            .await?;
        self.login(issued).await
    }

    /// Révoque un mot de passe, ou tous ceux d'une identité, au nom de `actor` (titulaire, ou
    /// administrateur : action sensible, revérifiée par la base) ; rend le nombre révoqué. Les
    /// vérifications gardées en mémoire pour eux sont oubliées.
    pub async fn revoke(
        &self,
        actor: &SessionCaller,
        target: AppPasswordTarget,
    ) -> AuthResult<i64> {
        let params = match &target {
            AppPasswordTarget::One(app_password) => AppPasswordRevokeParams {
                session: actor.session.to_sql(),
                app_password: Some(app_password.clone()),
                identity: None,
                organization: None,
            },
            AppPasswordTarget::Identity {
                identity,
                organization,
            } => AppPasswordRevokeParams {
                session: actor.session.to_sql(),
                app_password: None,
                identity: Some(identity.clone()),
                organization: organization.clone(),
            },
        };
        let revoked = self.store.app_password_revoke(params).await?.revoked;
        self.cache.lock().await.forget(&target);
        Ok(revoked)
    }

    /// Nombre de vérifications gardées en mémoire.
    pub async fn cached_logins(&self) -> usize {
        self.cache.lock().await.len()
    }

    async fn password_hash(&self, normalized: &str) -> AuthResult<String> {
        let pepper = self.keys.code_pepper().await?;
        let input = Zeroizing::new(format!("{HASH_DOMAIN}{normalized}"));
        Ok(sign_hmac_sha256_hex(&pepper, input.as_bytes())?)
    }

    async fn login(&self, issued: AppPasswordSessionIssued) -> AuthResult<AppPasswordLogin> {
        let (session, app_password) = issued.into_parts();
        let key = self.keys.signing_key().await?;
        Ok(AppPasswordLogin {
            access_token: access_token(&key, &self.namespace, &self.database, &session)?,
            expires_in: session.access_seconds,
            session,
            app_password,
        })
    }
}

/// Mot de passe d'application : 20 signes tirés uniformément (`OsRng`, tirage par rejet),
/// affichés en 4 groupes de 5 séparés par des tirets.
fn app_password() -> AuthResult<SecretString> {
    let mut text = Zeroizing::new(String::with_capacity(LENGTH + LENGTH / GROUP));
    let limit = 256 - (256 % ALPHABET.len());
    let mut drawn = 0;
    while drawn < LENGTH {
        let mut byte = [0u8; 1];
        OsRng
            .try_fill_bytes(&mut byte)
            .map_err(|_| AuthError::Crypto(lyxal_crypto::CryptoError::RandomUnavailable))?;
        if usize::from(byte[0]) >= limit {
            continue;
        }
        if drawn > 0 && drawn % GROUP == 0 {
            text.push('-');
        }
        text.push(char::from(ALPHABET[usize::from(byte[0]) % ALPHABET.len()]));
        drawn += 1;
    }
    Ok(SecretString::new(text.to_string())?)
}

/// Forme comparée d'une saisie : majuscules, espaces et tirets ignorés ; tout autre caractère
/// ou une longueur fausse : aucune (refus sans recherche en base).
fn normalize_app_password(input: &str) -> Option<Zeroizing<String>> {
    let mut normalized = Zeroizing::new(String::with_capacity(LENGTH));
    for c in input.chars() {
        if c == '-' || c.is_whitespace() {
            continue;
        }
        let lower = c.to_ascii_lowercase();
        if !lower.is_ascii() || !ALPHABET.contains(&(lower as u8)) {
            return None;
        }
        normalized.push(lower);
    }
    (normalized.len() == LENGTH).then_some(normalized)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn passwords_have_four_groups_of_the_unambiguous_alphabet() {
        let mut seen = std::collections::HashSet::new();
        for _ in 0..200 {
            let password = app_password().expect("mot de passe");
            let text = password.expose_secret();
            assert_eq!(text.len(), 23, "{}", text.len());
            let groups: Vec<&str> = text.split('-').collect();
            assert_eq!(groups.len(), 4);
            assert!(groups.iter().all(|g| g.len() == GROUP));
            assert!(groups
                .iter()
                .all(|g| g.bytes().all(|b| ALPHABET.contains(&b))));
            assert!(seen.insert(text.to_string()), "tirage répété");
        }
    }

    #[test]
    fn the_draw_is_spread_over_the_whole_alphabet() {
        // 31 signes, environ 99 bits : chaque signe apparaît sur un échantillon suffisant
        let mut counts = [0usize; 31];
        for _ in 0..300 {
            let password = app_password().expect("mot de passe");
            for b in password.expose_secret().bytes().filter(|b| *b != b'-') {
                let index = ALPHABET.iter().position(|a| *a == b).expect("signe");
                counts[index] += 1;
            }
        }
        // 6 000 signes : environ 194 par signe ; un tirage biaisé ou tronqué en oublierait
        assert!(counts.iter().all(|c| *c > 100), "{counts:?}");
        let entropy = (LENGTH as f64) * (ALPHABET.len() as f64).log2();
        assert!(entropy > 99.0 && entropy < 100.0, "{entropy}");
    }

    #[test]
    fn input_is_normalized_and_malformed_input_refused() {
        let expected = "7kq2mx9tabhc4wp3nrfe";
        for typed in [
            "7kq2m-x9tab-hc4wp-3nrfe",
            "7KQ2M-X9TAB-HC4WP-3NRFE",
            " 7kq2m x9tab hc4wp 3nrfe ",
            "7kq2mx9tabhc4wp3nrfe",
            "7Kq2m-x9TAB hc4wp-3nrfE",
        ] {
            assert_eq!(
                normalize_app_password(typed).as_deref().map(|s| s.as_str()),
                Some(expected),
                "{typed}"
            );
        }
        for refused in [
            "",
            "7kq2m-x9tab-hc4wp-3nrf",
            "7kq2m-x9tab-hc4wp-3nrfee",
            "7kq2m-x9tab-hc4wp-3nrf0",
            "7kq2m-x9tab-hc4wp-3nrfl",
            "7kq2m_x9tab-hc4wp-3nrfe",
            "7kq2m-x9tab-hc4wp-3nrfé",
        ] {
            assert!(normalize_app_password(refused).is_none(), "{refused}");
        }
    }

    #[test]
    fn secrets_are_redacted_in_debug() {
        let attempt = AppPasswordAttempt {
            username: "claire@exemple.fr".into(),
            password: SecretString::new("7kq2m-x9tab-hc4wp-3nrfe".into()).expect("secret"),
            protocol: AppProtocol::Imap,
            client: ClientInfo {
                ip: Some("203.0.113.5".into()),
                user_agent: None,
            },
            client_name: None,
            secure: true,
        };
        let text = format!("{attempt:?}");
        assert!(
            !text.contains("7kq2m") && !text.contains("claire"),
            "{text}"
        );
        assert!(
            text.contains("[REDACTED]") && text.contains("Imap"),
            "{text}"
        );
        let params = AppPasswordVerifyParams {
            password_hash: "ab12".repeat(16),
            identifier: "claire@exemple.fr".into(),
            identifier_hash: "cd34".repeat(16),
            protocol: "imap".into(),
            client: ClientInfo::default(),
            client_name: None,
            ip_hash: "ef56".repeat(16),
            access_slot: "a".into(),
        };
        let text = format!("{params:?}");
        assert!(
            !text.contains("ab12") && !text.contains("cd34") && !text.contains("ef56"),
            "{text}"
        );
        assert!(!text.contains("claire"), "{text}");
    }

    #[test]
    fn protocols_have_their_stored_names() {
        let names: Vec<&str> = [
            AppProtocol::Smtp,
            AppProtocol::Imap,
            AppProtocol::Pop3,
            AppProtocol::ManageSieve,
            AppProtocol::Dav,
            AppProtocol::Jmap,
        ]
        .into_iter()
        .map(AppProtocol::as_str)
        .collect();
        assert_eq!(
            names,
            ["smtp", "imap", "pop3", "managesieve", "dav", "jmap"]
        );
    }
}
