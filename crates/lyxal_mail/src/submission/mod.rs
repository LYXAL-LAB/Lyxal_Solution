// SPDX-License-Identifier: AGPL-3.0-only

//! Dépôt authentifié des logiciels de courrier, ports 587 (STARTTLS exigé) et 465 (TLS
//! implicite) : plan du lot 6, §8 (décisions E14 à E17).
//!
//! La session est celle de la réception du lot 5 (machine d'états, lecture de `DATA` et de
//! `BDAT`, fins de ligne, budget mémoire, délais, limites de session), dans son rôle « dépôt » :
//!
//! * `AUTH PLAIN` et `LOGIN` (`lyxal_mail_proto::smtp::AuthExchange`), annoncés et acceptés
//!   seulement sous TLS ; `MAIL` avant TLS ou avant `AUTH` : `530 5.7.0` ;
//! * le mot de passe d'application est vérifié par l'hôte ([`SubmissionAuthenticator`] : service
//!   de `lyxal_auth`, droits recalculés par la base) ; l'utilisateur rendu ([`SubmissionUser`])
//!   donne un store SurrealDB **à son nom**, sous lequel s'exécutent `fn::mail_sender_check` et
//!   `fn::mail_submission_begin` (permissions de table et `fn::mail_can` appliqués par la base,
//!   aucune règle recopiée) ; trois échecs ferment la session (`421 4.7.0`) ; aucun bannissement
//!   réseau ;
//! * `MAIL FROM`, puis `From`, `Sender`, `Resent-From` et `Resent-Sender`, contrôlés par
//!   `fn::mail_sender_check` (`550 5.7.1`), puis une dernière fois par
//!   `fn::mail_submission_begin` ;
//! * à la fin des données : lecture MIME, exactement un `From`, `Bcc` et `Resent-Bcc` retirés,
//!   `Message-ID` et `Date` ajoutés s'ils manquent, antivirus, `Received` sans adresse IP ni
//!   compte, puis inscription dans la file (`fn::mail_submission_begin` au nom de
//!   l'utilisateur, fichier chiffré écrit par `lyxal_storage` et `fn::mail_submission_commit`
//!   sous la session système de l'hôte) ; `250` seulement après l'inscription, `451 4.3.0` sur
//!   toute panne avant.
//!
//! La signature DKIM, l'adresse de retour et le préfixe de l'envoi sont faits par le worker
//! d'envoi à la première réservation (`fn::mail_queue_prepare`), jamais avec les droits de
//! l'utilisateur.

mod message;
mod metrics;
mod queue;

pub use metrics::SubmissionMetrics;

use async_trait::async_trait;
use lyxal_mail_proto::smtp::Credentials;
use lyxal_storage::ContentScanner;
use std::collections::BTreeMap;
use std::net::IpAddr;
use std::sync::Arc;

use crate::delivery::AntivirusStage;
use crate::ingest::MailIngest;
use crate::net::{MailProtocol, MemoryBudget, Session, SessionEnd, SessionHandler};
use crate::smtp::handler::{Mode, Shared};
use crate::smtp::session::SmtpSession;
use crate::smtp::{BlockList, SmtpConfig, SmtpConfigError, SmtpMetrics};
use crate::store::MailStore;

pub(crate) use message::{
    normalize_address, prepare_message, sender_addresses, submission_received, SenderRefusal,
};

/// Échecs de `AUTH` tolérés dans une session : au troisième, `421 4.7.0` et fermeture.
pub const MAX_AUTH_FAILURES: u32 = 3;

/// Tentative d'authentification présentée par une session de dépôt.
#[derive(Debug)]
pub struct AuthAttempt {
    /// Identifiant (adresse de connexion du compte) et mot de passe d'application, lus par
    /// `AUTH` ; le mot de passe est effacé à la libération et masqué dans le `Debug`.
    pub credentials: Credentials,
    /// Adresse IP réelle du client (après PROXY).
    pub client: IpAddr,
}

/// Refus d'une authentification. Aucune donnée du client n'y figure.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum AuthRefusal {
    /// Identifiant ou mot de passe faux, révoqué ou expiré (`535 5.7.8`).
    Invalid,
    /// Authentification réussie, mais le mot de passe n'a pas la permission `mail.send`
    /// (`535 5.7.8`, aucun détail).
    Forbidden,
    /// Adresse du client bloquée par `lyxal_auth` après trop d'échecs (`421 4.7.0`, fermeture).
    Locked,
    /// Base ou service de clés indisponible (`454 4.7.0`, à réessayer).
    Unavailable,
}

