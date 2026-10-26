-- ============================================================================
-- FONCTION : fn::ingestion_staged_list
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Recherche paginée et filtrée des articles en staging pour la console
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_staged_list($params: object) {
    LET $limit = IF $params.limit != NONE { <int> $params.limit } ELSE { 50 };
    LET $start = IF $params.start != NONE { <int> $params.start } ELSE { 0 };
    LET $batch_filter = IF $params.batch_id != NONE { <string> $params.batch_id } ELSE { NONE };
    LET $qual_filter = IF $params.qualification != NONE { string::uppercase(<string> $params.qualification) } ELSE { NONE };
    LET $mfg_filter = IF $params.fabricant != NONE { string::uppercase(<string> $params.fabricant) } ELSE { NONE };

    LET $b_rec = IF $batch_filter != NONE { <record> string::concat('ingestion_batch:', $batch_filter) } ELSE { NONE };

    LET $all_matches = (SELECT id FROM ingestion_staged_item WHERE
        ($b_rec == NONE OR batch = $b_rec) AND
        ($qual_filter == NONE OR qualification = $qual_filter) AND
        ($mfg_filter == NONE OR fabricant = $mfg_filter)
    );
    LET $total = array::len($all_matches);

    LET $items = (SELECT 
        <string> id AS id,
        <string> batch AS batch,
        ligne_numero,
        canonical_fingerprint,
        rules_version,
        fabricant,
        marque,
        reference_fabricant,
        code_barre_gtin,
        libelle_commercial,
        description_technique,
        type_item,
        unite_reference,
        conditionnement,
        qualification,
        qualification_reason,
        publication_action,
        diff_payload,
        transitions,
        is_approved,
        approved_by,
        IF approved_at != NONE { <string> approved_at } ELSE { NONE } AS approved_at
    FROM ingestion_staged_item WHERE
        ($b_rec == NONE OR batch = $b_rec) AND
        ($qual_filter == NONE OR qualification = $qual_filter) AND
        ($mfg_filter == NONE OR fabricant = $mfg_filter)
        ORDER BY ligne_numero ASC
        LIMIT $limit START $start
    );

    RETURN fn::result_ok({
        items: $items,
        total: $total,
        limit: $limit,
        start: $start
    });
} COMMENT "Retourne la liste paginée et filtrée des articles en staging";
