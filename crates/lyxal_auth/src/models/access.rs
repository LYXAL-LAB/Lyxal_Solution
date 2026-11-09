//! Contrats du lot 3 : mots de passe, parcours, codes, sessions, clés de signature, comptes de
//! service, clés d'API, purge. Paramètres construits par les services Rust (empreintes, secrets
//! scellés) ; jamais de valeur secrète en clair.

use lyxal_surreal::SurrealValue;

use super::types::{AuthDatetime, AuthRecordId};

/// Appareil à l'origine d'une requête.
#[derive(Debug, Clone, Default, PartialEq, SurrealValue)]
pub struct ClientInfo {
    /// Adresse IP.
    pub ip: Option<String>,
    /// Agent utilisateur.
    pub user_agent: Option<String>,
}

/// Paramètres de `fn::auth_password_credential_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PasswordCredentialParams {
    /// Identifiant (e-mail).
    pub identifier: String,
}

/// Résultat de `fn::auth_password_credential_get` (identité absente si identifiant inconnu).
#[derive(Clone, SurrealValue)]
pub struct PasswordCredential {
    /// Identité.
    pub identity: Option<AuthRecordId>,
    /// Identifiant normalisé.
    pub identifier: String,
    /// État de l'identité.
    pub state: Option<String>,
    /// Empreinte scellée (`enc:v2`).
    pub secret: Option<String>,
    /// Actions imposées.
    pub required_actions: Vec<String>,
}

impl std::fmt::Debug for PasswordCredential {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("PasswordCredential")
            .field("identity", &self.identity)
            .field("state", &self.state)
            .field("secret", &self.secret.as_ref().map(|_| "[REDACTED]"))
            .field("required_actions", &self.required_actions)
            .finish_non_exhaustive()
    }
}

/// Paramètres de `fn::auth_password_set`.
#[derive(Clone, SurrealValue)]
pub struct PasswordSetParams {
    /// Identité (texte).
    pub identity: String,
    /// Empreinte et historique scellés (`enc:v2`).
    pub secret: String,
    /// Révoquer les autres sessions.
    pub revoke_sessions: bool,
    /// Session conservée.
    pub except_session: Option<String>,
}

impl std::fmt::Debug for PasswordSetParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("PasswordSetParams")
            .field("identity", &self.identity)
            .field("revoke_sessions", &self.revoke_sessions)
            .finish_non_exhaustive()
    }
}

/// Résultat de `fn::auth_password_set`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct PasswordSet {
    /// Identifiant d'accès.
    pub credential: AuthRecordId,
    /// Sessions révoquées.
    pub sessions_revoked: i64,
}

/// Paramètres de `fn::auth_flow_start`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct FlowStartParams {
    /// Type de parcours.
    #[surreal(rename = "type")]
    pub flow_type: String,
    /// État initial (défaut selon le type).
    pub state: Option<String>,
    /// Identité.
    pub identity: Option<String>,
    /// Organisation.
    pub organization: Option<String>,
    /// Adresse visée.
    pub address: Option<String>,
    /// Actions imposées.
    pub required_actions: Vec<String>,
    /// Seconds facteurs admis (parcours `mfa_required`).
    pub methods: Vec<String>,
    /// Session à l'origine du parcours (texte).
    pub session: Option<String>,
    /// Appareil.
    pub client: ClientInfo,
}

/// Parcours.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Flow {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Type.
    #[surreal(rename = "type")]
    pub flow_type: String,
    /// État.
    pub state: String,
    /// Identité.
    pub identity: Option<AuthRecordId>,
    /// Organisation.
    pub organization: Option<AuthRecordId>,
    /// Adresse visée.
    pub address: Option<String>,
    /// Actions imposées restantes.
    pub required_actions: Vec<String>,
    /// Seconds facteurs admis, ou méthode enrôlée dans ce parcours.
    pub methods: Vec<String>,
    /// Session à l'origine du parcours.
    pub session: Option<AuthRecordId>,
    /// Expiration.
    pub expires_at: AuthDatetime,
}

