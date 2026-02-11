-- =============================================================================================
-- |
-- | Fichier : log_error_code_seeds.surql
-- | Module : System / log
-- | Description : Seeds pour les codes d'erreur du module log.
-- |               Utilise uniquement fn::create_error_code (les clés i18n sont créées automatiquement via events).
-- |
-- =============================================================================================

BEGIN;

-- =============================================================================================
-- | Codes d'erreur pour fn::log_create_record
-- =============================================================================================

-- Création réussie
fn::create_error_code(
    "LOG_CREATE_RECORD_SUCCESS",
    "error_code_log_create_record_success_message",
    "success",
    true,
    "L'entrée de log a été créée avec succès.",
    "error_code_log_create_record_success_label",
    "Log créé",
    "error_code_log_create_record_success_description",
    "L'enregistrement de log a été créé avec succès dans le système.",
    "system",
    "Le log est maintenant disponible pour consultation.",
    NONE,
    "log"
);

-- Logging désactivé
fn::create_error_code(
    "LOG_CREATE_RECORD_DISABLED",
    "error_code_log_create_record_disabled_message",
    "info",
    true,
    "Le logging est désactivé. L'entrée de log n'a pas été créée.",
    "error_code_log_create_record_disabled_label",
    "Logging désactivé",
    "error_code_log_create_record_disabled_description",
    "Le système de logging est désactivé dans la configuration. Aucun log n'a été enregistré.",
    "system",
    "Activer le logging dans la configuration si nécessaire.",
    NONE,
    "log"
);

-- Sévérité trop basse
fn::create_error_code(
    "LOG_CREATE_RECORD_SKIPPED_SEVERITY_TOO_LOW",
    "error_code_log_create_record_skipped_severity_too_low_message",
    "info",
    true,
    "L'entrée de log n'a pas été créée car la sévérité est inférieure au niveau minimum configuré.",
    "error_code_log_create_record_skipped_severity_too_low_label",
    "Log ignoré",
    "error_code_log_create_record_skipped_severity_too_low_description",
    "La sévérité de l'événement est inférieure au niveau de verbosité minimum configuré. Le log n'a pas été enregistré.",
    "system",
    "Ajuster le niveau de verbosité dans la configuration si nécessaire.",
    NONE,
    "log"
);

-- Échec de création
fn::create_error_code(
    "LOG_CREATE_RECORD_FAILED",
    "error_code_log_create_record_failed_message",
    "error",
    false,
    "Échec de la création de l'entrée de log.",
    "error_code_log_create_record_failed_label",
    "Échec de création",
    "error_code_log_create_record_failed_description",
    "Une erreur s'est produite lors de la création de l'enregistrement de log.",
    "system",
    "Vérifier les logs système et contacter le support technique si le problème persiste.",
    NONE,
    "log"
);

-- Configuration non trouvée
fn::create_error_code(
    "LOG_CREATE_RECORD_FAILED_CONFIG_NOT_FOUND",
    "error_code_log_create_record_failed_config_not_found_message",
    "error",
    false,
    "La configuration du système n'a pas été trouvée. Impossible de créer l'entrée de log.",
    "error_code_log_create_record_failed_config_not_found_label",
    "Configuration introuvable",
    "error_code_log_create_record_failed_config_not_found_description",
    "La configuration du système (system_configuration:default) est introuvable. Le logging ne peut pas fonctionner sans cette configuration.",
    "system",
    "Vérifier que la configuration du système est correctement initialisée.",
    NONE,
    "log"
);

-- =============================================================================================
-- | Codes d'erreur pour fn::log_archive
-- =============================================================================================

-- Archivage réussi
fn::create_error_code(
    "LOG_ARCHIVE_SUCCESS",
    "error_code_log_archive_success_message",
    "success",
    true,
    "Les logs ont été archivés avec succès.",
    "error_code_log_archive_success_label",
    "Archivage réussi",
    "error_code_log_archive_success_description",
    "Les logs expirés ont été déplacés vers l'archive avec succès.",
    "system",
    "Les logs archivés sont maintenant disponibles dans la table log_archive.",
    NONE,
    "log"
);

