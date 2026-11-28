//! Accès aux fonctions SurrealQL de `lyxal_infra` : un appel typé d'une ligne par fonction
//! publique (`LyxalSurrealCall::call_fn`). Les règles (état désiré, propriété, conflits, plan,
//! journal, droits) restent dans SurrealQL ; la session SurrealDB du client détermine
//! l'appelant (session système de l'hôte, administrateur de la plateforme, compte de service
//! d'un module ou du worker).

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError, SurrealPool};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    AccountCreateParams, AccountDeleted, AccountDueList, AccountListParams, AccountListResult,
    AccountRefParams, AccountResult, AccountTestOutcome, AccountTestResultParams,
    AccountUpdateParams, ApplyBeginParams, ApplyBegun, ApplyResult, ApplyResultParams,
    ChangeListParams, ChangeListResult, ChangeVerifyParams, ChangeVerifyResult,
    ConflictResolveParams, HealthParams, HealthResult, PurgeResult, RecordListParams,
    RecordListResult, RecordRefParams, RecordResult, RecordsDeclareParams, RecordsDeclareResult,
    RecordsReleaseParams, RecordsReleaseResult, RecordsStatusParams, RecordsStatusResult,
    RecordsSubjectsParams, RecordsSubjectsResult, SettingsGetParams, SettingsResult,
    SettingsUpdateParams, VerifyList, VerifyOutcome, VerifyResultParams, WorkerBatchParams,
    ZoneAttachParams, ZoneClaim, ZoneClaimParams, ZoneClaimRefParams, ZoneDetachParams,
    ZoneDetachResult, ZoneDueList, ZoneListParams, ZoneListResult, ZoneObserveParams, ZoneObserved,
    ZonePlanApproveParams, ZonePlanResult, ZoneReconcileRequested, ZoneRecordsParams,
    ZoneRecordsResult, ZoneRefParams, ZoneReleaseParams, ZoneReleased, ZoneRenewParams,
    ZoneRenewed, ZoneResult, ZoneUpdateParams,
};

/// Store de `lyxal_infra` sur un client SurrealDB (`Surreal<Any>`), ou sur le pool de
/// connexions de la session système de l'hôte (`SurrealPool`) : chaque appel prend alors le
/// client du tour suivant. Une copie du store partage la session de l'original.
#[derive(Clone)]
pub struct InfraStore {
    db: SurrealPool,
}

#[async_trait]
impl LyxalSurrealCall for InfraStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        self.db.client()
    }
}

type Call<T> = Result<T, LyxalSurrealError>;

