// SPDX-License-Identifier: AGPL-3.0-only

//! Dépôt authentifié des ports 587 et 465 (plan du lot 6, §8 et §16, décisions E14 et E30) :
//! l'hôte construit le service des mots de passe d'application de `lyxal_auth`
//! (`AppPasswordService`, sur sa session système et la **clé applicative** partagée avec
//! `lyxal-server`, lue de `LYXAL_GROUPWARE__CRYPTO__APPLICATION_KEY` seulement) et le remet à la
//! session de dépôt de `lyxal_mail` (`SubmissionHandler`).
//!
//! Une connexion réussie ouvre un client SurrealDB **au nom de l'utilisateur** : clone de la
//! connexion fixe de la session système, authentifié par le jeton d'accès rendu (accès
//! `lyxal_auth_<emplacement>`), comme les routes de `lyxal-server` ; le pool reste à la session
//! système. Les fonctions du dépôt s'y exécutent sous les droits de l'utilisateur, recalculés par
//! la base ; le jeton est renouvelé (`AppPasswordService::renew`) avant son expiration.

use crate::config::{GroupwareConfig, ENV_PREFIX};
use crate::error::GroupwareError;
use async_trait::async_trait;
use lyxal_auth::models::ClientInfo;
use lyxal_auth::{
    AppPasswordAttempt, AppPasswordLogin, AppPasswordService, AppProtocol, AuthError, AuthStore,
    SigningKeyService,
};
use lyxal_crypto::{SecretString, StaticKeyResolver};
use lyxal_host::database::Database;
use lyxal_mail::net::MemoryBudget;
use lyxal_mail::smtp::BlockList;
use lyxal_mail::submission::{
    AuthAttempt, AuthRefusal, SubmissionAuthenticator, SubmissionHandler, SubmissionServices,
    SubmissionUser,
};
use lyxal_mail::{MailIngest, MailStore};
use lyxal_storage::ContentScanner;
use lyxal_surreal::LyxalSurrealCall;
use std::sync::Arc;
use std::time::{Duration, Instant};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Permission qui donne le droit d'envoyer sous ses adresses (déclarée par `lyxal_mail`).
pub const SEND_PERMISSION: &str = "mail.send";
/// Un jeton d'accès est renouvelé quand il lui reste moins que cette durée.
const RENEW_MARGIN: Duration = Duration::from_secs(60);

type Service = AppPasswordService<StaticKeyResolver>;

/// Dépôt authentifié du nœud si une écoute `submission` est déclarée ; démarrage refusé sans la
/// clé applicative (`GROUPWARE_APPLICATION_KEY_MISSING`, décision E30).
pub fn submission_handler(
    config: &GroupwareConfig,
    database: &Database,
    ingest: &MailIngest,
    scanner: Option<Arc<dyn ContentScanner>>,
    budget: &MemoryBudget,
    blocks: &BlockList,
) -> Result<Option<SubmissionHandler>, GroupwareError> {
    if !config.has_submission_listener() {
        return Ok(None);
    }
    let crypto = lyxal_host::services::application_crypto(&config.crypto, ENV_PREFIX)?
        .ok_or(GroupwareError::ApplicationKeyMissing)?;
    let smtp = config
        .smtp
        .smtp_config()
        .ok_or_else(|| GroupwareError::Configuration {
            message: "smtp.hostname est obligatoire avec une écoute submission".into(),
        })?;
    let store = AuthStore::new(database.clone());
    let keys = Arc::new(SigningKeyService::new(store.clone(), crypto));
    let service = Arc::new(AppPasswordService::new(
        store,
        keys,
        config.database.namespace.clone(),
        config.database.database.clone(),
    ));
    let authenticator = Arc::new(GroupwareAuthenticator {
        service,
        connection: database.fixed().clone(),
    });
    let handler = SubmissionHandler::new(
        smtp,
        SubmissionServices {
            store: MailStore::new(database.clone()),
            ingest: ingest.clone(),
            budget: budget.clone(),
            blocks: blocks.clone(),
            authenticator,
            scanner,
        },
    )
    .map_err(|error| GroupwareError::Configuration {
        message: error.to_string(),
    })?;
    tracing::info!("dépôt authentifié : mots de passe d'application vérifiés par lyxal_auth");
    Ok(Some(handler))
}