/// Paramètres de `fn::auth_flow_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct FlowGetParams {
    /// Parcours (texte).
    pub flow: String,
}

/// Paramètres de `fn::auth_flow_submit`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct FlowSubmitParams {
    /// Parcours (texte).
    pub flow: String,
    /// États de départ admis.
    pub from: Vec<String>,
    /// Nouvel état.
    pub state: String,
    /// Actions imposées restantes.
    pub required_actions: Option<Vec<String>>,
    /// Seconds facteurs admis.
    pub methods: Option<Vec<String>>,
    /// Identité.
    pub identity: Option<String>,
}

/// Paramètres de `fn::auth_code_issue`.
#[derive(Clone, SurrealValue)]
pub struct CodeIssueParams {
    /// Parcours (texte).
    pub flow: String,
    /// Usage : `verification`, `recovery`, `address_change`.
    pub purpose: String,
    /// Adresse de destination.
    pub address: String,
    /// HMAC-SHA256 du code.
    pub code_hash: Option<String>,
    /// BLAKE3 du jeton de lien.
    pub link_hash: String,
    /// Identifiant d'événement (UUID v7) du contexte de scellement.
    pub event_id: Option<String>,
    /// Secret scellé `{ action_url, code }`.
    pub secret: Option<String>,
    /// Langue du destinataire.
    pub locale: Option<String>,
    /// Nom du destinataire.
    pub name: Option<String>,
}

impl std::fmt::Debug for CodeIssueParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("CodeIssueParams")
            .field("flow", &self.flow)
            .field("purpose", &self.purpose)
            .field("event_id", &self.event_id)
            .finish_non_exhaustive()
    }
}

/// Résultat de `fn::auth_code_issue`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct CodeIssued {
    /// Code.
    pub code: AuthRecordId,
    /// Expiration.
    pub expires_at: AuthDatetime,
}

/// Paramètres de `fn::auth_code_verify`.
#[derive(Debug, Clone, SurrealValue)]
pub struct CodeVerifyParams {
    /// Parcours (texte), avec un code.
    pub flow: Option<String>,
    /// Usage.
    pub purpose: String,
    /// HMAC du code présenté.
    pub code_hash: Option<String>,
    /// BLAKE3 du lien présenté.
    pub link_hash: Option<String>,
}

/// Résultat de `fn::auth_code_verify`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct CodeVerified {
    /// Parcours.
    pub flow: AuthRecordId,
    /// Type du parcours.
    #[surreal(rename = "type")]
    pub flow_type: String,
    /// Identité.
    pub identity: Option<AuthRecordId>,
    /// Adresse.
    pub address: String,
}

/// Paramètres des fonctions anti-force-brute.
#[derive(Debug, Clone, SurrealValue)]
pub struct LoginFailureParams {
    /// BLAKE3 de l'identifiant normalisé.
    pub identifier_hash: String,
    /// BLAKE3 de l'adresse IP.
    pub ip_hash: Option<String>,
    /// Identité (échec sur un compte existant).
    pub identity: Option<String>,
}

/// État de verrouillage.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct LoginFailureStatus {
    /// Verrouillé.
    pub locked: bool,
    /// Fin du verrouillage.
    pub until: Option<AuthDatetime>,
}

/// Paramètres de `fn::auth_login_failure_reset`.
#[derive(Debug, Clone, SurrealValue)]
pub struct LoginFailureResetParams {
    /// BLAKE3 de l'identifiant normalisé.
    pub identifier_hash: String,
}

/// Paramètres de `fn::auth_session_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SessionCreateParams {
    /// Identité (texte).
    pub identity: String,
    /// Organisation active (texte).
    pub organization: Option<String>,
    /// Méthodes d'authentification utilisées.
    pub amr: Vec<String>,
    /// Appareil.
    pub client: ClientInfo,
    /// Accès SurrealDB du jeton (`a` ou `b`).
    pub access_slot: String,
    /// BLAKE3 du jeton de renouvellement.
    pub refresh_token_hash: String,
}

