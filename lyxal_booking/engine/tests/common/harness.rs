//! Harness de test commun pour Lyxal Booking.
//!
//! Fournit une instance in-memory isolée de SurrealDB pré-chargée
//! avec l'intégralité du corpus SurrealQL (209 fichiers ordonnés en 14 étapes).

use std::path::{Path, PathBuf};
use anyhow::{Context, Result};
use lyxal_booking::db::{SurrealBookingStore, SurrealConnectionConfig};
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use serde::de::DeserializeOwned;
use serde::Serialize;
use uuid::Uuid;

/// Liste canonique ordonnée des 14 étapes d'architecture SurrealQL Lyxal OS (209 fichiers).
pub const SURREAL_IMPORT_STEPS: &[(&str, &[&str])] = &[
    (
        "01_options_and_context",
        &[], // Contexte namespace/database géré dynamiquement par SurrealBookingStore
    ),
    (
        "02_tables",
        &[
            "schema/booking_account.surql",
            "schema/booking.surql",
            "schema/booking_event_type.surql",
            "schema/booking_resource.surql",
            "schema/booking_team.surql",
            "schema/booking_setting.surql",
            "schema/booking_calendar.surql",
            "schema/booking_caldav_source.surql",
            "schema/booking_event.surql",
            "schema/booking_schedule.surql",
            "schema/booking_schedule_rule.surql",
            "schema/booking_schedule_override.surql",
            "schema/booking_time_off.surql",
            "schema/booking_frequency_limit.surql",
            "schema/booking_question.surql",
            "schema/booking_answer.surql",
            "schema/booking_invite.surql",
            "schema/booking_team_invite.surql",
            "schema/booking_activity.surql",
            "schema/booking_sync_log.surql",
            "schema/booking_host.surql",
            "schema/booking_group.surql",
            "schema/booking_session.surql",
            "schema/booking_watcher.surql",
        ],
    ),
    (
        "03_fields_and_indexes",
        &["schema/account_indexes.surql"],
    ),
    (
        "04_relations",
        &[
            "schema/booking_attendee.surql",
            "schema/booking_group_member.surql",
            "schema/booking_resource_allocation.surql",
            "schema/booking_team_group.surql",
            "schema/booking_team_member.surql",
        ],
    ),
    (
        "05_utility_and_core_functions",
        &[
            "functions/core/fn_check_username_taken.surql",
            "functions/core/fn_clear_user_avatar_path.surql",
            "functions/core/fn_get_all_enabled_users.surql",
            "functions/core/fn_get_company_link.surql",
            "functions/core/fn_get_dynamic_group_user_info.surql",
            "functions/core/fn_get_event_type_details_by_id.surql",
            "functions/core/fn_get_host_name_by_event_type.surql",
            "functions/core/fn_get_user_avatar_path.surql",
            "functions/core/fn_get_user_by_username.surql",
            "functions/core/fn_get_user_lend_resource_write.surql",
            "functions/core/fn_get_user_timezone.surql",
            "functions/core/fn_update_account_name_by_user.surql",
            "functions/core/fn_update_user_avatar_path.surql",
            "functions/core/fn_update_user_settings.surql",
            "functions/core/fn_update_user_timezone.surql",
            "functions/core/fn_update_user_username.surql",
        ],
    ),
    (
        "06_auth_and_users_functions",
        &[
            "functions/auth/fn_authenticate_user.surql",
            "functions/auth/fn_check_username_taken.surql",
            "functions/auth/fn_cleanup_expired_sessions.surql",
            "functions/auth/fn_create_local_account.surql",
            "functions/auth/fn_create_local_user.surql",
            "functions/auth/fn_create_session.surql",
            "functions/auth/fn_create_user.surql",
            "functions/auth/fn_delete_session.surql",
            "functions/auth/fn_delete_user.surql",
            "functions/auth/fn_find_or_create_oidc_account.surql",
            "functions/auth/fn_generate_username.surql",
            "functions/auth/fn_get_account_by_id.surql",
            "functions/auth/fn_get_auth_config.surql",
            "functions/auth/fn_get_company_link.surql",
            "functions/auth/fn_get_group_members.surql",
            "functions/auth/fn_get_user_email.surql",
            "functions/auth/fn_get_user_username.surql",
            "functions/auth/fn_lookup_auth_account.surql",
            "functions/auth/fn_sync_oidc_groups.surql",
            "functions/auth/fn_update_smtp_settings.surql",
            "functions/auth/fn_update_user_profile.surql",
            "functions/auth/fn_validate_session.surql",
            "functions/users/fn_get_user_profile.surql",
            "functions/users/fn_update_user_profile.surql",
            "functions/users/fn_update_user_timezone.surql",
        ],
    ),
    (
        "07_settings_functions",
        &[
            "functions/settings/fn_get_runtime_settings.surql",
            "functions/settings/fn_set_runtime_setting.surql",
        ],
    ),
    (
        "08_resources_and_calendars_functions",
        &[
            "functions/resources/fn_allocate_resource.surql",
            "functions/resources/fn_check_resource_availability.surql",
            "functions/resources/fn_create_resource.surql",
            "functions/resources/fn_create_with_resource_assignment.surql",
            "functions/resources/fn_delete_resource.surql",
            "functions/resources/fn_get_event_type_resources.surql",
            "functions/resources/fn_get_resource.surql",
            "functions/resources/fn_get_resource_busy_context.surql",
            "functions/resources/fn_get_resource_sync_context.surql",
            "functions/resources/fn_list_resources.surql",
            "functions/resources/fn_mark_resource_sync_failed.surql",
            "functions/resources/fn_replace_resource_events.surql",
            "functions/resources/fn_reschedule_with_resource_assignment.surql",
            "functions/resources/fn_set_resource_enabled.surql",
            "functions/resources/fn_update_resource.surql",
        ],
    ),
    (
        "09_event_types_functions",
        &[
            "functions/event_types/fn_can_manage_event_type.surql",
            "functions/event_types/fn_count_user_availability_rules.surql",
            "functions/event_types/fn_create_event_type.surql",
            "functions/event_types/fn_delete_event_type.surql",
            "functions/event_types/fn_delete_user_availability_rules.surql",
            "functions/event_types/fn_find_manageable_event_type_by_slug.surql",
            "functions/event_types/fn_get_event_type.surql",
            "functions/event_types/fn_get_event_type_host_user_id.surql",
            "functions/event_types/fn_get_event_type_meeting_info.surql",
            "functions/event_types/fn_get_event_type_resource_names.surql",
            "functions/event_types/fn_get_event_type_resources.surql",
            "functions/event_types/fn_get_event_types_for_user.surql",
            "functions/event_types/fn_get_internal_event_types.surql",
            "functions/event_types/fn_get_personal_event_types.surql",
            "functions/event_types/fn_get_private_internal_event_type.surql",
            "functions/event_types/fn_get_user_availability_rules.surql",
            "functions/event_types/fn_insert_user_availability_rule.surql",
            "functions/event_types/fn_list_event_types.surql",
            "functions/event_types/fn_save_availability_rules.surql",
            "functions/event_types/fn_save_overrides.surql",
            "functions/event_types/fn_toggle_event_type.surql",
            "functions/event_types/fn_update_event_type.surql",
            "functions/event_types/fn_update_event_type_resources.surql",
        ],
    ),
    (
        "10_availability_and_slots_functions",
        &[
            "functions/availability/fn_apply_buffers.surql",
            "functions/availability/fn_check_frequency_limit.surql",
            "functions/availability/fn_delete_availability_override.surql",
            "functions/availability/fn_get_availability_overrides.surql",
            "functions/availability/fn_get_available_slots.surql",
            "functions/availability/fn_get_setting.surql",
            "functions/availability/fn_is_slot_available.surql",
            "functions/availability/fn_save_availability_override.surql",
        ],
    ),
    (
        "11_teams_functions",
        &[
            "functions/teams/fn_add_team_member.surql",
            "functions/teams/fn_check_collective_availability.surql",
            "functions/teams/fn_clear_team_avatar_path.surql",
            "functions/teams/fn_create_team.surql",
            "functions/teams/fn_delete_team.surql",
            "functions/teams/fn_get_group_member_ids.surql",
            "functions/teams/fn_get_oidc_groups_with_counts.surql",
            "functions/teams/fn_get_team_avatar_path.surql",
            "functions/teams/fn_get_team_details.surql",
            "functions/teams/fn_get_team_invite_token.surql",
            "functions/teams/fn_get_team_linked_group_ids.surql",
            "functions/teams/fn_get_team_members.surql",
            "functions/teams/fn_get_team_members_with_users.surql",
            "functions/teams/fn_get_teams_for_user.surql",
            "functions/teams/fn_get_user_admin_teams.surql",
            "functions/teams/fn_nullify_event_types_team.surql",
            "functions/teams/fn_promote_team_member.surql",
            "functions/teams/fn_remove_direct_members_not_in_list.surql",
            "functions/teams/fn_remove_orphaned_group_members.surql",
            "functions/teams/fn_remove_team_member.surql",
            "functions/teams/fn_remove_unlinked_team_groups.surql",
            "functions/teams/fn_reset_team_member_roles.surql",
            "functions/teams/fn_round_robin_assign.surql",
            "functions/teams/fn_set_team_invite_token.surql",
            "functions/teams/fn_update_team.surql",
            "functions/teams/fn_update_team_avatar_path.surql",
            "functions/teams/fn_update_team_visibility.surql",
            "functions/teams/fn_upsert_team_group.surql",
            "functions/teams/fn_upsert_team_member.surql",
        ],
    ),
    (
        "12_bookings_and_invites_functions",
        &[
            "functions/bookings/fn_approve_booking.surql",
            "functions/bookings/fn_approve_by_token.surql",
            "functions/bookings/fn_cancel_booking.surql",
            "functions/bookings/fn_cancel_by_token.surql",
            "functions/bookings/fn_claim_booking.surql",
            "functions/bookings/fn_confirm_pending.surql",
            "functions/bookings/fn_create_booking.surql",
            "functions/bookings/fn_decline_by_token.surql",
            "functions/bookings/fn_get_booking_meeting_info.surql",
            "functions/bookings/fn_get_claimable_bookings.surql",
            "functions/bookings/fn_get_due_reminders.surql",
            "functions/bookings/fn_get_pending_booking_by_token.surql",
            "functions/bookings/fn_get_reschedule_booking_info.surql",
            "functions/bookings/fn_get_token_info.surql",
            "functions/bookings/fn_mark_reminder_sent.surql",
            "functions/bookings/fn_persist_meeting_url.surql",
            "functions/bookings/fn_reschedule_booking.surql",
            "functions/bookings/fn_reschedule_by_token.surql",
            "functions/invites/fn_consume_invite.surql",
            "functions/invites/fn_create_invite.surql",
            "functions/invites/fn_delete_invite.surql",
            "functions/invites/fn_validate_invite.surql",
        ],
    ),
    (
        "13_admin_platform_cli_dashboard_integrations",
        &[
            "functions/admin/fn_get_tenant_audit_logs.surql",
            "functions/admin/fn_get_tenant_metrics.surql",
            "functions/admin/fn_get_tenant_settings.surql",
            "functions/admin/fn_list_tenant_users.surql",
            "functions/admin/fn_update_tenant_settings.surql",
            "functions/admin/fn_update_tenant_user_role.surql",
            "functions/platform/fn_get_platform_audit_logs.surql",
            "functions/platform/fn_get_platform_metrics.surql",
            "functions/platform/fn_get_platform_settings.surql",
            "functions/platform/fn_list_platform_users.surql",
            "functions/platform/fn_list_tenants.surql",
            "functions/platform/fn_update_platform_settings.surql",
            "functions/cli/fn_cli_create_user.surql",
            "functions/dashboard/fn_get_dashboard_stats.surql",
            "functions/dashboard/fn_get_pending_bookings.surql",
            "functions/integrations/fn_commit_oauth_token_refresh.surql",
            "functions/integrations/fn_create_calendar_source.surql",
            "functions/integrations/fn_delete_calendar_source.surql",
            "functions/integrations/fn_delete_synchronized_event_by_remote_id.surql",
            "functions/integrations/fn_get_all_resources.surql",
            "functions/integrations/fn_get_caldav_oauth_refresh_context.surql",
            "functions/integrations/fn_get_calendar_by_href.surql",
            "functions/integrations/fn_get_calendar_source.surql",
            "functions/integrations/fn_get_resource_caldav_credentials.surql",
            "functions/integrations/fn_get_stalest_caldav_source.surql",
            "functions/integrations/fn_get_team_resources.surql",
            "functions/integrations/fn_get_user_calendars.surql",
            "functions/integrations/fn_get_writable_caldav_sources.surql",
            "functions/integrations/fn_list_all_caldav_sources.surql",
            "functions/integrations/fn_list_calendar_sources.surql",
            "functions/integrations/fn_replace_synchronized_calendar_snapshot.surql",
            "functions/integrations/fn_set_caldav_source_enabled.surql",
            "functions/integrations/fn_set_write_calendar.surql",
            "functions/integrations/fn_update_caldav_password.surql",
            "functions/integrations/fn_update_caldav_refresh_token.surql",
            "functions/integrations/fn_update_caldav_source_status.surql",
            "functions/integrations/fn_update_calendar_sync_state.surql",
            "functions/integrations/fn_update_oauth_access_token.surql",
            "functions/integrations/fn_update_oauth_client_secret.surql",
            "functions/integrations/fn_update_setting_secret.surql",
            "functions/integrations/fn_update_smtp_password.surql",
        ],
    ),
];

