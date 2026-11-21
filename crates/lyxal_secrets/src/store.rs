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
    AccessDueParams, AccessDueReport, AccessRequest, AuditDenied, AuditDeniedParams, AuditList,
    AuditListParams, AuditReport, AuditVerifyParams, CallerContext, CallerContextParams, DueList,
    DueListParams, DueMarkParams, DueMarkResult, EmergencyAccessParams, Grant, GrantCreateParams,
    GrantList, GrantListParams, GrantRevokeParams, LabelsResult, Policy, PolicyDeleteParams,
    PolicyDeleted, PolicyList, PolicyListParams, PolicySetParams, PurgeDueParams, PurgeReport,
    ReadBeginParams, ReadEnvelope, ReadTicket, ReadTicketRef, RequestAccessParams,
    RequestApplyParams, RequestChangeParams, RequestDecisionParams, RequestList, RequestListParams,
    RequestRefParams, RequestRejectParams, Resealed, RetiredKeys, RewrapList, RewrapListParams,
    RotateAllowed, RotationBeginParams, RotationCheckParams, RotationCheckResult,
    RotationClaimParams, RotationClaimed, RotationFailParams, RotationGetParams,
    RotationLeaseParams, RotationList, RotationRecord, RotationRefParams, RotationStepParams,
    SecretCreateParams, SecretGetParams, SecretList, SecretListParams, SecretPurged, SecretRecord,
    SecretRefParams, SecretUpdateParams, SecretVersion, SettingsGetParams, SettingsSetParams,
    SettingsView, Share, ShareConsumeParams, ShareConsumed, ShareCreateParams, ShareDueParams,
    ShareDueReport, ShareFailed, ShareList, ShareListParams, ShareLoaded, ShareRefParams,
    StoredSettings, TenantKeyCreateParams, TenantKeyCreated, TenantKeyDestroyParams,
    TenantKeyDestroyed, TenantKeyRetiredParams, TenantKeyRewrapParams, TenantKeyRewrapped,
    TenantKeyRing, TenantKeyRingParams, TenantRef, VersionAddParams, VersionAdded,
    VersionLabelParams, VersionList, VersionListParams, VersionRefParams, VersionResealParams,
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

    /// `fn::secrets_tenant_key_ring` : clés scellées d'une portée pour un usage (session
    /// système).
    pub(crate) async fn tenant_key_ring(&self, params: TenantKeyRingParams) -> Call<TenantKeyRing> {
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

    /// `fn::secrets_tenant_key_retired` : clés retirées d'un usage (session système).
    pub(crate) async fn tenant_key_retired(
        &self,
        params: TenantKeyRetiredParams,
    ) -> Call<RetiredKeys> {
        self.call_fn("secrets_tenant_key_retired", params).await
    }

    /// `fn::secrets_rewrap_list` : travail de rescellement (session système).
    pub(crate) async fn rewrap_list(&self, params: RewrapListParams) -> Call<RewrapList> {
        self.call_fn("secrets_rewrap_list", params).await
    }
    /// `fn::secrets_due_list` : échéances à signaler et clés d'organisation à faire tourner
    /// (worker).
    pub async fn due_list(&self, params: DueListParams) -> Call<DueList> {
        self.call_fn("secrets_due_list", params).await
    }

    /// `fn::secrets_due_mark` : échéance signalée une seule fois (worker).
    pub async fn due_mark(&self, params: DueMarkParams) -> Call<DueMarkResult> {
        self.call_fn("secrets_due_mark", params).await
    }

    /// `fn::secrets_rotation_begin` : rotation démarrée (écriture, ou worker sans urgence).
    pub async fn rotation_begin(&self, params: RotationBeginParams) -> Call<RotationRecord> {
        self.call_fn("secrets_rotation_begin", params).await
    }

    /// `fn::secrets_rotation_claim` : rotations réservées pour les faire avancer (worker).
    pub async fn rotation_claim(&self, params: RotationClaimParams) -> Call<RotationClaimed> {
        self.call_fn("secrets_rotation_claim", params).await
    }

    /// `fn::secrets_rotation_step` : étape franchie par le détenteur de la réservation, qu'elle
    /// renouvelle (worker).
    pub async fn rotation_step(&self, params: RotationStepParams) -> Call<RotationRecord> {
        self.call_fn("secrets_rotation_step", params).await
    }

    /// `fn::secrets_rotation_finish` : bascule sur la nouvelle version (worker).
    pub async fn rotation_finish(&self, params: RotationLeaseParams) -> Call<RotationRecord> {
        self.call_fn("secrets_rotation_finish", params).await
    }

    /// `fn::secrets_rotation_fail` : nouvel essai planifié ou échec définitif (worker).
    pub async fn rotation_fail(&self, params: RotationFailParams) -> Call<RotationRecord> {
        self.call_fn("secrets_rotation_fail", params).await
    }

    /// `fn::secrets_rotation_cancel` : rotation annulée (écriture).
    pub async fn rotation_cancel(&self, params: RotationRefParams) -> Call<RotationRecord> {
        self.call_fn("secrets_rotation_cancel", params).await
    }

    /// `fn::secrets_rotation_get` : rotation en cours et historique d'un secret (liste).
    pub async fn rotation_get(&self, params: RotationGetParams) -> Call<RotationList> {
        self.call_fn("secrets_rotation_get", params).await
    }

    /// `fn::secrets_rotation_check_record` : résultat d'un essai sans bascule (worker).
    pub async fn rotation_check_record(
        &self,
        params: RotationCheckParams,
    ) -> Call<RotationCheckResult> {
        self.call_fn("secrets_rotation_check_record", params).await
    }

    /// `fn::secrets_grant_create` : accès temporaire accordé (`secrets.access.manage`).
    pub async fn grant_create(&self, params: GrantCreateParams) -> Call<Grant> {
        self.call_fn("secrets_grant_create", params).await
    }

    /// `fn::secrets_grant_revoke` : accès retiré tout de suite (`secrets.access.manage`).
    pub async fn grant_revoke(&self, params: GrantRevokeParams) -> Call<Grant> {
        self.call_fn("secrets_grant_revoke", params).await
    }

    /// `fn::secrets_grant_list` : accès d'une organisation (tous pour le gestionnaire des accès,
    /// les siens pour les autres).
    pub async fn grant_list(&self, params: GrantListParams) -> Call<GrantList> {
        self.call_fn("secrets_grant_list", params).await
    }

    /// `fn::secrets_access_emergency` : accès d'urgence que l'appelant s'accorde lui-même
    /// (journalisé et publié).
    pub async fn access_emergency(&self, params: EmergencyAccessParams) -> Call<Grant> {
        self.call_fn("secrets_access_emergency", params).await
    }

    /// `fn::secrets_policy_set` : protection posée ou remplacée (`secrets.access.manage`).
    pub async fn policy_set(&self, params: PolicySetParams) -> Call<Policy> {
        self.call_fn("secrets_policy_set", params).await
    }

    /// `fn::secrets_policy_delete` : protection retirée (`secrets.access.manage`).
    pub async fn policy_delete(&self, params: PolicyDeleteParams) -> Call<PolicyDeleted> {
        self.call_fn("secrets_policy_delete", params).await
    }

    /// `fn::secrets_policy_list` : protections d'une organisation et protection effective d'un
    /// chemin.
    pub async fn policy_list(&self, params: PolicyListParams) -> Call<PolicyList> {
        self.call_fn("secrets_policy_list", params).await
    }

    /// `fn::secrets_request_access` : accès demandé pour soi.
    pub async fn request_access(&self, params: RequestAccessParams) -> Call<AccessRequest> {
        self.call_fn("secrets_request_access", params).await
    }

    /// `fn::secrets_request_change` : changement d'un secret protégé demandé.
    pub async fn request_change(&self, params: RequestChangeParams) -> Call<AccessRequest> {
        self.call_fn("secrets_request_change", params).await
    }

    /// `fn::secrets_request_approve` : approbation (jamais de sa propre demande).
    pub async fn request_approve(&self, params: RequestDecisionParams) -> Call<AccessRequest> {
        self.call_fn("secrets_request_approve", params).await
    }

    /// `fn::secrets_request_reject` : refus, qui clôt la demande.
    pub async fn request_reject(&self, params: RequestRejectParams) -> Call<AccessRequest> {
        self.call_fn("secrets_request_reject", params).await
    }

    /// `fn::secrets_request_cancel` : demande annulée par son auteur.
    pub async fn request_cancel(&self, params: RequestRefParams) -> Call<AccessRequest> {
        self.call_fn("secrets_request_cancel", params).await
    }

    /// `fn::secrets_request_apply` : changement approuvé (ou d'urgence) appliqué par son auteur.
    pub async fn request_apply(&self, params: RequestApplyParams) -> Call<AccessRequest> {
        self.call_fn("secrets_request_apply", params).await
    }

    /// `fn::secrets_request_get` : une demande.
    pub async fn request_get(&self, params: RequestRefParams) -> Call<AccessRequest> {
        self.call_fn("secrets_request_get", params).await
    }

    /// `fn::secrets_request_list` : demandes d'une organisation.
    pub async fn request_list(&self, params: RequestListParams) -> Call<RequestList> {
        self.call_fn("secrets_request_list", params).await
    }

    /// `fn::secrets_access_due` : demandes échues expirées, anciens accès retirés (worker).
    pub async fn access_due(&self, params: AccessDueParams) -> Call<AccessDueReport> {
        self.call_fn("secrets_access_due", params).await
    }

    /// `fn::secrets_share_create` : partage créé avec sa copie scellée (par le service seulement,
    /// qui seul tire la clé du lien et scelle).
    pub(crate) async fn share_create(&self, params: ShareCreateParams) -> Call<Share> {
        self.call_fn("secrets_share_create", params).await
    }

    /// `fn::secrets_share_list` : partages d'une portée, sans élément scellé.
    pub async fn share_list(&self, params: ShareListParams) -> Call<ShareList> {
        self.call_fn("secrets_share_list", params).await
    }

    /// `fn::secrets_share_revoke` : partage retiré, copie effacée.
    pub async fn share_revoke(&self, params: ShareRefParams) -> Call<Share> {
        self.call_fn("secrets_share_revoke", params).await
    }

    /// `fn::secrets_share_load` : partage actif avec sa copie scellée, l'empreinte de sa clé et le
    /// hachage de son mot de passe (session système seulement).
    pub(crate) async fn share_load(&self, params: ShareRefParams) -> Call<ShareLoaded> {
        self.call_fn("secrets_share_load", params).await
    }

    /// `fn::secrets_share_fail` : un essai faux compté ; au cinquième, partage détruit (session
    /// système seulement).
    pub async fn share_fail(&self, params: ShareRefParams) -> Call<ShareFailed> {
        self.call_fn("secrets_share_fail", params).await
    }

    /// `fn::secrets_share_consume` : une ouverture consommée, atomiquement (session système
    /// seulement).
    pub async fn share_consume(&self, params: ShareConsumeParams) -> Call<ShareConsumed> {
        self.call_fn("secrets_share_consume", params).await
    }

    /// `fn::secrets_share_due` : partages échus expirés, fiches finies retirées (worker).
    pub async fn share_due(&self, params: ShareDueParams) -> Call<ShareDueReport> {
        self.call_fn("secrets_share_due", params).await
    }
}