/// Session émise : ce que porte le jeton d'accès.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SessionIssued {
    /// Session.
    pub session: AuthRecordId,
    /// Identité.
    pub identity: Option<AuthRecordId>,
    /// Application (compte de service).
    pub application: Option<AuthRecordId>,
    /// Organisation active.
    pub organization: Option<AuthRecordId>,
    /// Nature.
    pub kind: String,
    /// Permissions.
    pub permissions: Vec<String>,
    /// Version des droits.
    pub version: i64,
    /// Niveau d'assurance.
    pub aal: i64,
    /// Durée d'un jeton d'accès (secondes).
    pub access_seconds: i64,
    /// Expiration par inactivité.
    pub idle_expires_at: AuthDatetime,
    /// Expiration absolue.
    pub expires_at: AuthDatetime,
    /// Expiration du jeton de renouvellement.
    pub refresh_expires_at: Option<AuthDatetime>,
}

/// Paramètres de `fn::auth_session_refresh`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SessionRefreshParams {
    /// BLAKE3 du jeton présenté.
    pub token_hash: String,
    /// BLAKE3 du nouveau jeton.
    pub new_token_hash: String,
    /// Accès SurrealDB du jeton.
    pub access_slot: String,
}

/// Paramètres de `fn::auth_session_revoke`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SessionRevokeParams {
    /// Session (texte).
    pub session: String,
    /// Motif.
    pub reason: String,
}

/// Résultat de `fn::auth_session_revoke`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SessionRevoked {
    /// Session.
    pub session: AuthRecordId,
    /// Révoquée par cet appel.
    pub revoked: bool,
}

/// Paramètres de `fn::auth_session_revoke_all`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SessionRevokeAllParams {
    /// Identité (texte).
    pub identity: String,
    /// Session conservée.
    pub except_session: Option<String>,
    /// Motif.
    pub reason: String,
}

/// Paramètres de `fn::auth_session_switch_organization`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SessionSwitchParams {
    /// Session courante (texte).
    pub session: String,
    /// Nouvelle organisation active (texte), aucune pour l'installation.
    pub organization: Option<String>,
    /// Accès SurrealDB du jeton.
    pub access_slot: String,
    /// BLAKE3 du jeton de renouvellement.
    pub refresh_token_hash: String,
}

/// Paramètres de `fn::auth_session_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SessionListParams {
    /// Organisation (gestion).
    pub organization: Option<String>,
    /// Identité.
    pub identity: Option<String>,
}

/// Session listée.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SessionSummary {
    /// Session.
    pub id: AuthRecordId,
    /// Identité.
    pub identity: Option<AuthRecordId>,
    /// Nature.
    pub kind: String,
    /// Organisation active.
    pub organization: Option<AuthRecordId>,
    /// Appareil.
    pub client: ClientInfo,
    /// Création.
    pub created_at: AuthDatetime,
    /// Dernière activité.
    pub last_seen_at: AuthDatetime,
    /// Session de l'appel.
    pub current: bool,
}

/// Paramètres de `fn::auth_registration_start`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RegistrationStartParams {
    /// Empreinte du jeton d'invitation.
    pub invitation_token_hash: Option<String>,
    /// Empreinte du lien d'installation.
    pub setup_link_hash: Option<String>,
}

/// Résultat de `fn::auth_registration_start`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RegistrationStarted {
    /// Parcours.
    pub flow: AuthRecordId,
    /// Adresse de l'invitation ou du lien.
    pub email: String,
    /// Organisation de l'invitation.
    pub organization: Option<AuthRecordId>,
    /// `invitation` ou `setup`.
    pub kind: String,
}

/// Paramètres de `fn::auth_registration_complete`.
#[derive(Clone, SurrealValue)]
pub struct RegistrationCompleteParams {
    /// Parcours (texte).
    pub flow: String,
    /// Traits (hors adresse, imposée par l'invitation).
    pub traits: lyxal_surreal::Value,
}