/// Harnais de test fournissant une instance in-memory de SurrealDB
/// avec l'ensemble des schémas et fonctions chargés.
#[derive(Clone)]
pub struct TestHarness {
    store: SurrealBookingStore,
    namespace: String,
    database: String,
}

impl TestHarness {
    /// Crée un nouveau harnais avec un namespace/database unique et isolé en mémoire.
    pub async fn new() -> Result<Self> {
        let unique_id = Uuid::new_v4().simple().to_string();
        let ns = format!("test_ns_{}", &unique_id[..8]);
        let db = format!("test_db_{}", &unique_id[..8]);
        Self::with_custom_ns(&ns, &db).await
    }

    /// Crée un harnais avec namespace et database spécifiques.
    pub async fn with_custom_ns(ns: &str, db: &str) -> Result<Self> {
        let store = SurrealBookingStore::connect(SurrealConnectionConfig {
            endpoint: "memory",
            namespace: ns,
            database: db,
            credentials: None,
        })
        .await
        .map_err(|e| anyhow::anyhow!("Erreur de connexion SurrealBookingStore in-memory: {}", e))?;

        let harness = Self {
            store,
            namespace: ns.to_string(),
            database: db.to_string(),
        };

        // Chargement des helpers universels de retour fn::result_ok / fn::result_error
        harness.init_result_helpers().await?;

        // Chargement de l'ensemble des 209 fichiers .surql
        harness.load_all_surrealql_steps().await?;

        Ok(harness)
    }

