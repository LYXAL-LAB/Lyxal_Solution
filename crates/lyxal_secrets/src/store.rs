//! Accès aux fonctions SurrealQL de `lyxal_secrets` : un appel typé d'une ligne par fonction
//! (`LyxalSurrealCall::call_fn`). Les règles restent dans SurrealQL ; la session SurrealDB du
//! client détermine l'appelant (session système de l'hôte, session d'une personne ou d'un
//! programme). Les appels qui transportent une enveloppe ou une clé scellée sont internes au
//! crate : seuls le service, le client et le worker les utilisent.

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    AuditDenied, AuditDeniedParams, AuditList, AuditListParams, AuditReport, AuditVerifyParams,
    CallerContext, CallerContextParams, LabelsResult, PurgeDueParams, PurgeReport, ReadBeginParams,
    ReadEnvelope, ReadTicket, ReadTicketRef, Resealed, RewrapList, RewrapListParams, RotateAllowed,
    SecretCreateParams, SecretGetParams, SecretList, SecretListParams, SecretPurged, SecretRecord,
    SecretRefParams, SecretUpdateParams, SecretVersion, SettingsGetParams, SettingsSetParams,
    SettingsView, StoredSettings, TenantKeyCreateParams, TenantKeyCreated, TenantKeyDestroyParams,
    TenantKeyDestroyed, TenantKeyRewrapParams, TenantKeyRewrapped, TenantKeyRing, TenantRef,
    VersionAddParams, VersionAdded, VersionLabelParams, VersionList, VersionListParams,
    VersionRefParams, VersionResealParams,
};

/// Store de `lyxal_secrets` sur un client SurrealDB (`Surreal<Any>`).
#[derive(Clone)]
pub struct SecretsStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for SecretsStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

type Call<T> = Result<T, LyxalSurrealError>;

