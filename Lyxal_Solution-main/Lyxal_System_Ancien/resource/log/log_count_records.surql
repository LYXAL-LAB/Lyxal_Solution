-- =============================================================================================
-- |
-- | Fichier : log_count_records.surql
-- | Module : system / log
-- | Description : Compte le nombre total d'enregistrements de log correspondant à un
-- |               ensemble de filtres.
-- |
-- | Paramètres :
-- |   - $filters: option<object> (Mêmes filtres que fn::log_get_records)
-- |
-- | Retour :
-- |   - { success: true, count: number }
-- =============================================================================================
DEFINE FUNCTION fn::log_count_records(
    $filters: option<object>
) {
    -- Définir les filtres à partir de l'objet $filters, avec des valeurs par défaut à NONE
    LET $f = $filters OR {};
    LET $run_id_filter = $f['operation.run_id'] OR NONE;
    LET $user_id_filter = $f['content.user_id'] OR NONE;
    LET $reason_key_filter = $f['result.reason_key'] OR NONE;
    LET $resource_table_filter = $f['resource.table_id'] OR NONE;
    LET $resource_id_filter = $f['resource.id'] OR NONE;
    LET $start_date_filter = $f['timestamp.start'] OR NONE;
    LET $end_date_filter = $f['timestamp.end'] OR NONE;

    -- Exécuter la requête de comptage
    LET $result = (
        SELECT count() AS total FROM log
        WHERE
            ($run_id_filter IS NONE OR operation.run_id = $run_id_filter)
            AND
            ($user_id_filter IS NONE OR content.user_id = type::thing($user_id_filter))
            AND
            ($reason_key_filter IS NONE OR result.reason_key = type::thing($reason_key_filter))
            AND
            ($resource_table_filter IS NONE OR resource.table_id = type::thing($resource_table_filter))
            AND
            ($resource_id_filter IS NONE OR resource.id = $resource_id_filter)
            AND
            ($start_date_filter IS NONE OR timestamp.created_at >= type::datetime($start_date_filter))
            AND
            ($end_date_filter IS NONE OR timestamp.created_at <= type::datetime($end_date_filter))
        GROUP ALL
    );
    
    RETURN {
        success: true,
        count: $result[0].total OR 0
    };
}
COMMENT 'Compte les enregistrements de log en fonction des filtres fournis.';
