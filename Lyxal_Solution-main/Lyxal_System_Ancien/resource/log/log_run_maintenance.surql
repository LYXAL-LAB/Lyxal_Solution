-- =============================================================================================
-- |
-- | Fichier : log_run_maintenance.surql
-- | Module : system / log
-- | Description : Orchestre les tâches de maintenance des logs. C'est le point d'entrée
-- |               unique à appeler pour l'archivage et le nettoyage.
-- |
-- | Comportement :
-- |   1. Loggue le début de l'opération.
-- |   2. Appelle `fn::log_archive()` pour déplacer les logs expirés vers l'archive.
-- |   3. Appelle `fn::log_cleanup()` pour supprimer les archives expirées.
-- |   4. Loggue le résultat (succès ou échec) de l'opération complète.
-- |   5. Retourne un résumé des opérations.
-- |
-- | Retour :
-- |   - { success: true, run_id: string, archived: number, cleaned: number, log_id: record<log> }
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::log_run_maintenance() {
    LET $run_id = rand::uuid();
    LET $start_time = time::now();

    -- Log du début de la maintenance
    -- NOTE: Ces error_code devront être créés.
    fn::log_create_record({
        success: true,
        reason_key: error_code:log_run_maintenance_start
    }, { run_id: $run_id });

    -- Étape 1: Archiver les logs
    LET $archive_result = fn::log_archive();

    -- Étape 2: Nettoyer les archives
    LET $cleanup_result = fn::log_cleanup();

    -- Étape 3: Déterminer le statut final et préparer le log de fin
    LET $final_success = 
        $archive_result.success = true AND
        $cleanup_result.success = true;

    LET $final_reason_key = IF $final_success {
        error_code:log_run_maintenance_success
    } ELSE {
        error_code:log_run_maintenance_failed
    };

    LET $end_log_data = {
        run_id: $run_id,
        duration_ms: (time::now() - $start_time).ms,
        archive_result: $archive_result,
        cleanup_result: $cleanup_result
    };
    
    -- Étape 4: Logguer la fin de la maintenance
    LET $end_log = fn::log_create_record({
        success: $final_success,
        reason_key: $final_reason_key
    }, { run_id: $run_id }, NONE, NONE, NONE, NONE, NONE, $end_log_data);

    -- Étape 5: Retourner le résultat combiné
    RETURN {
      success: $final_success,
      run_id: $run_id,
      archived: $archive_result.archived_count OR 0,
      cleaned: $cleanup_result.deleted_count OR 0,
      log_id: $end_log.data.log_id
    };
  }
  COMMENT "Exécute et loggue les tâches de maintenance des logs : archivage et nettoyage."
  PERMISSIONS FULL;