impl AuthRefusal {
    /// Nom du motif (mesures, journal).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Invalid => "invalid",
            Self::Forbidden => "forbidden",
            Self::Locked => "locked",
            Self::Unavailable => "unavailable",
        }
    }
}

/// Vérification des mots de passe d'application, fournie par l'hôte (service de `lyxal_auth`) :
/// `lyxal_mail` ne dépend pas de `lyxal_auth`.
#[async_trait]
pub trait SubmissionAuthenticator: Send + Sync {
    /// Vérifie une tentative ; rend l'utilisateur authentifié, avec la permission `mail.send`.
    async fn authenticate(
        &self,
        attempt: AuthAttempt,
    ) -> Result<Box<dyn SubmissionUser>, AuthRefusal>;
}

/// Utilisateur authentifié d'une session de dépôt.
#[async_trait]
pub trait SubmissionUser: Send + Sync {
    /// Store au nom de l'utilisateur (client SurrealDB authentifié par son jeton d'accès) ; le
    /// jeton est renouvelé quand il expire pendant la session (droits recalculés par la base).
    /// Session révoquée ou expirée : [`AuthRefusal::Invalid`].
    async fn store(&mut self) -> Result<MailStore, AuthRefusal>;
}

/// Services remis par l'hôte au dépôt authentifié.
pub struct SubmissionServices {
    /// Session système de l'hôte (résolution des destinataires des domaines de l'installation).
    pub store: MailStore,
    /// Écriture chiffrée du fichier et mise en file (stockage de l'hôte).
    pub ingest: MailIngest,
    /// Budget mémoire des connexions du nœud (classe « réception SMTP » pour les messages).
    pub budget: MemoryBudget,
    /// Liste de blocage du nœud (appliquée à l'acceptation ; aucun bannissement écrit ici).
    pub blocks: BlockList,
    /// Vérification des mots de passe d'application.
    pub authenticator: Arc<dyn SubmissionAuthenticator>,
    /// Antivirus de `lyxal_storage`, s'il est configuré.
    pub scanner: Option<Arc<dyn ContentScanner>>,
}

/// Ce que le dépôt ajoute aux sessions partagées.
pub(crate) struct SubmissionShared {
    pub(crate) authenticator: Arc<dyn SubmissionAuthenticator>,
    pub(crate) ingest: MailIngest,
    pub(crate) antivirus: AntivirusStage,
    pub(crate) metrics: Arc<SubmissionMetrics>,
}

/// Dépôt authentifié (écoutes `protocol = "submission"`). Clonable : les clones partagent les
/// mesures.
#[derive(Clone)]
pub struct SubmissionHandler {
    shared: Arc<Shared>,
    metrics: Arc<SubmissionMetrics>,
}

impl SubmissionHandler {
    /// Dépôt sous les réglages `config` (ceux de la session SMTP, contrôlés ici : nom de l'hôte,
    /// taille, destinataires, délais, limites de session).
    pub fn new(config: SmtpConfig, services: SubmissionServices) -> Result<Self, SmtpConfigError> {
        let metrics = Arc::new(SubmissionMetrics::default());
        let mode = Mode::Submission(SubmissionShared {
            authenticator: services.authenticator,
            ingest: services.ingest,
            antivirus: AntivirusStage::new(services.scanner),
            metrics: metrics.clone(),
        });
        Ok(Self {
            shared: Arc::new(Shared::new(
                config,
                services.store,
                services.budget,
                services.blocks,
                Arc::new(SmtpMetrics::default()),
                mode,
            )?),
            metrics,
        })
    }

    /// Réglages en vigueur.
    pub fn config(&self) -> &SmtpConfig {
        &self.shared.config
    }

    /// Mesures du dépôt (aucune adresse, aucun compte) : sessions, messages acceptés et refusés
    /// par motif, destinataires, authentifications par issue, usurpations refusées.
    pub fn snapshot(&self) -> BTreeMap<String, u64> {
        let mut values = self.shared.metrics.snapshot();
        // Compteurs de la réception sans objet pour le dépôt
        values.retain(|name, _| {
            !["spf.", "dkim.", "dmarc.", "dns_", "duplicates_avoided"]
                .iter()
                .any(|prefix| name.starts_with(prefix))
        });
        values.extend(self.metrics.snapshot());
        values
    }
}

#[async_trait]
impl SessionHandler for SubmissionHandler {
    fn protocol(&self) -> MailProtocol {
        MailProtocol::Submission
    }

    async fn handle(&self, session: Session) -> SessionEnd {
        SmtpSession::new(self.shared.clone(), session).run().await
    }
}