-- Aucun log à archiver
fn::create_error_code(
    "LOG_ARCHIVE_NO_LOGS_TO_ARCHIVE",
    "error_code_log_archive_no_logs_to_archive_message",
    "info",
    true,
    "Aucun log n'a besoin d'être archivé pour le moment.",
    "error_code_log_archive_no_logs_to_archive_label",
    "Aucun log à archiver",
    "error_code_log_archive_no_logs_to_archive_description",
    "Aucun log n'a atteint sa date d'expiration de rétention chaude. Aucune action d'archivage nécessaire.",
    "system",
    "Aucune action requise. L'archivage sera effectué automatiquement lorsque des logs expireront.",
    NONE,
    "log"
);

-- Configuration non trouvée
fn::create_error_code(
    "LOG_ARCHIVE_FAILED_CONFIG_NOT_FOUND",
    "error_code_log_archive_failed_config_not_found_message",
    "error",
    false,
    "La configuration du système n'a pas été trouvée. Impossible d'archiver les logs.",
    "error_code_log_archive_failed_config_not_found_label",
    "Configuration introuvable",
    "error_code_log_archive_failed_config_not_found_description",
    "La configuration du système (system_configuration:default) est introuvable. L'archivage ne peut pas fonctionner sans cette configuration.",
    "system",
    "Vérifier que la configuration du système est correctement initialisée.",
    NONE,
    "log"
);

-- =============================================================================================
-- | Codes d'erreur pour fn::log_archive_cleanup
-- =============================================================================================

-- Nettoyage réussi
fn::create_error_code(
    "LOG_ARCHIVE_CLEANUP_SUCCESS",
    "error_code_log_archive_cleanup_success_message",
    "success",
    true,
    "Le nettoyage des archives a été effectué avec succès.",
    "error_code_log_archive_cleanup_success_label",
    "Nettoyage réussi",
    "error_code_log_archive_cleanup_success_description",
    "Les anciens logs archivés ont été supprimés avec succès.",
    "system",
    "Les logs archivés expirés ont été définitivement supprimés.",
    NONE,
    "log"
);

-- =============================================================================================
-- | Codes d'erreur pour fn::log_cleanup
-- =============================================================================================

-- Nettoyage réussi
fn::create_error_code(
    "LOG_CLEANUP_SUCCESS",
    "error_code_log_cleanup_success_message",
    "success",
    true,
    "Le nettoyage des archives a été effectué avec succès.",
    "error_code_log_cleanup_success_label",
    "Nettoyage réussi",
    "error_code_log_cleanup_success_description",
    "Les logs archivés dont la rétention froide a expiré ont été supprimés avec succès.",
    "system",
    "Les logs archivés expirés ont été définitivement supprimés.",
    NONE,
    "log"
);

-- Aucun log à supprimer
fn::create_error_code(
    "LOG_CLEANUP_NO_LOGS_TO_DELETE",
    "error_code_log_cleanup_no_logs_to_delete_message",
    "info",
    true,
    "Aucun log archivé n'a besoin d'être supprimé pour le moment.",
    "error_code_log_cleanup_no_logs_to_delete_label",
    "Aucun log à supprimer",
    "error_code_log_cleanup_no_logs_to_delete_description",
    "Aucun log archivé n'a atteint sa date d'expiration de rétention froide. Aucune action de nettoyage nécessaire.",
    "system",
    "Aucune action requise. Le nettoyage sera effectué automatiquement lorsque des logs archivés expireront.",
    NONE,
    "log"
);

-- =============================================================================================
-- | Codes d'erreur pour fn::log_get_record_by_id
-- =============================================================================================