impl std::fmt::Debug for RegistrationCompleteParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("RegistrationCompleteParams")
            .field("flow", &self.flow)
            .finish_non_exhaustive()
    }
}

/// Résultat de `fn::auth_registration_complete`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RegistrationCompleted {
    /// Identité créée.
    pub identity: AuthRecordId,
    /// Organisation de l'invitation.
    pub organization: Option<AuthRecordId>,
}

/// Paramètres de `fn::auth_setup_start`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SetupStartParams {
    /// Adresse du premier administrateur.
    pub email: String,
    /// BLAKE3 du jeton de lien.
    pub link_hash: String,
}

/// Résultat de `fn::auth_setup_start`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SetupStarted {
    /// Parcours.
    pub flow: AuthRecordId,
    /// Expiration du lien.
    pub expires_at: AuthDatetime,
}

/// Paramètres de `fn::auth_address_verify`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AddressVerifyParams {
    /// Identité (texte).
    pub identity: String,
    /// Adresse vérifiée.
    pub address: String,
}

/// Paramètres de `fn::auth_address_change_request`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AddressChangeRequestParams {
    /// Identité (texte).
    pub identity: String,
    /// Nouvelle adresse.
    pub new_address: String,
    /// Appareil.
    pub client: ClientInfo,
}

/// Résultat de `fn::auth_address_change_request`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AddressChangeRequested {
    /// Parcours.
    pub flow: AuthRecordId,
    /// Nouvelle adresse normalisée.
    pub address: String,
}

/// Paramètres de `fn::auth_address_change_confirm`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AddressChangeConfirmParams {
    /// Parcours (texte).
    pub flow: String,
}

/// Résultat de `fn::auth_address_change_confirm`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AddressChanged {
    /// Identité.
    pub identity: AuthRecordId,
    /// Nouvelle adresse.
    pub address: String,
}

/// Paramètres de `fn::auth_required_action_complete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RequiredActionCompleteParams {
    /// Identité (texte).
    pub identity: String,
    /// Action.
    pub action: String,
}

/// Paramètres de `fn::auth_required_action_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RequiredActionListParams {
    /// Identité (texte ; par défaut celle de la session).
    pub identity: Option<String>,
}

/// Action imposée en attente.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RequiredAction {
    /// Enregistrement.
    pub id: AuthRecordId,
    /// Action (`verify_email`, `update_password`, `accept_terms`).
    pub action: String,
    /// Motif.
    pub reason: Option<String>,
    /// Création.
    pub created_at: AuthDatetime,
}

/// Paramètres de `fn::auth_signing_key_get_active`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SigningKeyGetParams {
    /// `access_token` ou `code_pepper`.
    pub purpose: String,
}

/// Clé de signature scellée.
#[derive(Clone, SurrealValue)]
pub struct SigningKeyRecord {
    /// Emplacement (`a`, `b`).
    pub slot: Option<String>,
    /// Clé scellée (`enc:v2`).
    pub secret: String,
    /// Activation.
    pub activated_at: AuthDatetime,
}

impl std::fmt::Debug for SigningKeyRecord {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SigningKeyRecord")
            .field("slot", &self.slot)
            .finish_non_exhaustive()
    }
}

/// Résultat de `fn::auth_signing_key_get_active`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SigningKeys {
    /// Clé active.
    pub active: SigningKeyRecord,
    /// Clé précédente (encore vérifiable).
    pub previous: Option<SigningKeyRecord>,
}

/// Paramètres de `fn::auth_signing_key_rotate`.
#[derive(Clone, SurrealValue)]
pub struct SigningKeyRotateParams {
    /// Usage.
    pub purpose: String,
    /// Nouvelle clé scellée.
    pub secret: String,
    /// Écraser l'emplacement même si des jetons signés par lui peuvent être valides.
    pub force: bool,
    /// Durée du cache des émetteurs (secondes).
    pub cache_seconds: i64,
}

