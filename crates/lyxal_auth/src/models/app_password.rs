//! Contrats des mots de passe d'application (lot 1 du programme courrier, agendas et contacts) :
//! création, liste, journal, révocation, vérification par l'hôte des protocoles, renouvellement.
//! Aucune valeur secrète : la base reçoit des empreintes, masquées en `Debug`.

use lyxal_surreal::SurrealValue;

use super::access::{ClientInfo, SessionIssued};
use super::types::{AuthDatetime, AuthRecordId, AuthValue};

/// Paramètres de `fn::auth_app_password_create` (session système).
#[derive(Clone, SurrealValue)]
pub struct AppPasswordCreateParams {
    /// Session interactive de l'utilisateur (acteur, texte).
    pub session: String,
    /// Nom de l'appareil ou du logiciel.
    pub name: String,
    /// Permissions choisies.
    pub permissions: Vec<String>,
    /// Expiration (facultative ; la politique peut l'imposer).
    pub expires_at: Option<AuthDatetime>,
    /// HMAC-SHA256 de la forme normalisée du mot de passe.
    pub password_hash: String,
}

crate::models::redacted_debug!(AppPasswordCreateParams {
    shown: [session, name, permissions, expires_at],
    hidden: [password_hash]
});

/// Mot de passe d'application sans secret (création, liste).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AppPasswordSummary {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Nom de l'appareil.
    pub name: String,
    /// Organisation.
    pub organization: AuthRecordId,
    /// Permissions choisies.
    pub permissions: Vec<String>,
    /// Expiration.
    pub expires_at: Option<AuthDatetime>,
    /// État calculé : `active`, `expired`, `revoked`.
    pub state: String,
    /// Dernière connexion vérifiée.
    pub last_used_at: Option<AuthDatetime>,
    /// Protocole de la dernière connexion.
    pub last_used_protocol: Option<String>,
    /// Adresse IP de la dernière connexion.
    pub last_used_ip: Option<String>,
    /// Révocation.
    pub revoked_at: Option<AuthDatetime>,
    /// Motif de révocation.
    pub revoked_reason: Option<String>,
    /// Création.
    pub created_at: AuthDatetime,
}

/// Résultat de `fn::auth_app_password_create`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AppPasswordCreated {
    /// Mot de passe créé (sans secret).
    pub app_password: AppPasswordSummary,
    /// Identifiant à saisir dans le logiciel (adresse e-mail de connexion).
    pub username: String,
}

/// Paramètres de `fn::auth_app_password_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AppPasswordListParams {
    /// Identité (texte ; par défaut celle de la session).
    pub identity: Option<String>,
    /// Organisation (texte ; toutes si absente).
    pub organization: Option<String>,
}

/// Paramètres de `fn::auth_app_password_uses`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AppPasswordUsesParams {
    /// Mot de passe d'application (texte).
    pub app_password: String,
    /// Nombre maximal de lignes (1 à 1000 ; défaut 100).
    pub limit: Option<i64>,
}

/// Ligne du journal regroupé des connexions (protocole et adresse IP).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AppPasswordUse {
    /// Protocole.
    pub protocol: String,
    /// Adresse IP du client.
    pub ip: String,
    /// Logiciel (dernier connu).
    pub client_name: Option<String>,
    /// Première connexion.
    pub first_seen_at: AuthDatetime,
    /// Dernière connexion.
    pub last_seen_at: AuthDatetime,
    /// Nombre de connexions vérifiées.
    pub count: i64,
}

/// Paramètres de `fn::auth_app_password_revoke` (session système) : un mot de passe, ou tous
/// ceux d'une identité (dans une organisation ou toutes).
#[derive(Debug, Clone, SurrealValue)]
pub struct AppPasswordRevokeParams {
    /// Session de l'acteur (titulaire ou administrateur, texte).
    pub session: String,
    /// Mot de passe d'application (texte).
    pub app_password: Option<String>,
    /// Identité (texte).
    pub identity: Option<String>,
    /// Organisation (texte), avec `identity`.
    pub organization: Option<String>,
}

/// Résultat de `fn::auth_app_password_revoke`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct AppPasswordRevoked {
    /// Mots de passe révoqués par cet appel.
    pub revoked: i64,
}