-- Récupération réussie
fn::create_error_code(
    "LOG_GET_RECORD_BY_ID_SUCCESS",
    "error_code_log_get_record_by_id_success_message",
    "success",
    true,
    "Le log a été récupéré avec succès.",
    "error_code_log_get_record_by_id_success_label",
    "Log récupéré",
    "error_code_log_get_record_by_id_success_description",
    "Le log demandé a été récupéré et traduit avec succès.",
    "system",
    "Le log est maintenant disponible pour consultation.",
    NONE,
    "log"
);

-- Log non trouvé
fn::create_error_code(
    "LOG_GET_RECORD_BY_ID_NOT_FOUND",
    "error_code_log_get_record_by_id_not_found_message",
    "error",
    false,
    "Le log demandé est introuvable.",
    "error_code_log_get_record_by_id_not_found_label",
    "Log introuvable",
    "error_code_log_get_record_by_id_not_found_description",
    "Le log avec l'identifiant fourni n'existe pas dans le système.",
    "system",
    "Vérifier l'identifiant du log et son existence dans le système.",
    NONE,
    "log"
);

-- =============================================================================================
-- | Codes d'erreur pour fn::log_get_records
-- =============================================================================================

-- Récupération réussie
fn::create_error_code(
    "LOG_GET_RECORDS_SUCCESS",
    "error_code_log_get_records_success_message",
    "success",
    true,
    "Les logs ont été récupérés avec succès.",
    "error_code_log_get_records_success_label",
    "Logs récupérés",
    "error_code_log_get_records_success_description",
    "La liste des logs a été récupérée et traduite avec succès selon les filtres appliqués.",
    "system",
    "Les logs sont maintenant disponibles pour consultation.",
    NONE,
    "log"
);

-- Liste vide
fn::create_error_code(
    "LOG_GET_RECORDS_EMPTY",
    "error_code_log_get_records_empty_message",
    "info",
    true,
    "Aucun log ne correspond aux critères de recherche.",
    "error_code_log_get_records_empty_label",
    "Aucun résultat",
    "error_code_log_get_records_empty_description",
    "Aucun log ne correspond aux filtres appliqués dans la requête.",
    "system",
    "Modifier les critères de recherche ou vérifier qu'il existe des logs correspondants.",
    NONE,
    "log"
);

-- =============================================================================================
-- | Codes d'erreur pour fn::log_run_maintenance
-- =============================================================================================

-- Début de maintenance
fn::create_error_code(
    "LOG_RUN_MAINTENANCE_START",
    "error_code_log_run_maintenance_start_message",
    "info",
    true,
    "Début de la maintenance des logs.",
    "error_code_log_run_maintenance_start_label",
    "Maintenance démarrée",
    "error_code_log_run_maintenance_start_description",
    "Le processus de maintenance des logs (archivage et nettoyage) a été démarré.",
    "system",
    "La maintenance est en cours d'exécution.",
    NONE,
    "log"
);

-- Maintenance réussie
fn::create_error_code(
    "LOG_RUN_MAINTENANCE_SUCCESS",
    "error_code_log_run_maintenance_success_message",
    "success",
    true,
    "La maintenance des logs a été effectuée avec succès.",
    "error_code_log_run_maintenance_success_label",
    "Maintenance réussie",
    "error_code_log_run_maintenance_success_description",
    "Le processus de maintenance des logs (archivage et nettoyage) s'est terminé avec succès.",
    "system",
    "Les logs ont été archivés et nettoyés selon la configuration.",
    NONE,
    "log"
);

-- Échec de maintenance
fn::create_error_code(
    "LOG_RUN_MAINTENANCE_FAILED",
    "error_code_log_run_maintenance_failed_message",
    "error",
    false,
    "La maintenance des logs a échoué.",
    "error_code_log_run_maintenance_failed_label",
    "Échec de maintenance",
    "error_code_log_run_maintenance_failed_description",
    "Une erreur s'est produite lors de l'exécution de la maintenance des logs (archivage ou nettoyage).",
    "system",
    "Vérifier les logs système et la configuration. Réessayer la maintenance si nécessaire.",
    NONE,
    "log"
);

COMMIT;