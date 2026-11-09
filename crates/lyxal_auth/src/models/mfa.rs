//! Contrats des fonctions SurrealQL du double facteur (lot 4) : seconds facteurs, niveau
//! d'assurance, réauthentification, tentatives, état des cérémonies passkeys.

use lyxal_surreal::SurrealValue;

use super::types::{AuthDatetime, AuthRecordId, AuthValue};

/// Paramètres de `fn::auth_login_requirements`.
#[derive(Debug, Clone, SurrealValue)]
pub struct LoginRequirementsParams {
    /// Identité (texte).
    pub identity: String,
    /// Organisation demandée (texte).
    pub organization: Option<String>,
}

/// Ce qu'exige la connexion d'une identité.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct LoginRequirements {
    /// Actions imposées (dont `configure_mfa` calculée).
    pub required_actions: Vec<String>,
    /// Double facteur exigé.
    pub mfa_required: bool,
    /// Niveau d'assurance atteignable.
    pub available_aal: i64,
    /// Seconds facteurs utilisables (`totp`, `passkey`, `recovery_code`).
    pub methods: Vec<String>,
}

/// Paramètres de `fn::auth_assurance_check`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AssuranceCheckParams {
    /// Session vérifiée (texte ; session système).
    pub session: Option<String>,
    /// `aal1`, `aal2` ou `highest_available`.
    pub min_aal: String,
    /// Authentification récente exigée.
    pub fresh: bool,
}

/// Exigence d'assurance satisfaite.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct AssuranceState {
    /// Niveau de la session.
    pub aal: Option<i64>,
    /// Niveau atteignable par l'identité.
    pub available_aal: Option<i64>,
    /// Dernière authentification.
    pub authenticated_at: Option<AuthDatetime>,
    /// Session système.
    pub system: bool,
}

/// Paramètres de `fn::auth_session_reauthenticate`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SessionReauthenticateParams {
    /// Session (texte).
    pub session: String,
    /// Méthode vérifiée par l'hôte (`password`, `totp`, `passkey`, `recovery_code`).
    pub method: String,
    /// Accès SurrealDB du nouveau jeton (`a` ou `b`).
    pub access_slot: String,
}

/// Paramètres de `fn::auth_mfa_failure_check` et `fn::auth_mfa_failure_reset`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MfaFailureKeyParams {
    /// BLAKE3 de l'identité.
    pub identity_hash: String,
}

/// Paramètres de `fn::auth_mfa_failure_record`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MfaFailureParams {
    /// BLAKE3 de l'identité.
    pub identity_hash: String,
    /// Identité (texte).
    pub identity: String,
    /// Parcours (texte).
    pub flow: Option<String>,
    /// Méthode présentée.
    pub method: String,
}

/// État du verrouillage du second facteur.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MfaFailureStatus {
    /// Verrouillé.
    pub locked: bool,
    /// Fin du verrouillage.
    pub until: Option<AuthDatetime>,
    /// Parcours échoué (trop d'essais).
    pub flow_failed: Option<bool>,
}

/// Paramètres de `fn::auth_flow_state_save`.
#[derive(Clone, SurrealValue)]
pub struct FlowStateSaveParams {
    /// Parcours (texte).
    pub flow: String,
    /// État scellé (`enc:v2`).
    pub secret_state: String,
}

/// Paramètres de `fn::auth_flow_state_take`.
#[derive(Debug, Clone, SurrealValue)]
pub struct FlowStateTakeParams {
    /// Parcours (texte).
    pub flow: String,
}

/// État de cérémonie lu (et effacé) avec son parcours.
#[derive(Clone, SurrealValue)]
pub struct FlowStateTaken {
    /// Parcours.
    pub flow: AuthRecordId,
    /// Type de parcours.
    #[surreal(rename = "type")]
    pub flow_type: String,
    /// État du parcours.
    pub state: String,
    /// Identité.
    pub identity: Option<AuthRecordId>,
    /// Organisation.
    pub organization: Option<AuthRecordId>,
    /// Session à l'origine du parcours.
    pub session: Option<AuthRecordId>,
    /// Méthodes du parcours.
    pub methods: Vec<String>,
    /// État scellé (`enc:v2`).
    pub secret_state: String,
}

impl std::fmt::Debug for FlowStateTaken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("FlowStateTaken")
            .field("flow", &self.flow)
            .field("flow_type", &self.flow_type)
            .field("state", &self.state)
            .field("secret_state", &"[REDACTED]")
            .finish_non_exhaustive()
    }
}