/// Vérification des mots de passe d'application par `lyxal_auth`.
struct GroupwareAuthenticator {
    service: Arc<Service>,
    /// Connexion fixe de la session système, clonée pour chaque utilisateur.
    connection: Surreal<Any>,
}

/// Refus de `lyxal_auth` traduit pour la session : verrou de l'adresse, panne (base, clés), ou
/// identifiants refusés.
fn refusal(error: &AuthError) -> AuthRefusal {
    let business = match error {
        AuthError::Rejected(_) => true,
        AuthError::Surreal(inner) => matches!(
            inner.as_ref(),
            lyxal_surreal::LyxalSurrealError::Call(lyxal_surreal::LyxalCallError::Business(_))
        ),
        AuthError::Crypto(_) | AuthError::InvalidParameter(_) | AuthError::Dns(_) => false,
    };
    match error.code().as_str() {
        "AUTH_TOO_MANY_ATTEMPTS" => AuthRefusal::Locked,
        "AUTH_SIGNING_KEY_UNAVAILABLE" => AuthRefusal::Unavailable,
        _ if business => AuthRefusal::Invalid,
        _ => AuthRefusal::Unavailable,
    }
}

#[async_trait]
impl SubmissionAuthenticator for GroupwareAuthenticator {
    async fn authenticate(
        &self,
        attempt: AuthAttempt,
    ) -> Result<Box<dyn SubmissionUser>, AuthRefusal> {
        // Un mot de passe d'application est en ASCII : autre chose ne peut pas correspondre
        let password = std::str::from_utf8(attempt.credentials.password())
            .ok()
            .and_then(|text| SecretString::new(text.to_string()).ok())
            .ok_or(AuthRefusal::Invalid)?;
        let login = self
            .service
            .authenticate(AppPasswordAttempt {
                username: attempt.credentials.authcid().to_string(),
                password,
                protocol: AppProtocol::Smtp,
                client: ClientInfo {
                    ip: Some(attempt.client.to_string()),
                    user_agent: None,
                },
                client_name: None,
                secure: true,
            })
            .await
            .map_err(|error| {
                let refused = refusal(&error);
                if refused == AuthRefusal::Unavailable {
                    tracing::warn!(code = %error.code(), "vérification d'un mot de passe d'application en échec");
                }
                refused
            })?;
        if !login
            .session
            .permissions
            .iter()
            .any(|permission| permission == SEND_PERMISSION)
        {
            return Err(AuthRefusal::Forbidden);
        }
        // Session à part, clonée de la connexion fixe : le pool reste à la session système
        let mut user = GroupwareUser {
            service: self.service.clone(),
            store: MailStore::new(self.connection.clone()),
            login,
            renew_at: Instant::now(),
        };
        user.open().await?;
        Ok(Box::new(user))
    }
}

/// Utilisateur d'une session de dépôt : jeton d'accès et client SurrealDB à son nom.
struct GroupwareUser {
    service: Arc<Service>,
    /// Store sur le client SurrealDB authentifié par le jeton de l'utilisateur.
    store: MailStore,
    login: AppPasswordLogin,
    renew_at: Instant,
}

impl GroupwareUser {
    /// Authentifie le client par le jeton courant ; note quand le renouveler.
    async fn open(&mut self) -> Result<(), AuthRefusal> {
        self.store
            .surreal_client()
            .authenticate(self.login.access_token.expose_secret().to_string())
            .await
            .map_err(|error| {
                tracing::warn!(error = %error, "session SurrealDB de l'utilisateur refusée");
                AuthRefusal::Unavailable
            })?;
        let valid_for = Duration::from_secs(u64::try_from(self.login.expires_in).unwrap_or(0));
        self.renew_at = Instant::now() + valid_for.saturating_sub(RENEW_MARGIN);
        Ok(())
    }
}

#[async_trait]
impl SubmissionUser for GroupwareUser {
    async fn store(&mut self) -> Result<MailStore, AuthRefusal> {
        if Instant::now() >= self.renew_at {
            self.login = self.service.renew(&self.login).await.map_err(|error| {
                let refused = refusal(&error);
                if refused == AuthRefusal::Unavailable {
                    tracing::warn!(code = %error.code(), "renouvellement du jeton d'un dépôt en échec");
                }
                refused
            })?;
            if !self
                .login
                .session
                .permissions
                .iter()
                .any(|permission| permission == SEND_PERMISSION)
            {
                return Err(AuthRefusal::Forbidden);
            }
            self.open().await?;
        }
        Ok(self.store.clone())
    }
}