impl SecretsStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis).
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// `fn::auth_context` (contrat public de `lyxal_auth`) : appelant de la session.
    pub async fn caller_context(&self) -> Call<CallerContext> {
        self.call_fn("auth_context", CallerContextParams {}).await
    }

    /// `fn::secrets_settings_get` : réglages d'une portée.
    pub async fn settings_get(&self, params: SettingsGetParams) -> Call<SettingsView> {
        self.call_fn("secrets_settings_get", params).await
    }

    /// `fn::secrets_settings_set` : réglages enregistrés.
    pub async fn settings_set(&self, params: SettingsSetParams) -> Call<StoredSettings> {
        self.call_fn("secrets_settings_set", params).await
    }

    /// `fn::secrets_secret_create` : fiche créée.
    pub async fn secret_create(&self, params: SecretCreateParams) -> Call<SecretRecord> {
        self.call_fn("secrets_secret_create", params).await
    }

    /// `fn::secrets_secret_update` : fiche modifiée.
    pub async fn secret_update(&self, params: SecretUpdateParams) -> Call<SecretRecord> {
        self.call_fn("secrets_secret_update", params).await
    }

    /// `fn::secrets_secret_get` : fiche et ses dernières versions.
    pub async fn secret_get(&self, params: SecretGetParams) -> Call<SecretRecord> {
        self.call_fn("secrets_secret_get", params).await
    }

    /// `fn::secrets_secret_list` : fiches d'une portée.
    pub async fn secret_list(&self, params: SecretListParams) -> Call<SecretList> {
        self.call_fn("secrets_secret_list", params).await
    }

    /// `fn::secrets_secret_disable` : lecture refusée, réversible.
    pub async fn secret_disable(&self, params: SecretRefParams) -> Call<SecretRecord> {
        self.call_fn("secrets_secret_disable", params).await
    }

    /// `fn::secrets_secret_enable` : secret réactivé.
    pub async fn secret_enable(&self, params: SecretRefParams) -> Call<SecretRecord> {
        self.call_fn("secrets_secret_enable", params).await
    }

    /// `fn::secrets_secret_delete` : suppression douce, date de purge posée.
    pub async fn secret_delete(&self, params: SecretRefParams) -> Call<SecretRecord> {
        self.call_fn("secrets_secret_delete", params).await
    }

    /// `fn::secrets_secret_restore` : secret supprimé restauré.
    pub async fn secret_restore(&self, params: SecretRefParams) -> Call<SecretRecord> {
        self.call_fn("secrets_secret_restore", params).await
    }

    /// `fn::secrets_secret_purge` : secret supprimé purgé avant sa date de purge.
    pub async fn secret_purge(&self, params: SecretRefParams) -> Call<SecretPurged> {
        self.call_fn("secrets_secret_purge", params).await
    }

    /// `fn::secrets_version_add` : version scellée ajoutée (par le service seulement).
    pub(crate) async fn version_add(&self, params: VersionAddParams) -> Call<VersionAdded> {
        self.call_fn("secrets_version_add", params).await
    }

    /// `fn::secrets_version_list` : versions d'un secret, sans enveloppe.
    pub async fn version_list(&self, params: VersionListParams) -> Call<VersionList> {
        self.call_fn("secrets_version_list", params).await
    }

    /// `fn::secrets_version_label` : étiquette posée ou retirée.
    pub async fn version_label(&self, params: VersionLabelParams) -> Call<LabelsResult> {
        self.call_fn("secrets_version_label", params).await
    }

    /// `fn::secrets_version_disable` : version désactivée.
    pub async fn version_disable(&self, params: VersionRefParams) -> Call<SecretVersion> {
        self.call_fn("secrets_version_disable", params).await
    }

    /// `fn::secrets_version_enable` : version réactivée.
    pub async fn version_enable(&self, params: VersionRefParams) -> Call<SecretVersion> {
        self.call_fn("secrets_version_enable", params).await
    }

    /// `fn::secrets_version_destroy` : version détruite (enveloppe effacée).
    pub async fn version_destroy(&self, params: VersionRefParams) -> Call<SecretVersion> {
        self.call_fn("secrets_version_destroy", params).await
    }

    /// `fn::secrets_version_reseal` : version rescellée par la clé active (worker seulement).
    pub(crate) async fn version_reseal(&self, params: VersionResealParams) -> Call<Resealed> {
        self.call_fn("secrets_version_reseal", params).await
    }

    /// `fn::secrets_read_begin` : ticket de lecture tracé au journal.
    pub async fn read_begin(&self, params: ReadBeginParams) -> Call<ReadTicket> {
        self.call_fn("secrets_read_begin", params).await
    }

    /// `fn::secrets_read_envelope` : enveloppe et contexte contre un ticket (session système).
    pub(crate) async fn read_envelope(&self, params: ReadTicketRef) -> Call<ReadEnvelope> {
        self.call_fn("secrets_read_envelope", params).await
    }

    /// `fn::secrets_audit_list` : entrées du journal d'une portée.
    pub async fn audit_list(&self, params: AuditListParams) -> Call<AuditList> {
        self.call_fn("secrets_audit_list", params).await
    }

    /// `fn::secrets_audit_verify` : vérification de la chaîne du journal.
    pub async fn audit_verify(&self, params: AuditVerifyParams) -> Call<AuditReport> {
        self.call_fn("secrets_audit_verify", params).await
    }

    /// `fn::secrets_audit_denied` : lecture refusée journalisée au nom de l'appelant (session
    /// système).
    pub async fn audit_denied(&self, params: AuditDeniedParams) -> Call<AuditDenied> {
        self.call_fn("secrets_audit_denied", params).await
    }

    /// `fn::secrets_purge_due` : secrets purgés à échéance, tickets échus retirés.
    pub async fn purge_due(&self, params: PurgeDueParams) -> Call<PurgeReport> {
        self.call_fn("secrets_purge_due", params).await
    }

    /// `fn::secrets_tenant_key_ring` : clés scellées d'une portée (session système).
    pub(crate) async fn tenant_key_ring(&self, params: TenantRef) -> Call<TenantKeyRing> {
        self.call_fn("secrets_tenant_key_ring", params).await
    }

    /// `fn::secrets_tenant_key_create` : clé d'organisation scellée rangée (session système).
    pub(crate) async fn tenant_key_create(
        &self,
        params: TenantKeyCreateParams,
    ) -> Call<TenantKeyCreated> {
        self.call_fn("secrets_tenant_key_create", params).await
    }

    /// `fn::secrets_tenant_key_rotate_allowed` : droit de demander une rotation.
    pub async fn tenant_key_rotate_allowed(&self, params: TenantRef) -> Call<RotateAllowed> {
        self.call_fn("secrets_tenant_key_rotate_allowed", params)
            .await
    }

    /// `fn::secrets_tenant_key_rewrap` : clé rescellée par la nouvelle clé maîtresse.
    pub(crate) async fn tenant_key_rewrap(
        &self,
        params: TenantKeyRewrapParams,
    ) -> Call<TenantKeyRewrapped> {
        self.call_fn("secrets_tenant_key_rewrap", params).await
    }

    /// `fn::secrets_tenant_key_destroy` : ancienne clé détruite (session système).
    pub async fn tenant_key_destroy(
        &self,
        params: TenantKeyDestroyParams,
    ) -> Call<TenantKeyDestroyed> {
        self.call_fn("secrets_tenant_key_destroy", params).await
    }

    /// `fn::secrets_rewrap_list` : travail de rescellement (session système).
    pub(crate) async fn rewrap_list(&self, params: RewrapListParams) -> Call<RewrapList> {
        self.call_fn("secrets_rewrap_list", params).await
    }
}
