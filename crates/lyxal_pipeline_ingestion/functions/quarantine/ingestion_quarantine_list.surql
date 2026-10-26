-- ============================================================================
-- FONCTION : fn::ingestion_quarantine_list
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Consultation paginée et filtrée des anomalies en quarantaine
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_list($params: object) {
    LET $limit = IF $params.limit != NONE { <int> $params.limit } ELSE { 50 };
    LET $start = IF $params.start != NONE { <int> $params.start } ELSE { 0 };
    LET $batch_filter = IF $params.batch_id != NONE { <string> $params.batch_id } ELSE { NONE };
    LET $sev_filter = IF $params.severite != NONE { string::uppercase(<string> $params.severite) } ELSE { NONE };
    LET $resolved_filter = IF $params.is_resolved != NONE { <bool> $params.is_resolved } ELSE { NONE };

    LET $b_rec = IF $batch_filter != NONE { <record> string::concat('ingestion_batch:', $batch_filter) } ELSE { NONE };

    LET $all_matches = (SELECT id FROM ingestion_quarantine_record WHERE
        ($b_rec == NONE OR batch = $b_rec) AND
        ($sev_filter == NONE OR severite = $sev_filter) AND
        ($resolved_filter == NONE OR is_resolved = $resolved_filter)
    );
    LET $total = array::len($all_matches);

    LET $records = (SELECT 
        <string> id AS id,
        <string> batch AS batch,
        IF raw_record != NONE { <string> raw_record } ELSE { NONE } AS raw_record,
        code_erreur,
        severite,
        champ_concerne,
        valeur_fautive,
        cause_detaillee,
        IF created_at != NONE { <string> created_at } ELSE { NONE } AS created_at,
        is_resolved,
        resolved_by,
        IF resolved_at != NONE { <string> resolved_at } ELSE { NONE } AS resolved_at,
        resolution_comment
    FROM ingestion_quarantine_record WHERE
        ($b_rec == NONE OR batch = $b_rec) AND
        ($sev_filter == NONE OR severite = $sev_filter) AND
        ($resolved_filter == NONE OR is_resolved = $resolved_filter)
        ORDER BY created_at DESC
        LIMIT $limit START $start
    );

    RETURN fn::result_ok({
        records: $records,
        total: $total,
        limit: $limit,
        start: $start
    });
} COMMENT "Retourne la liste paginée et filtrée des anomalies en zone de quarantaine";