impl std::fmt::Debug for SigningKeyRotateParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SigningKeyRotateParams")
            .field("purpose", &self.purpose)
            .field("force", &self.force)
            .finish_non_exhaustive()
    }
}

/// Résultat de `fn::auth_signing_key_rotate`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SigningKeyRotated {
    /// Emplacement activé.
    pub slot: Option<String>,
    /// Clé créée par cet appel.
    pub created: bool,
}

/// Paramètres de `fn::auth_service_session_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ServiceSessionParams {
    /// Identifiant client.
    pub client_id: String,
    /// BLAKE3 du secret client.
    pub secret_hash: String,
    /// Appareil.
    pub client: ClientInfo,
    /// Accès SurrealDB du jeton.
    pub access_slot: String,
}

/// Paramètres de `fn::auth_service_session_open` (compte de service interne à l'hôte).
#[derive(Debug, Clone, SurrealValue)]
pub struct ServiceSessionOpenParams {
    /// Identifiant client de l'application machine.
    pub client_id: String,
    /// Appareil.
    pub client: ClientInfo,
    /// Accès SurrealDB du jeton.
    pub access_slot: String,
}

/// Paramètres de `fn::auth_api_key_session_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ApiKeySessionParams {
    /// BLAKE3 de la clé.
    pub key_hash: String,
    /// Appareil.
    pub client: ClientInfo,
    /// Accès SurrealDB du jeton.
    pub access_slot: String,
}

/// Paramètres de `fn::auth_api_key_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ApiKeyCreateParams {
    /// Nom.
    pub name: String,
    /// BLAKE3 de la clé.
    pub key_hash: String,
    /// Préfixe affichable.
    pub prefix: String,
    /// Permissions accordées.
    pub permissions: Vec<String>,
    /// Expiration.
    pub expires_at: Option<AuthDatetime>,
}

/// Clé d'API créée (sans empreinte).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ApiKeyCreated {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Nom.
    pub name: String,
    /// Préfixe.
    pub prefix: String,
    /// Permissions.
    pub permissions: Vec<String>,
}

/// Paramètres de `fn::auth_application_secret_add`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ApplicationSecretAddParams {
    /// Application (texte).
    pub application: String,
    /// BLAKE3 du secret.
    pub secret_hash: String,
    /// Préfixe affichable.
    pub prefix: String,
    /// Expiration.
    pub expires_at: Option<AuthDatetime>,
}

/// Secret client ajouté.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ApplicationSecretAdded {
    /// Identifiant.
    pub id: AuthRecordId,
    /// Préfixe.
    pub prefix: String,
}

/// Paramètres de `fn::auth_purge`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AuthPurgeParams {
    /// Éléments au plus par catégorie.
    pub limit: i64,
}

/// Résultat de `fn::auth_purge`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AuthPurgeResult {
    /// Sessions expirées marquées.
    pub sessions_expired: i64,
    /// Parcours supprimés.
    pub flows: i64,
    /// Jetons de renouvellement supprimés.
    pub refresh_tokens: i64,
    /// Sessions terminées supprimées.
    pub sessions: i64,
    /// Compteurs d'échecs supprimés.
    pub login_failures: i64,
    /// Invitations expirées.
    pub invitations_expired: i64,
    /// TOTP jamais confirmés supprimés.
    pub pending_totp: i64,
    /// Demandes d'acceptation d'invitation supprimées.
    pub invitation_claims: i64,
    /// Émissions de codes anciennes supprimées.
    pub code_issuances: i64,
}

/// Paramètres de `fn::auth_session_check`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SessionCheckParams {
    /// Session (texte).
    pub session: String,
    /// Version des droits portée par le jeton.
    pub pv: i64,
}

/// Appelant identifié par un jeton vérifié et une session valide.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SessionCaller {
    /// Session.
    pub session: AuthRecordId,
    /// Identité.
    pub identity: Option<AuthRecordId>,
    /// Application (compte de service).
    pub application: Option<AuthRecordId>,
    /// Organisation active.
    pub organization: Option<AuthRecordId>,
    /// Nature.
    pub kind: String,
}