    /// Retourne la référence vers le store persistant `SurrealBookingStore`.
    pub fn store(&self) -> &SurrealBookingStore {
        &self.store
    }

    /// Exécute un appel typé vers une fonction SurrealQL canonique via `LyxalSurrealCall`.
    pub async fn call_fn<T, P>(&self, name: &str, params: P) -> Result<T, LyxalSurrealError>
    where
        T: DeserializeOwned,
        P: Serialize,
    {
        self.store.call_fn(name, params).await
    }

    /// Définition standard des fonctions de contrat LyxalResult
    async fn init_result_helpers(&self) -> Result<()> {
        let result_helpers = r#"
            DEFINE FUNCTION OVERWRITE fn::result_ok($data: any) {
                RETURN { ok: true, data: $data, error: NONE };
            };
            DEFINE FUNCTION OVERWRITE fn::result_error($code: string, $language: string, $details: object) {
                RETURN {
                    ok: false,
                    data: NONE,
                    error: {
                        code: $code,
                        module: "booking",
                        domain: "common",
                        category: "validation",
                        severity: "error",
                        message: $code,
                        http_status: 400,
                        retryable: false,
                        timestamp: time::now(),
                        details: $details
                    }
                };
            };
        "#;
        self.store
            .client()
            .query(result_helpers)
            .await
            .context("Échec d'enregistrement des helpers fn::result_ok / fn::result_error")?;
        Ok(())
    }

    /// Importe déterministement l'ensemble des fichiers SurrealQL.
    async fn load_all_surrealql_steps(&self) -> Result<()> {
        let base_dir = get_module_root();

        for (step_name, files) in SURREAL_IMPORT_STEPS {
            for rel_path in *files {
                let full_path = base_dir.join(rel_path);
                let content = std::fs::read_to_string(&full_path)
                    .with_context(|| format!("[Harness] Fichier introuvable: {:?}", full_path))?;

                let mut response = self
                    .store
                    .client()
                    .query(&content)
                    .await
                    .with_context(|| format!("[Harness] Requête échouée pour {}", rel_path))?;

                let errors = response.take_errors();
                if !errors.is_empty() {
                    return Err(anyhow::anyhow!(
                        "[Harness Import Error] Étape {} / Fichier {}: {:?}",
                        step_name,
                        rel_path,
                        errors
                    ));
                }
            }
        }
        Ok(())
    }
}

/// Résout la racine du module `lyxal_booking`.
fn get_module_root() -> PathBuf {
    let manifest_dir = Path::new(env!("CARGO_MANIFEST_DIR"));
    manifest_dir.parent().unwrap().to_path_buf()
}