/// Paramètres de `fn::auth_mfa_factor_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MfaFactorListParams {
    /// Session de l'utilisateur (texte).
    pub session: Option<String>,
    /// Parcours de connexion (texte).
    pub flow: Option<String>,
    /// Identité (texte).
    pub identity: Option<String>,
}

/// TOTP d'une identité.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TotpFactor {
    /// Moyen.
    pub id: AuthRecordId,
    /// `pending` ou `active`.
    pub state: String,
    /// Création.
    pub created_at: AuthDatetime,
    /// Dernier usage.
    pub last_used_at: Option<AuthDatetime>,
}

/// Passkey d'une identité.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct PasskeyFactor {
    /// Moyen.
    pub id: AuthRecordId,
    /// Nom.
    pub label: Option<String>,
    /// Création.
    pub created_at: AuthDatetime,
    /// Dernier usage.
    pub last_used_at: Option<AuthDatetime>,
    /// Clé synchronisable.
    pub backup_eligible: Option<bool>,
    /// Clé synchronisée.
    pub backup_state: Option<bool>,
}

/// Codes de secours d'une identité.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RecoveryCodesSummary {
    /// Codes générés.
    pub total: i64,
    /// Codes restants.
    pub remaining: i64,
    /// Génération.
    pub created_at: AuthDatetime,
}

/// Seconds facteurs d'une identité (sans secret).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MfaFactors {
    /// TOTP.
    pub totp: Option<TotpFactor>,
    /// Passkeys.
    pub passkeys: Vec<PasskeyFactor>,
    /// Codes de secours.
    pub recovery_codes: Option<RecoveryCodesSummary>,
    /// Niveau atteignable.
    pub available_aal: i64,
}

/// Paramètres de `fn::auth_mfa_totp_begin`.
#[derive(Clone, SurrealValue)]
pub struct TotpBeginParams {
    /// Session de l'utilisateur (texte).
    pub session: Option<String>,
    /// Parcours de connexion (texte).
    pub flow: Option<String>,
    /// Identifiant choisi pour le moyen (texte `auth_credential:<clé>`).
    pub credential: String,
    /// Secret scellé (`enc:v2`).
    pub secret: String,
    /// `SHA1` ou `SHA256`.
    pub algorithm: String,
    /// Chiffres.
    pub digits: i64,
    /// Pas (secondes).
    pub step_seconds: i64,
}

/// TOTP en attente de confirmation.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TotpBegun {
    /// Moyen.
    pub credential: AuthRecordId,
    /// Identité.
    pub identity: AuthRecordId,
    /// Compte affiché par l'application (e-mail).
    pub account: Option<String>,
}

/// Paramètres de `fn::auth_mfa_totp_secret_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TotpSecretGetParams {
    /// Identité (texte).
    pub identity: String,
    /// `active` ou `pending`.
    pub state: String,
}

/// Secret TOTP scellé.
#[derive(Clone, SurrealValue)]
pub struct TotpSecretRecord {
    /// Moyen.
    pub credential: AuthRecordId,
    /// Secret scellé (`enc:v2`).
    pub secret: String,
    /// Réglages (`algorithm`, `digits`, `step_seconds`, `last_step`).
    pub public_data: AuthValue,
}

impl std::fmt::Debug for TotpSecretRecord {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("TotpSecretRecord")
            .field("credential", &self.credential)
            .field("secret", &"[REDACTED]")
            .finish_non_exhaustive()
    }
}

/// Paramètres de `fn::auth_mfa_totp_activate`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TotpActivateParams {
    /// Session de l'utilisateur (texte).
    pub session: Option<String>,
    /// Parcours de connexion (texte).
    pub flow: Option<String>,
    /// Moyen (texte).
    pub credential: String,
    /// Pas accepté.
    pub step: i64,
}

/// TOTP activé.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TotpActivated {
    /// Moyen.
    pub credential: AuthRecordId,
    /// Identité.
    pub identity: AuthRecordId,
    /// Codes de secours encore disponibles.
    pub recovery_codes: i64,
}

/// Paramètres de `fn::auth_mfa_totp_step_use`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TotpStepUseParams {
    /// Moyen (texte).
    pub credential: String,
    /// Pas accepté.
    pub step: i64,
}

/// Moyen utilisé.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct CredentialUsed {
    /// Moyen.
    pub credential: AuthRecordId,
    /// Identité.
    pub identity: AuthRecordId,
}