impl InfraStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis), ou sur un pool de
    /// clients de la même session.
    pub fn new(db: impl Into<SurrealPool>) -> Self {
        Self { db: db.into() }
    }

    // ------------------------------------------------------------------ réglages

    /// `fn::infra_settings_get` : réglages effectifs.
    pub async fn settings_get(&self, params: SettingsGetParams) -> Call<SettingsResult> {
        self.call_fn("infra_settings_get", params).await
    }

    /// `fn::infra_settings_update` : réglages modifiés.
    pub async fn settings_update(&self, params: SettingsUpdateParams) -> Call<SettingsResult> {
        self.call_fn("infra_settings_update", params).await
    }

    // ------------------------------------------------------------------ comptes

    /// `fn::infra_account_create` : compte d'hébergeur créé (essai demandé).
    pub async fn account_create(&self, params: AccountCreateParams) -> Call<AccountResult> {
        self.call_fn("infra_account_create", params).await
    }

    /// `fn::infra_account_update` : compte modifié.
    pub async fn account_update(&self, params: AccountUpdateParams) -> Call<AccountResult> {
        self.call_fn("infra_account_update", params).await
    }

    /// `fn::infra_account_get` : compte, sans secret, et nombre de zones.
    pub async fn account_get(&self, params: AccountRefParams) -> Call<AccountResult> {
        self.call_fn("infra_account_get", params).await
    }

    /// `fn::infra_account_list` : comptes.
    pub async fn account_list(&self, params: AccountListParams) -> Call<AccountListResult> {
        self.call_fn("infra_account_list", params).await
    }

    /// `fn::infra_account_delete` : compte sans zone supprimé.
    pub async fn account_delete(&self, params: AccountRefParams) -> Call<AccountDeleted> {
        self.call_fn("infra_account_delete", params).await
    }

    /// `fn::infra_account_test_request` : essai du compte demandé.
    pub async fn account_test_request(&self, params: AccountRefParams) -> Call<AccountResult> {
        self.call_fn("infra_account_test_request", params).await
    }

    // ------------------------------------------------------------------ zones

    /// `fn::infra_zone_attach` : zone rattachée (mode observe par défaut).
    pub async fn zone_attach(&self, params: ZoneAttachParams) -> Call<ZoneResult> {
        self.call_fn("infra_zone_attach", params).await
    }

    /// `fn::infra_zone_update` : mode ou organisations acceptées changés.
    pub async fn zone_update(&self, params: ZoneUpdateParams) -> Call<ZoneResult> {
        self.call_fn("infra_zone_update", params).await
    }

    /// `fn::infra_zone_detach` : zone détachée.
    pub async fn zone_detach(&self, params: ZoneDetachParams) -> Call<ZoneDetachResult> {
        self.call_fn("infra_zone_detach", params).await
    }

    /// `fn::infra_zone_get` : zone, dernier plan, compteurs.
    pub async fn zone_get(&self, params: ZoneRefParams) -> Call<ZoneResult> {
        self.call_fn("infra_zone_get", params).await
    }

    /// `fn::infra_zone_list` : zones.
    pub async fn zone_list(&self, params: ZoneListParams) -> Call<ZoneListResult> {
        self.call_fn("infra_zone_list", params).await
    }

    /// `fn::infra_zone_reconcile_request` : passe immédiate demandée.
    pub async fn zone_reconcile_request(
        &self,
        params: ZoneRefParams,
    ) -> Call<ZoneReconcileRequested> {
        self.call_fn("infra_zone_reconcile_request", params).await
    }

    /// `fn::infra_zone_plan_approve` : plan bloqué approuvé une fois.
    pub async fn zone_plan_approve(&self, params: ZonePlanApproveParams) -> Call<ZoneResult> {
        self.call_fn("infra_zone_plan_approve", params).await
    }

    /// `fn::infra_zone_records` : photo de la zone chez le fournisseur.
    pub async fn zone_records(&self, params: ZoneRecordsParams) -> Call<ZoneRecordsResult> {
        self.call_fn("infra_zone_records", params).await
    }

    // ------------------------------------------------------------------ contrat public des modules

    /// `fn::infra_records_declare` : ensemble (propriétaire, sujet) déclaré.
    pub async fn records_declare(
        &self,
        params: RecordsDeclareParams,
    ) -> Call<RecordsDeclareResult> {
        self.call_fn("infra_records_declare", params).await
    }

    /// `fn::infra_records_release` : ensemble (propriétaire, sujet) retiré.
    pub async fn records_release(
        &self,
        params: RecordsReleaseParams,
    ) -> Call<RecordsReleaseResult> {
        self.call_fn("infra_records_release", params).await
    }

    /// `fn::infra_records_status` : états des enregistrements d'un propriétaire.
    pub async fn records_status(&self, params: RecordsStatusParams) -> Call<RecordsStatusResult> {
        self.call_fn("infra_records_status", params).await
    }

    /// `fn::infra_records_subjects` : sujets d'un propriétaire, page par page.
    pub async fn records_subjects(
        &self,
        params: RecordsSubjectsParams,
    ) -> Call<RecordsSubjectsResult> {
        self.call_fn("infra_records_subjects", params).await
    }

    // ------------------------------------------------------------------ enregistrements (administration)

    /// `fn::infra_record_list` : enregistrements voulus.
    pub async fn record_list(&self, params: RecordListParams) -> Call<RecordListResult> {
        self.call_fn("infra_record_list", params).await
    }

    /// `fn::infra_record_get` : enregistrement voulu et valeurs observées.
    pub async fn record_get(&self, params: RecordRefParams) -> Call<RecordResult> {
        self.call_fn("infra_record_get", params).await
    }

    /// `fn::infra_record_conflict_resolve` : conflit levé (`take_over` ou `yield`).
    pub async fn record_conflict_resolve(
        &self,
        params: ConflictResolveParams,
    ) -> Call<RecordResult> {
        self.call_fn("infra_record_conflict_resolve", params).await
    }

    // ------------------------------------------------------------------ journal

    /// `fn::infra_change_list` : entrées du journal.
    pub async fn change_list(&self, params: ChangeListParams) -> Call<ChangeListResult> {
        self.call_fn("infra_change_list", params).await
    }

    /// `fn::infra_change_verify` : contrôle de la chaîne du journal.
    pub async fn change_verify(&self, params: ChangeVerifyParams) -> Call<ChangeVerifyResult> {
        self.call_fn("infra_change_verify", params).await
    }

    // ------------------------------------------------------------------ worker

    /// `fn::infra_account_due` : comptes dont un essai est demandé.
    pub async fn account_due(&self, params: WorkerBatchParams) -> Call<AccountDueList> {
        self.call_fn("infra_account_due", params).await
    }

    /// `fn::infra_account_test_result` : résultat de l'essai d'un compte.
    pub async fn account_test_result(
        &self,
        params: AccountTestResultParams,
    ) -> Call<AccountTestOutcome> {
        self.call_fn("infra_account_test_result", params).await
    }

    /// `fn::infra_zone_due` : zones à réconcilier.
    pub async fn zone_due(&self, params: WorkerBatchParams) -> Call<ZoneDueList> {
        self.call_fn("infra_zone_due", params).await
    }

    /// `fn::infra_zone_claim` : zone réservée pour une passe.
    pub async fn zone_claim(&self, params: ZoneClaimParams) -> Call<ZoneClaim> {
        self.call_fn("infra_zone_claim", params).await
    }

    /// `fn::infra_zone_renew` : réservation renouvelée.
    pub async fn zone_renew(&self, params: ZoneRenewParams) -> Call<ZoneRenewed> {
        self.call_fn("infra_zone_renew", params).await
    }

    /// `fn::infra_zone_observe` : photo de la zone écrite par différence.
    pub async fn zone_observe(&self, params: ZoneObserveParams) -> Call<ZoneObserved> {
        self.call_fn("infra_zone_observe", params).await
    }

    /// `fn::infra_zone_plan` : plan de la zone réservée.
    pub async fn zone_plan(&self, params: ZoneClaimRefParams) -> Call<ZonePlanResult> {
        self.call_fn("infra_zone_plan", params).await
    }

    /// `fn::infra_zone_apply_begin` : intentions notées avant l'appel au fournisseur.
    pub async fn zone_apply_begin(&self, params: ApplyBeginParams) -> Call<ApplyBegun> {
        self.call_fn("infra_zone_apply_begin", params).await
    }

    /// `fn::infra_zone_apply_result` : issue de l'écriture chez le fournisseur.
    pub async fn zone_apply_result(&self, params: ApplyResultParams) -> Call<ApplyResult> {
        self.call_fn("infra_zone_apply_result", params).await
    }

    /// `fn::infra_zone_release` : fin de la passe.
    pub async fn zone_release(&self, params: ZoneReleaseParams) -> Call<ZoneReleased> {
        self.call_fn("infra_zone_release", params).await
    }

    /// `fn::infra_records_to_verify` : vérifications de publication dues.
    pub async fn records_to_verify(&self, params: WorkerBatchParams) -> Call<VerifyList> {
        self.call_fn("infra_records_to_verify", params).await
    }

    /// `fn::infra_record_verify_result` : réponse des serveurs faisant autorité.
    pub async fn record_verify_result(&self, params: VerifyResultParams) -> Call<VerifyOutcome> {
        self.call_fn("infra_record_verify_result", params).await
    }

    /// `fn::infra_purge` : journal et retraits au-delà de leur conservation.
    pub async fn purge(&self, params: WorkerBatchParams) -> Call<PurgeResult> {
        self.call_fn("infra_purge", params).await
    }

    /// `fn::infra_health` : nombres de la sonde de santé.
    pub async fn health(&self, params: HealthParams) -> Call<HealthResult> {
        self.call_fn("infra_health", params).await
    }
}
