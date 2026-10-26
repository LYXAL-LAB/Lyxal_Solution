-- ============================================================================
-- FONCTION : fn::ingestion_manifest_list
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Consultation paginée et filtrée des manifestes de publication
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_list($params: object) {
    LET $limit = IF $params.limit != NONE { <int> $params.limit } ELSE { 50 };
    LET $start = IF $params.start != NONE { <int> $params.start } ELSE { 0 };
    LET $statut_filter = IF $params.statut != NONE { string::uppercase(<string> $params.statut) } ELSE { NONE };
    LET $batch_filter = IF $params.batch_id != NONE { <string> $params.batch_id } ELSE { NONE };

    LET $b_rec = IF $batch_filter != NONE { <record> string::concat('ingestion_batch:', $batch_filter) } ELSE { NONE };

    LET $all_matches = (SELECT id FROM ingestion_publication_manifest WHERE
        ($b_rec == NONE OR batch = $b_rec) AND
        ($statut_filter == NONE OR statut = $statut_filter)
    );
    LET $total = array::len($all_matches);

    LET $manifests = (SELECT 
        <string> id AS id,
        <string> batch AS batch,
        manifest_ref,
        manifest_version,
        seal_hash,
        is_sealed,
        statut,
        approved_by,
        IF approved_at != NONE { <string> approved_at } ELSE { NONE } AS approved_at,
        approver_role,
        nb_articles_insert,
        nb_articles_update,
        items_committed,
        items_failed,
        execution_items,
        transitions,
        IF executed_at != NONE { <string> executed_at } ELSE { NONE } AS executed_at
    FROM ingestion_publication_manifest WHERE
        ($b_rec == NONE OR batch = $b_rec) AND
        ($statut_filter == NONE OR statut = $statut_filter)
        ORDER BY id DESC
        LIMIT $limit START $start
    );

    RETURN fn::result_ok({
        manifests: $manifests,
        total: $total,
        limit: $limit,
        start: $start
    });
} COMMENT "Retourne la liste paginée et filtrée des manifestes de publication";