/// Paramètres de `fn::auth_app_password_eligible` (aucun champ requis).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AppPasswordEligibleParams {
    /// Langue des messages d'erreur (défaut `fr`).
    pub language: Option<String>,
}

/// Permission que l'appelant peut donner à un mot de passe d'application.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct EligiblePermission {
    /// Code.
    pub code: String,
    /// Module déclarant.
    pub module: String,
    /// Description par langue (`{ fr, en }`).
    pub description: AuthValue,
}

/// Paramètres de `fn::auth_app_password_verify` (session système).
#[derive(Clone, SurrealValue)]
pub struct AppPasswordVerifyParams {
    /// HMAC-SHA256 de la forme normalisée du mot de passe présenté.
    pub password_hash: String,
    /// Identifiant présenté (adresse e-mail de connexion).
    pub identifier: String,
    /// BLAKE3 de l'identifiant normalisé (compteur d'échecs).
    pub identifier_hash: String,
    /// Protocole (`smtp`, `imap`, `pop3`, `managesieve`, `dav`, `jmap`).
    pub protocol: String,
    /// Appareil (adresse IP exigée).
    pub client: ClientInfo,
    /// Logiciel (en-tête `User-Agent` ou commande IMAP `ID`).
    pub client_name: Option<String>,
    /// BLAKE3 de l'adresse IP (compteur d'échecs).
    pub ip_hash: String,
    /// Accès SurrealDB du jeton (`a` ou `b`).
    pub access_slot: String,
}

crate::models::redacted_debug!(AppPasswordVerifyParams {
    shown: [protocol, client, client_name, access_slot],
    hidden: [password_hash, identifier, identifier_hash, ip_hash]
});

/// Paramètres de `fn::auth_app_password_failure_record` (session système) : saisie au mauvais
/// format, refusée sans recherche de l'empreinte mais comptée.
#[derive(Clone, SurrealValue)]
pub struct AppPasswordFailureParams {
    /// BLAKE3 de l'adresse IP.
    pub ip_hash: String,
    /// BLAKE3 de l'identifiant normalisé.
    pub identifier_hash: String,
}

crate::models::redacted_debug!(AppPasswordFailureParams {
    shown: [],
    hidden: [ip_hash, identifier_hash]
});

/// Paramètres de `fn::auth_app_password_session_renew` (session système).
#[derive(Debug, Clone, SurrealValue)]
pub struct AppPasswordSessionRenewParams {
    /// Session `app_password` (texte).
    pub session: String,
    /// Accès SurrealDB du jeton (`a` ou `b`).
    pub access_slot: String,
}

/// Ce que porte le jeton d'une session `app_password`, et le mot de passe d'application.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AppPasswordSessionIssued {
    /// Session.
    pub session: AuthRecordId,
    /// Identité.
    pub identity: Option<AuthRecordId>,
    /// Organisation du mot de passe.
    pub organization: Option<AuthRecordId>,
    /// Nature (`app_password`).
    pub kind: String,
    /// Permissions (celles du mot de passe encore détenues).
    pub permissions: Vec<String>,
    /// Version des droits.
    pub version: i64,
    /// Niveau d'assurance (1).
    pub aal: i64,
    /// Durée d'un jeton d'accès (secondes).
    pub access_seconds: i64,
    /// Expiration par inactivité.
    pub idle_expires_at: AuthDatetime,
    /// Expiration absolue de la session partagée.
    pub expires_at: AuthDatetime,
    /// Mot de passe d'application.
    pub app_password: AuthRecordId,
}

impl AppPasswordSessionIssued {
    /// Session émise (contrat commun des jetons) et mot de passe d'application.
    pub fn into_parts(self) -> (SessionIssued, AuthRecordId) {
        (
            SessionIssued {
                session: self.session,
                identity: self.identity,
                application: None,
                organization: self.organization,
                kind: self.kind,
                permissions: self.permissions,
                version: self.version,
                aal: self.aal,
                access_seconds: self.access_seconds,
                idle_expires_at: self.idle_expires_at,
                expires_at: self.expires_at,
                refresh_expires_at: None,
            },
            self.app_password,
        )
    }
}