/// Paramètres de `fn::auth_mfa_passkey_save`.
#[derive(Clone, SurrealValue)]
pub struct PasskeySaveParams {
    /// Session de l'utilisateur (texte).
    pub session: Option<String>,
    /// Parcours de connexion (texte).
    pub flow: Option<String>,
    /// Identifiant WebAuthn (Base64 URL).
    pub credential_id: String,
    /// Nom.
    pub label: Option<String>,
    /// Clé sérialisée par `webauthn-rs`.
    pub public_data: AuthValue,
}

/// Passkey enregistrée.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct PasskeySaved {
    /// Moyen.
    pub credential: AuthRecordId,
    /// Identité.
    pub identity: AuthRecordId,
    /// Nom.
    pub label: Option<String>,
}

/// Paramètres de `fn::auth_mfa_passkey_find`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PasskeyFindParams {
    /// Identifiant WebAuthn (Base64 URL).
    pub credential_id: String,
}

/// Passkey retrouvée par son identifiant WebAuthn.
#[derive(Clone, SurrealValue)]
pub struct PasskeyFound {
    /// Moyen.
    pub credential: AuthRecordId,
    /// Identité.
    pub identity: AuthRecordId,
    /// Clé sérialisée.
    pub public_data: AuthValue,
    /// État de l'identité.
    pub identity_state: Option<String>,
}

/// Paramètres de `fn::auth_mfa_passkey_list_for`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PasskeyListForParams {
    /// Identité (texte).
    pub identity: String,
}

/// Passkey d'une identité avec sa clé sérialisée.
#[derive(Clone, SurrealValue)]
pub struct PasskeyRecord {
    /// Moyen.
    pub credential: AuthRecordId,
    /// Identifiant WebAuthn.
    pub credential_id: String,
    /// Clé sérialisée.
    pub public_data: AuthValue,
}

/// Paramètres de `fn::auth_mfa_passkey_update`.
#[derive(Clone, SurrealValue)]
pub struct PasskeyUpdateParams {
    /// Moyen (texte).
    pub credential: String,
    /// Clé sérialisée mise à jour.
    pub public_data: AuthValue,
}

/// Paramètres de `fn::auth_mfa_passkey_rename`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PasskeyRenameParams {
    /// Session de l'utilisateur (texte).
    pub session: String,
    /// Moyen (texte).
    pub credential: String,
    /// Nouveau nom.
    pub label: String,
}

/// Passkey renommée.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct PasskeyRenamed {
    /// Moyen.
    pub credential: AuthRecordId,
    /// Nom.
    pub label: String,
}

/// Paramètres de `fn::auth_mfa_recovery_codes_replace`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecoveryCodesReplaceParams {
    /// Session de l'utilisateur (texte).
    pub session: Option<String>,
    /// Parcours de connexion (texte).
    pub flow: Option<String>,
    /// Génération (UUID v7 hexadécimal).
    pub batch: String,
    /// Empreintes HMAC des codes.
    pub code_hashes: Vec<String>,
}

/// Codes de secours remplacés.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RecoveryCodesReplaced {
    /// Identité.
    pub identity: AuthRecordId,
    /// Codes enregistrés.
    pub count: i64,
}

/// Paramètres de `fn::auth_mfa_recovery_code_use`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecoveryCodeUseParams {
    /// Identité (texte).
    pub identity: String,
    /// Empreinte HMAC du code présenté.
    pub code_hash: String,
}

/// Code de secours consommé.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RecoveryCodeUsed {
    /// Identité.
    pub identity: AuthRecordId,
    /// Codes restants.
    pub remaining: i64,
}

/// Paramètres de `fn::auth_mfa_factor_remove`.
#[derive(Debug, Clone, SurrealValue)]
pub struct FactorRemoveParams {
    /// Session de l'utilisateur (texte).
    pub session: String,
    /// Passkey (texte).
    pub credential: Option<String>,
    /// `totp` ou `passkey`.
    pub method: String,
}

/// Facteur retiré.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct FactorRemoved {
    /// Moyen retiré.
    pub removed: AuthRecordId,
    /// Niveau atteignable après le retrait.
    pub available_aal: i64,
}

/// Paramètres de `fn::auth_mfa_reset`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MfaResetParams {
    /// Session de l'administrateur (texte).
    pub session: String,
    /// Identité remise à zéro (texte).
    pub identity: String,
}

/// Remise à zéro faite.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct MfaReset {
    /// Identité.
    pub identity: AuthRecordId,
    /// Facteurs supprimés.
    pub removed: i64,
    /// Sessions révoquées.
    pub sessions_revoked: i64,
}
